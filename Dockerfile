# ── Stage 1: Build dependencies ──
FROM python:3.12-slim AS builder

WORKDIR /build
COPY backend/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: Production image ──
FROM python:3.12-slim

LABEL maintainer="thinht7113"
LABEL description="Score Management Backend API"

# Copy installed packages from builder
COPY --from=builder /install /usr/local

WORKDIR /app

# Copy backend source code
COPY backend/ ./backend/

# Create a volume mount point for the SQLite database
# so data persists across container restarts
VOLUME ["/app/backend/data"]

# Expose the API port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/healthz')" || exit 1

# Environment variables (can be overridden at runtime)
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1

# Entry point: use gunicorn for production
CMD ["gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "2", \
     "--timeout", "120", \
     "--access-logfile", "-", \
     "backend.app:create_app()"]
