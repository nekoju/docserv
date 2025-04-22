#!/usr/bin/env python3
from flask import Flask, request, abort, Response
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
BASE_DIR = os.environ.get("DOC_PATH", "test")
DOC_TOKEN = os.environ.get("DOC_TOKEN", "changeme")

def check_auth():
    auth = request.authorization
    if not auth or auth.username != DOC_TOKEN:
        abort(401, "Unauthorized")

@app.route("/doc/<path:filename>", methods=["GET", "POST"])
def doc_handler(filename):
    check_auth()
    full_path = os.path.join(BASE_DIR, filename)

    if request.method == "GET":
        if os.path.isfile(full_path):
            with open(full_path, "r", encoding="utf-8") as f:
                return Response(f.read(), mimetype="text/plain")
        else:
            abort(404, "File not found")

    elif request.method == "POST":
        content = request.get_data(as_text=True)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        with open(full_path, "w", encoding="utf-8") as f:
            f.write(content)
        return Response("OK", mimetype="text/plain")

@app.route("/list", methods=["GET"])
def list_docs():
    files = []
    for root, _, filenames in os.walk(BASE_DIR):
        for name in filenames:
            rel_path = os.path.relpath(os.path.join(root, name), BASE_DIR)
            files.append(rel_path)
    return Response("\n".join(files) + "\n", mimetype="text/plain")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

