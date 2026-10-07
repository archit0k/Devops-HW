FROM python:3.14-slim-trixie
WORKDIR /app
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10001 studyslot && useradd --uid 10001 --gid studyslot --create-home studyslot
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt
COPY --chown=studyslot:studyslot app ./app
COPY --chown=studyslot:studyslot alembic ./alembic
COPY --chown=studyslot:studyslot alembic.ini ./
USER 10001:10001
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
