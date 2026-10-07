FROM python:3.14-alpine
WORKDIR /app
RUN apk upgrade --no-cache \
    && addgroup -g 10001 studyslot && adduser -D -u 10001 -G studyslot studyslot
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt \
    && pip uninstall -y pip setuptools wheel
COPY --chown=studyslot:studyslot app ./app
COPY --chown=studyslot:studyslot alembic ./alembic
COPY --chown=studyslot:studyslot alembic.ini ./
USER 10001:10001
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
