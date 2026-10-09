from __future__ import annotations

import sqlite3
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Literal

from app.config.settings import get_settings

MessageSource = Literal["WHATSAPP", "PLATFORM"]


def _db_path() -> Path:
    settings = get_settings()
    p = Path(settings.whatsapp_history_db)
    if not p.is_absolute():
        p = Path(__file__).resolve().parent.parent.parent / p
    p.parent.mkdir(parents=True, exist_ok=True)
    return p


@contextmanager
def _conn():
    conn = sqlite3.connect(str(_db_path()), check_same_thread=False)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
        conn.commit()
    finally:
        conn.close()


def _migrate_schema(conn: sqlite3.Connection) -> None:
    cols = {row[1] for row in conn.execute("PRAGMA table_info(wa_messages)").fetchall()}
    if "source" not in cols:
        conn.execute("ALTER TABLE wa_messages ADD COLUMN source TEXT DEFAULT 'WHATSAPP'")


def init_db() -> None:
    with _conn() as conn:
        conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS wa_messages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                chat_jid TEXT NOT NULL,
                sender_jid TEXT,
                push_name TEXT,
                direction TEXT NOT NULL,
                body TEXT,
                media_type TEXT,
                wa_message_id TEXT,
                source TEXT DEFAULT 'WHATSAPP',
                created_at TEXT NOT NULL
            );
            CREATE INDEX IF NOT EXISTS idx_wa_messages_chat ON wa_messages(chat_jid, created_at DESC);

            CREATE TABLE IF NOT EXISTS wa_conversations (
                chat_jid TEXT PRIMARY KEY,
                user_id INTEGER,
                push_name TEXT,
                last_message_at TEXT,
                message_count INTEGER DEFAULT 0
            );
            """
        )
        _migrate_schema(conn)


def upsert_conversation(chat_jid: str, push_name: str | None = None, user_id: int | None = None) -> None:
    now = datetime.now(timezone.utc).isoformat()
    with _conn() as conn:
        conn.execute(
            """
            INSERT INTO wa_conversations (chat_jid, push_name, user_id, last_message_at, message_count)
            VALUES (?, ?, ?, ?, 1)
            ON CONFLICT(chat_jid) DO UPDATE SET
                push_name = COALESCE(excluded.push_name, wa_conversations.push_name),
                user_id = COALESCE(excluded.user_id, wa_conversations.user_id),
                last_message_at = excluded.last_message_at,
                message_count = wa_conversations.message_count + 1
            """,
            (chat_jid, push_name, user_id, now),
        )


def save_message(
    *,
    chat_jid: str,
    direction: str,
    body: str,
    source: MessageSource = "WHATSAPP",
    user_id: int | None = None,
    sender_jid: str | None = None,
    push_name: str | None = None,
    media_type: str | None = None,
    wa_message_id: str | None = None,
) -> int:
    now = datetime.now(timezone.utc).isoformat()
    upsert_conversation(chat_jid, push_name, user_id)

    with _conn() as conn:
        cur = conn.execute(
            """
            INSERT INTO wa_messages
            (user_id, chat_jid, sender_jid, push_name, direction, body, media_type, wa_message_id, source, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (user_id, chat_jid, sender_jid, push_name, direction, body, media_type, wa_message_id, source, now),
        )
        return int(cur.lastrowid)


def list_conversations(limit: int = 50) -> list[dict[str, Any]]:
    with _conn() as conn:
        rows = conn.execute(
            """
            SELECT chat_jid, user_id, push_name, last_message_at, message_count
            FROM wa_conversations
            ORDER BY last_message_at DESC
            LIMIT ?
            """,
            (limit,),
        ).fetchall()
    return [dict(r) for r in rows]


def list_messages(chat_jid: str | None = None, limit: int = 100) -> list[dict[str, Any]]:
    with _conn() as conn:
        if chat_jid:
            rows = conn.execute(
                """
                SELECT id, user_id, chat_jid, sender_jid, push_name, direction, body,
                       media_type, wa_message_id, source, created_at
                FROM wa_messages WHERE chat_jid = ?
                ORDER BY id DESC LIMIT ?
                """,
                (chat_jid, limit),
            ).fetchall()
        else:
            rows = conn.execute(
                """
                SELECT id, user_id, chat_jid, sender_jid, push_name, direction, body,
                       media_type, wa_message_id, source, created_at
                FROM wa_messages
                ORDER BY id DESC LIMIT ?
                """,
                (limit,),
            ).fetchall()
    return [dict(r) for r in rows]


def recent_context(chat_jid: str, limit: int = 10) -> list[dict[str, str]]:
    """Historique recent pour un fil (ex. ``212...@s.whatsapp.net`` ou ``UI_45``)."""
    rows = list_messages(chat_jid=chat_jid, limit=limit)
    rows.reverse()
    return [
        {"role": "assistant" if r["direction"] == "out" else "user", "content": r["body"] or ""}
        for r in rows
        if r["body"]
    ]
