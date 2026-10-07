from flask import Flask, jsonify, request

app = Flask(__name__)


@app.get("/health")
def health():
    return jsonify(status="ok", student="Archit Kulkarni", roll_no="24BCS10194")


@app.get("/")
def home():
    return "<h1>Hello from Archit's DevSecOps lab</h1><p>24BCS10194 · Section A</p>"


@app.get("/api/greet/<name>")
def greet(name):
    return jsonify(message=f"Hello, {name}!")


@app.post("/api/add")
def add():
    data = request.get_json(silent=True) or {}
    a, b = data.get("a"), data.get("b")
    if type(a) not in (int, float) or type(b) not in (int, float):
        return jsonify(error="a and b must be numbers"), 400
    return jsonify(result=a + b)
