from __future__ import annotations

import asyncio
import io
import logging
from enum import Enum
from pathlib import Path
from typing import Any

import httpx
import segno

from app.config.settings import get_settings
from app.services.whatsapp_ai_reply import generate_whatsapp_reply
from app.services.whatsapp_cloud import is_cloud_configured
from app.services.whatsapp_history import init_db, save_message
from app.services.whatsapp_runtime import effective_driver
from app.services.whatsapp_service import generate_contact_qr_png, get_whatsapp_status
from app.services.whatsapp_session_store import get_session_db_path, session_exists

logger = logging.getLogger(__name__)

_AI_RETRIES = 3
_AI_RETRY_DELAY_S = 2.0
_UNAUTHORIZED_WHATSAPP_MSG = (
    "Désolé, votre numéro n'est pas répertorié dans le système Marsa Maroc. "
    "L'accès à l'assistant IA est réservé au personnel autorisé."
)


class ConnectionState(str, Enum):
    DISCONNECTED = "disconnected"
    CONNECTING = "connecting"
    QR_PENDING = "qr_pending"
    CONNECTED = "connected"
    ERROR = "error"


class WhatsAppBotManager:
    """Client WhatsApp Web (Neonize) pour la ligne business +212689461643."""

    def __init__(self) -> None:
        self._lock = asyncio.Lock()
        self._client: Any = None
        self._connect_task: asyncio.Task | None = None
        self._reconnect_task: asyncio.Task | None = None
        self._state = ConnectionState.DISCONNECTED
        self._error: str | None = None
        self._qr_png: bytes | None = None
        self._ai_sem = asyncio.Semaphore(2)
        self._logged_out = False
        self._resetting = False

    @property
    def state(self) -> ConnectionState:
        return self._state

    @property
    def error(self) -> str | None:
        return self._error

    def _client_live(self, client: Any | None = None) -> bool:
        """Neonize peut avoir client.me / is_logged_in sans connected=True (reconnexion 515)."""
        c = client or self._client
        if c is None:
            return False
        if getattr(c, "me", None):
            return True
        if getattr(c, "connected", False):
            return True
        try:
            if c.is_logged_in:
                return True
        except Exception:
            pass
        try:
            if c.is_connected:
                return True
        except Exception:
            pass
        return False

    def is_connected(self) -> bool:
        return self._client_live() or self._state == ConnectionState.CONNECTED

    def _mark_connected(self) -> None:
        if self._state == ConnectionState.CONNECTED and not self._qr_png:
            return
        self._state = ConnectionState.CONNECTED
        self._qr_png = None
        self._error = None
        logger.info("Ligne WhatsApp business connectee — reponses auto actives")

    async def _connection_watcher(self, client: Any) -> None:
        """Neonize peut authentifier sans ConnectedEv — surveiller me / is_logged_in."""
        for _ in range(300):
            await asyncio.sleep(1)
            if self._logged_out or self._resetting:
                return
            if self._client_live(client):
                self._mark_connected()
                return

    async def get_pairing_qr_png(self) -> bytes | None:
        return self._qr_png

    async def get_contact_qr_png(self) -> bytes:
        return generate_contact_qr_png()

    def _clear_session_store(self) -> None:
        """Uniquement apres 401 ou reset admin — pas a l'arret normal du serveur."""
        paths = [
            get_session_db_path(),
            Path(__file__).resolve().parent.parent.parent / "neonize.db",
        ]
        seen: set[str] = set()
        for path in paths:
            key = str(path.resolve())
            if key in seen:
                continue
            seen.add(key)
            if path.is_file():
                try:
                    path.unlink()
                    logger.info("Session WhatsApp supprimee: %s", path)
                except OSError as exc:
                    logger.warning("Impossible de supprimer %s: %s", path, exc)

    async def reset_session(self) -> None:
        """Apres deconnexion 401 : efface la session et relance le QR admin."""
        if self._resetting:
            return
        self._resetting = True
        try:
            await self._reset_session_impl()
        finally:
            self._resetting = False

    async def _reset_session_impl(self) -> None:
        async with self._lock:
            self._logged_out = True
            if self._reconnect_task and not self._reconnect_task.done():
                self._reconnect_task.cancel()
            if self._client:
                try:
                    await self._client.disconnect()
                except Exception:
                    pass
            if self._connect_task and not self._connect_task.done():
                self._connect_task.cancel()
            self._client = None
            self._connect_task = None
            self._qr_png = None
            self._state = ConnectionState.DISCONNECTED
        self._clear_session_store()
        self._logged_out = False
        self._error = None
        await self.start()

    async def start(self) -> None:
        if effective_driver() != "neonize":
            return
        async with self._lock:
            if self._client_live():
                self._mark_connected()
                return
            if self._connect_task and not self._connect_task.done():
                return
            init_db()
            self._logged_out = False
            self._state = ConnectionState.CONNECTING
            self._error = None
            self._connect_task = asyncio.create_task(self._run_client())

    async def stop(self) -> None:
        async with self._lock:
            if self._reconnect_task and not self._reconnect_task.done():
                self._reconnect_task.cancel()
            if self._client:
                try:
                    await self._client.disconnect()
                except Exception as exc:
                    logger.warning("WhatsApp disconnect: %s", exc)
            if self._connect_task and not self._connect_task.done():
                self._connect_task.cancel()
                try:
                    await self._connect_task
                except asyncio.CancelledError:
                    pass
            self._client = None
            self._connect_task = None
            self._reconnect_task = None
            self._state = ConnectionState.DISCONNECTED
            self._qr_png = None

    def _schedule_reconnect(self) -> None:
        if self._logged_out:
            return
        if self._reconnect_task and not self._reconnect_task.done():
            return

        async def _reconnect() -> None:
            await asyncio.sleep(15)
            if self._logged_out or self.is_connected():
                return
            logger.info("Tentative de reconnexion Neonize…")
            await self.start()

        self._reconnect_task = asyncio.create_task(_reconnect())

    async def _run_client(self) -> None:
        try:
            from neonize.aioze.client import NewAClient
            from neonize.aioze.events import (
                ConnectedEv,
                DisconnectedEv,
                LoggedOutEv,
                MessageEv,
                PairStatusEv,
            )
            from neonize.proto.Neonize_pb2 import PairStatus as PairStatusProto
            from neonize.utils import jid
            from neonize.utils.message import extract_text

            db_path = get_session_db_path()
            if session_exists():
                logger.info("Session WhatsApp trouvee — synchronisation sans nouveau QR (%s)", db_path.name)
            else:
                logger.info("Premiere liaison — scannez le QR serveur (admin) une seule fois")
            self._client = NewAClient(str(db_path))

            @self._client.event(PairStatusEv)
            async def on_pair_status(_client: NewAClient, evt: PairStatusEv) -> None:
                if evt.Status == PairStatusProto.SUCCESS:
                    self._mark_connected()

            @self._client.qr
            async def on_qr(_client: NewAClient, data: bytes) -> None:
                if self._client_live(_client) or getattr(_client, "me", None):
                    return
                if self._state == ConnectionState.CONNECTED:
                    return
                try:
                    qr_str = data.decode("utf-8") if isinstance(data, bytes) else str(data)
                    buf = io.BytesIO()
                    segno.make(qr_str).save(buf, kind="png", scale=8)
                    self._qr_png = buf.getvalue()
                    self._state = ConnectionState.QR_PENDING
                    logger.info("QR Neonize pret — scanner avec +212689461643 (admin)")
                except Exception as exc:
                    logger.exception("QR encode failed: %s", exc)

            @self._client.event(ConnectedEv)
            async def on_connected(_client: NewAClient, _evt: ConnectedEv) -> None:
                self._mark_connected()

            @self._client.event(DisconnectedEv)
            async def on_disconnected(_client: NewAClient, _evt: DisconnectedEv) -> None:
                if self._logged_out:
                    return
                if self._client_live(_client) or getattr(_client, "me", None):
                    logger.info("Deconnexion WhatsApp temporaire — reprise automatique")
                    return
                if self._state == ConnectionState.CONNECTED:
                    logger.warning("WhatsApp deconnecte — reconnexion planifiee")
                self._state = ConnectionState.DISCONNECTED
                self._schedule_reconnect()

            @self._client.event(LoggedOutEv)
            async def on_logged_out(_client: NewAClient, _evt: LoggedOutEv) -> None:
                self._logged_out = True
                self._state = ConnectionState.ERROR
                self._error = (
                    "Session WhatsApp expiree (deconnexion 401). "
                    "Ouvrez /?admin=1 puis « Reinitialiser session » et rescannez le QR serveur."
                )
                logger.error("WhatsApp 401 logged out — rescan QR serveur requis (+212)")
                if not self._resetting:
                    asyncio.create_task(self.reset_session())

            @self._client.event(MessageEv)
            async def on_message(client: NewAClient, evt: MessageEv) -> None:
                if self._client_live(client):
                    self._mark_connected()
                asyncio.create_task(self._handle_incoming(client, evt, extract_text, jid))

            self._state = ConnectionState.CONNECTING
            await self._client.connect()
            asyncio.create_task(self._connection_watcher(self._client))
        except asyncio.CancelledError:
            raise
        except Exception as exc:
            logger.exception("WhatsApp neonize failed")
            self._state = ConnectionState.ERROR
            self._error = str(exc)

    def _is_business_sync_message(self, chat_jid: str, sender_jid: str) -> bool:
        """Ignore uniquement les messages systeme du propre numero (pas les clients)."""
        phone = get_settings().whatsapp_phone.lstrip("+").replace(" ", "")
        local = phone.split("@")[0]

        def _user(jid_str: str) -> str:
            return jid_str.split("@")[0].split(":")[0]

        return _user(sender_jid) == local and _user(chat_jid) == local

    @staticmethod
    def _phone_from_jid(jid: str) -> str | None:
        """Extrait proprement le numéro depuis WhatsApp."""

        if not jid:
            return None

        local = jid.split("@")[0].split(":")[0].strip()

        logger.info("RAW JID = %s", jid)
        logger.info("LOCAL PART = %s", local)

        digits = "".join(c for c in local if c.isdigit())

        logger.info("DIGITS = %s", digits)

        # ignore IDs incohérents
        if len(digits) < 10 or len(digits) > 15:
            logger.warning("Numero invalide ignore: %s", digits)
            return None

        return digits

    async def _fetch_user_id_from_java(self, jid: str) -> int | None:
        phone = self._phone_from_jid(jid)
        if not phone:
            return None
        settings = get_settings()
        base = (settings.java_backend_base_url or "http://localhost:8080").rstrip("/")
        url = f"{base}/api/internal/personnel/by-phone/{phone}"
        try:
            timeout = httpx.Timeout(5.0, connect=2.0)
            async with httpx.AsyncClient(timeout=timeout) as client:
                resp = await client.get(url)
                if resp.status_code == 404:
                    return None
                resp.raise_for_status()
                data = resp.json()
                if isinstance(data, int):
                    return data
                if isinstance(data, dict):
                    for key in ("id", "userId", "user_id"):
                        val = data.get(key)
                        if val is not None:
                            return int(val)
        except Exception as exc:
            logger.debug("Lookup Java user_id pour %s ignore (%s)", phone, exc)
        return None

    async def _handle_incoming(self, client: Any, evt: Any, extract_text: Any, jid_mod: Any) -> None:
        settings = get_settings()
        info = evt.Info
        source = info.MessageSource
        if source.IsFromMe:
            return
        chat = source.Chat
        chat_jid = jid_mod.Jid2String(chat)
        sender_jid = chat_jid
        if getattr(source, "Sender", None):
            candidate = jid_mod.Jid2String(source.Sender)

            logger.info("Candidate sender = %s", candidate)

    # ignorer les IDs WhatsApp LID
            if "@lid" not in candidate:
                sender_jid = candidate

        logger.info("FINAL SENDER = %s", sender_jid)
        logger.info("CHAT JID = %s", chat_jid)
        if self._is_business_sync_message(chat_jid, sender_jid):
            return
        if settings.whatsapp_ignore_groups and getattr(chat, "Server", "") == "g.us":
            return
        if getattr(info, "Category", "") == "peer":
            return

        if self._client_live(client):
            self._mark_connected()
        elif not self._client_live(client) and self._state not in (
            ConnectionState.CONNECTED,
            ConnectionState.CONNECTING,
        ):
            logger.warning("Message ignore (session non prete): %s", chat_jid)
            return

        push_name = info.Pushname or ""
        wa_id = info.ID
        user_text = (extract_text(evt.Message) or "").strip()

        input_type = "text"
        content: str | None = None
        mime: str | None = None
        media_type: str | None = None
        msg = evt.Message

        if msg.imageMessage.ListFields():
            media_type = "image"
            input_type = "image"
            mime = msg.imageMessage.mimetype or "image/jpeg"
        elif msg.videoMessage.ListFields():
            media_type = "video"
            input_type = "video"
            mime = msg.videoMessage.mimetype or "video/mp4"

        if media_type and input_type in {"image", "video"}:
            try:
                import base64

                raw = await client.download_any(evt)
                content = base64.b64encode(raw).decode("ascii")
                if not user_text:
                    user_text = f"[{media_type}]"
            except Exception as exc:
                logger.warning("Media download failed: %s", exc)
                user_text = user_text or f"Fichier {media_type}"
                input_type = "text"

        if not user_text and not content:
            return

        phone = self._phone_from_jid(sender_jid)

        logger.info(
            "Message WhatsApp recu de %s (%s) phone=%s : %s",
            push_name or chat_jid,
            chat_jid,
            phone,
            user_text[:80],
        )

        save_message(
            chat_jid=chat_jid,
            direction="in",
            body=user_text,
            source="WHATSAPP",
            sender_jid=phone,
            push_name=push_name,
            media_type=media_type,
            wa_message_id=wa_id,
        )

        if phone  is None:
            logger.warning("Numero WhatsApp invalide")
            if self._client_live(client):
                try:
                    await client.reply_message(_UNAUTHORIZED_WHATSAPP_MSG, evt, to=chat)
                    save_message(
                        chat_jid=chat_jid,
                        direction="out",
                        body=_UNAUTHORIZED_WHATSAPP_MSG,
                        source="WHATSAPP",
                    )
                except Exception as exc:
                    logger.warning("Envoi message refus echoue pour %s: %s", chat_jid, exc)
            return

        if not settings.whatsapp_auto_reply_enabled:
            return

        async with self._ai_sem:
            await self._reply_with_retries(
                client,
                evt,
                chat,
                chat_jid,
                user_text,
                input_type,
                content,
                mime,
            )

    async def _reply_with_retries(
        self,
        client: Any,
        evt: Any,
        chat: Any,
        chat_jid: str,
        user_text: str,
        input_type: str,
        content: str | None,
        mime: str | None,
    ) -> None:
       
        last_exc: Exception | None = None
        for attempt in range(1, _AI_RETRIES + 1):
            try:
                reply = await generate_whatsapp_reply(
                    user_text,
                    chat_jid,
                    input_type=input_type,  # type: ignore[arg-type]
                    content=content,
                    content_mime_type=mime,
                    user_prompt=user_text if input_type != "text" else None,
                )
                if not self._client_live(client):
                    logger.warning("Client deconnecte avant envoi reponse a %s", chat_jid)
                    return
                await client.reply_message(reply, evt, to=chat)
                save_message(
                    chat_jid=chat_jid,
                    direction="out",
                    body=reply,
                    source="WHATSAPP",
                )
                logger.info("Reponse auto envoyee a %s", chat_jid)
                return
            except (httpx.TimeoutException, httpx.ConnectTimeout, httpx.ReadTimeout) as exc:
                last_exc = exc
                logger.warning("IA timeout (tentative %s/%s): %s", attempt, _AI_RETRIES, exc)
            except Exception as exc:
                last_exc = exc
                logger.warning("IA erreur (tentative %s/%s): %s", attempt, _AI_RETRIES, exc)
            if attempt < _AI_RETRIES:
                await asyncio.sleep(_AI_RETRY_DELAY_S * attempt)

        fallback = (
            "Desole, je suis momentanement surcharge. "
            "Renvoyez votre message dans quelques secondes."
        )
        try:
            if self._client_live(client):
                await client.reply_message(fallback, evt, to=chat)
                save_message(
                    chat_jid=chat_jid,
                    direction="out",
                    body=fallback,
                    source="WHATSAPP",
                )
        except Exception as exc:
            logger.exception("Envoi message secours echoue: %s (cause: %s)", exc, last_exc)


