from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse

from .config import settings
from .db import ping_db
from .routers import chat, vision, sync

app = FastAPI(
    title="AI Sport Assistant API",
    description="Бекенд AI спортивного асистента: Claude (tool use) + food vision + синхронізація.",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat.router)
app.include_router(vision.router)
app.include_router(sync.router)


@app.get("/", include_in_schema=False)
def root() -> RedirectResponse:
    return RedirectResponse(url="/docs")


@app.get("/health", tags=["meta"])
def health() -> dict:
    return {
        "status": "ok",
        "model": settings.claude_model,
        "db": "ok" if ping_db() else "down",
    }
