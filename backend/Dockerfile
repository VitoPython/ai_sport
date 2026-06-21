# ───── AI Sport Assistant API ─────
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Залежності окремим шаром — кешуються, доки requirements.txt не змінився.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Код застосунку.
COPY app ./app

# Непривілейований користувач (безпека).
RUN useradd --create-home --uid 10001 appuser
USER appuser

EXPOSE 8000

# Health-check без зовнішніх залежностей (без curl).
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/health').status==200 else 1)"

# 1 worker: тимчасове сховище у пам'яті (store.py) одне на процес.
# Після переходу на Postgres (Фаза 2) можна підняти кількість воркерів.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
