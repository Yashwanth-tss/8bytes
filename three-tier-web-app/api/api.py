from flask import Flask, jsonify, request, g
import os
import psycopg2

api = Flask(__name__)

# PostgreSQL configurations
DB_HOST = os.getenv("DB_HOST", "db")
DB_USER = os.getenv("DB_USER", "user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "password")
DB_NAME = os.getenv("DB_NAME", "quotesdb")
DB_PORT = os.getenv("DB_PORT", "5432")


def get_db():
    if "db" not in g:
        g.db = psycopg2.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            port=DB_PORT,
        )
    return g.db


@api.teardown_appcontext
def close_db(e=None):
    db = g.pop("db", None)
    if db is not None:
        db.close()


@api.route("/api/quotes", methods=["GET"])
def get_quotes():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, quote, author FROM quotes")
    quotes = cursor.fetchall()
    cursor.close()
    return jsonify([{"id": q[0], "quote": q[1], "author": q[2]} for q in quotes])


@api.route("/health", methods=["GET"])
def health():
    return "OK", 200


@api.route("/api/quotes", methods=["POST"])
def add_quote():
    content = request.json["quote"]
    author = request.json["author"]
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO quotes (quote, author) VALUES (%s, %s) RETURNING id",
        (content, author),
    )
    quote_id = cursor.fetchone()[0]
    conn.commit()
    cursor.close()
    return jsonify({"id": quote_id, "quote": content, "author": author}), 201

    
@api.route("/api/getquotes", methods=["GET"])
def get_quote():
    author = request.json["author"]
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT quote, author FROM quotes WHERE author=%s)",
        (author), 
    )
    quotes = cursor.fetchall()
    cursor.close()
    return jsonify([{"id": q[0], "quote": q[1], "author": q[2]} for q in quotes]), 200


if __name__ == "__main__":
    # Use the PORT environment variable provided by Beanstalk, defaulting to 5001 for local development
    port = int(os.environ.get("PORT", 5001))
    api.run(host="0.0.0.0", port=port)
