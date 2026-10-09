from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import FileResponse, ORJSONResponse, Response
from fastapi.staticfiles import StaticFiles
from slowapi import Limiter
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from slowapi.util import get_remote_address

from app.config.settings import get_settings
from app.middleware.logging_middleware import RequestLoggingMiddleware
from app.routers import ai as ai_router
from app.routers import health as health_router
from app.routers import metrics as metrics_router
from app.routers import openrouter_models as openrouter_models_router
from app.routers import platform as platform_router
from app.routers import whatsapp_meta as whatsapp_meta_router
from app.utils.errors import app_error_handler, http_exception_handler, rate_limit_handler, retry_error_handler, retry_error_handler
from app.utils.logging import configure_logging
from app.routers import notifications as notifications_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    configure_logging(settings.service_log_level)
    kb_dir = Path(settings.knowledge_base_dir)
    if not kb_dir.is_absolute():
        kb_dir = Path(__file__).resolve().parent.parent / kb_dir
    kb_dir.mkdir(parents=True, exist_ok=True)

    from app.services.whatsapp_history import init_db
    from app.services.whatsapp_bot_manager import get_whatsapp_bot
    from app.services.whatsapp_runtime import effective_driver, should_start_neonize_bot

    init_db()
    wa_bot = get_whatsapp_bot()
    use_neonize = should_start_neonize_bot()
    if use_neonize:
        from app.services.whatsapp_session_store import get_session_db_path, session_exists

        if session_exists():
            logging.getLogger(__name__).info(
                "WhatsApp neonize — reprise session (%s), pas de nouveau QR",
                get_session_db_path().name,
            )
        else:
            logging.getLogger(__name__).info(
                "WhatsApp neonize — premier demarrage, QR admin requis une fois"
            )
        await wa_bot.start()
    else:
        logging.getLogger(__name__).info("WhatsApp Cloud API - webhook /v1/whatsapp/meta/webhook")

    logging.getLogger(__name__).info("Starting %s (%s)", settings.service_name, settings.service_env)
    logging.getLogger(__name__).info("Knowledge base: %s", kb_dir)
    yield
    if use_neonize:
        await wa_bot.stop()
    logging.getLogger(__name__).info("Shutting down %s", settings.service_name)


def create_app() -> FastAPI:
    settings = get_settings()

    limiter = Limiter(key_func=get_remote_address, default_limits=[settings.service_rate_limit])

    app = FastAPI(
        title=settings.service_name,
        version="1.0.0",
        default_response_class=ORJSONResponse,
        lifespan=lifespan,
    )

    app.state.limiter = limiter
    app.add_middleware(SlowAPIMiddleware)
    app.add_middleware(RequestLoggingMiddleware)

    from tenacity import RetryError

    from app.utils.exceptions import AppError

    app.add_exception_handler(RateLimitExceeded, rate_limit_handler)
    app.add_exception_handler(RetryError, retry_error_handler)
    app.add_exception_handler(AppError, app_error_handler)
    app.add_exception_handler(Exception, http_exception_handler)

    static_dir = Path(__file__).resolve().parent.parent / "static"
    if static_dir.is_dir():
        app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")

        @app.get("/", include_in_schema=False)
        def index() -> FileResponse:
            return FileResponse(static_dir / "index.html")

    @app.get("/favicon.ico", include_in_schema=False)
    def favicon() -> Response:
        return Response(status_code=204)

    app.include_router(health_router.router)
    app.include_router(metrics_router.router)
    app.include_router(openrouter_models_router.router)
    app.include_router(ai_router.router)
    app.include_router(platform_router.router)
    app.include_router(notifications_router.router)
    
    from app.services.whatsapp_runtime import effective_driver

    if effective_driver() == "cloud":
        app.include_router(whatsapp_meta_router.router)

    return app


app = create_app()

