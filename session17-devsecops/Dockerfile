FROM python:3.14-alpine
WORKDIR /app
RUN apk upgrade --no-cache && adduser -D -u 10001 homework
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt \
    && pip uninstall -y pip setuptools wheel
COPY app.py .
USER 10001
EXPOSE 5000
CMD ["flask", "--app", "app", "run", "--host=0.0.0.0", "--port=5000"]