_bot_manager: WhatsAppBotManager | None = None


def get_whatsapp_bot() -> WhatsAppBotManager:
    global _bot_manager
    if _bot_manager is None:
        _bot_manager = WhatsAppBotManager()
    return _bot_manager


async def get_enhanced_status() -> dict[str, Any]:
    settings = get_settings()
    base = get_whatsapp_status()
    driver = effective_driver()
    meta_ok = is_cloud_configured()
    show_admin = settings.whatsapp_show_admin

    if driver == "neonize":
        bot = get_whatsapp_bot()
        st = bot.state.value
        connected = bot.is_connected()
        if connected and bot.state != ConnectionState.CONNECTED:
            bot._mark_connected()
        user_action = (
            "1. Scannez le QR code avec votre WhatsApp.\n"
            "2. La conversation avec +212 689 461 643 s'ouvre.\n"
            "3. Envoyez un message — l'assistant IA répond dans le chat."
        )
        saved = session_exists()
        if connected:
            display = "Assistant actif"
        elif st == "connecting" and saved:
            display = "Synchronisation WhatsApp (session enregistree)"
        elif st == "qr_pending" and saved:
            display = "Reconnexion en cours…"
        elif st == "qr_pending":
            display = "Premier scan QR serveur requis (admin, une fois)"
        elif st == "connecting":
            display = "Connexion en cours…"
        elif st == "error":
            display = bot.error or "Erreur session — reinitialisez via /?admin=1"
        else:
            display = "Serveur en cours de démarrage"
        return {
            "phone": base.phone,
            "display": display,
            "wa_link": base.wa_link,
            "connection_state": st,
            "connected": connected,
            "auto_reply_enabled": settings.whatsapp_auto_reply_enabled and connected,
            "driver": "neonize",
            "error": bot.error,
            "needs_business_setup": not connected,
            "meta_configured": False,
            "show_admin_panel": show_admin,
            "session_saved": saved,
            "user_action": user_action,
        }

    return {
        "phone": base.phone,
        "display": "Assistant WhatsApp +212 689 461 643",
        "wa_link": base.wa_link,
        "connection_state": "ready" if meta_ok else "pending",
        "connected": meta_ok,
        "auto_reply_enabled": settings.whatsapp_auto_reply_enabled and meta_ok,
        "driver": "cloud",
        "error": None,
        "needs_business_setup": False,
        "meta_configured": meta_ok,
        "show_admin_panel": show_admin,
        "user_action": (
            "1. Scannez le QR code avec votre WhatsApp.\n"
            "2. La conversation avec +212 689 461 643 s'ouvre.\n"
            "3. Envoyez un message — l'assistant IA répond dans le chat."
        ),
    }
