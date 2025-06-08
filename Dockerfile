# Multi-stage build for production optimization
FROM python:3.9-slim as base

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # FreeCAD and dependencies
    freecad-python3 \
    python3-freecad \
    # System utilities
    file \
    wget \
    curl \
    # Cleanup to reduce image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Set working directory
WORKDIR /app

# Create necessary directories
RUN mkdir -p temp uploads outputs logs \
    && chown -R appuser:appuser /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/
COPY freecad_scripts/ ./freecad_scripts/

# Copy configuration files
COPY .env* ./

# Set proper permissions
RUN chown -R appuser:appuser /app \
    && chmod +x /app

# Switch to non-root user
USER appuser

# Configure FreeCAD environment
ENV FREECAD_USER_HOME=/app \
    FREECAD_USER_DATA=/app/.FreeCAD \
    PYTHONPATH="/usr/lib/freecad-python3/lib:${PYTHONPATH}"

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Expose port
EXPOSE 8000

# Default command
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]

# Production stage
FROM base as production

# Additional optimizations for production
ENV ENVIRONMENT=production

# Copy additional production configs if needed
# COPY production.env .env

# Override CMD for production with more workers if needed
# CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]

# Development stage
FROM base as development

# Install development dependencies
RUN pip install --no-cache-dir pytest pytest-asyncio pytest-cov black isort mypy

# Override for development with reload
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
