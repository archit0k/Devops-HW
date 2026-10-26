FROM python:3.14-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
COPY app/ ./app/
USER 10001:10001
CMD ["python", "-c", "from app.calculator import add, subtract, multiply, divide; print('Archit Kulkarni | 24BCS10194'); print('10 + 5 =', add(10, 5)); print('10 - 5 =', subtract(10, 5)); print('10 * 5 =', multiply(10, 5)); print('10 / 5 =', divide(10, 5))"]
