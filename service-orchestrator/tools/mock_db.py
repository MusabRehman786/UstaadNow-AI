
import sqlite3
import json
from datetime import datetime, timedelta

DB_PATH = "ustaadnow.db"


# Session context expires after this many minutes of inactivity
SESSION_TTL_MINUTES = 30


def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

# ── Pricing ───────────────────────────────────────────────────────────────────

SERVICE_BASE_RATES = {
    "AC Technician":  {"min": 1500, "max": 3000, "unit": "per visit"},
    "Plumber":        {"min": 800,  "max": 2000, "unit": "per visit"},
    "Electrician":    {"min": 1000, "max": 2500, "unit": "per visit"},
    "Home Tutor":     {"min": 500,  "max": 1500, "unit": "per hour"},
    "Beautician":     {"min": 2000, "max": 5000, "unit": "per session"},
    "Carpenter":      {"min": 1500, "max": 4000, "unit": "per visit"},
    "Painter":        {"min": 800,  "max": 1500, "unit": "per day"},
    "CCTV Installer": {"min": 3000, "max": 8000, "unit": "per visit"},
}


def _seed_pricing(cursor):
    """Insert base rates only if the table is empty."""
    count = cursor.execute("SELECT COUNT(*) FROM service_pricing").fetchone()[0]
    if count > 0:
        return
    for service, data in SERVICE_BASE_RATES.items():
        cursor.execute(
            "INSERT INTO service_pricing (service_type, min_price, max_price, unit) VALUES (?, ?, ?, ?)",
            (service, data["min"], data["max"], data["unit"]),
        )
    print("🌱 Seeded service_pricing table")


def get_price_estimate(service_type: str, rating: float = 4.0) -> dict:
    """
    Fetch base rate from DB, apply a small rating multiplier.
    Higher-rated providers charge up to 20% more.
    Falls back to a generic estimate if service not found.
    """
    conn = get_connection()
    row = conn.execute(
        "SELECT min_price, max_price, unit FROM service_pricing WHERE service_type = ?",
        (service_type,)
    ).fetchone()
    conn.close()

    if not row:
        # Generic fallback
        row = {"min_price": 1000, "max_price": 3000, "unit": "per visit"}

    multiplier = 1.0 + max(0.0, (rating - 3.0) / 10.0)   # 0% to 20% premium
    min_p = int(row["min_price"] * multiplier)
    max_p = int(row["max_price"] * multiplier)
    unit  = row["unit"]

    return {
        "min":      min_p,
        "max":      max_p,
        "unit":     unit,
        "currency": "PKR",
        "display":  f"PKR {min_p:,} – {max_p:,} / {unit}",
    }
# def init_db():
#     conn = get_connection()
#     cursor = conn.cursor()

#     cursor.execute("""
#         CREATE TABLE IF NOT EXISTS bookings (
#             id INTEGER PRIMARY KEY AUTOINCREMENT,
#             booking_id TEXT UNIQUE,
#             data TEXT,
#             created_at TEXT
#         )
#     """)

#     cursor.execute("""
#         CREATE TABLE IF NOT EXISTS session_context (
#             session_id TEXT PRIMARY KEY,
#             raw_input TEXT,
#             service_type TEXT,
#             location TEXT,
#             time_preference TEXT,
#             language_detected TEXT,
#             turn_count INTEGER DEFAULT 1,
#             updated_at TEXT
#         )
#     """)
#     conn.commit()
#     conn.close()


def init_db():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS bookings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            booking_id TEXT UNIQUE,
            data TEXT,
            created_at TEXT
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS session_context (
            session_id TEXT PRIMARY KEY,
            raw_input TEXT,
            service_type TEXT,
            location TEXT,
            time_preference TEXT,
            language_detected TEXT,
            turn_count INTEGER DEFAULT 1,
            updated_at TEXT
        )
    """)

    # ── NEW ──────────────────────────────────────────────────────────────────
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS service_pricing (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            service_type TEXT UNIQUE NOT NULL,
            min_price    INTEGER NOT NULL,
            max_price    INTEGER NOT NULL,
            unit         TEXT NOT NULL DEFAULT 'per visit'
        )
    """)
    _seed_pricing(cursor)
    # ─────────────────────────────────────────────────────────────────────────

    conn.commit()
    conn.close()


# Run schema setup at import time so callers never hit "no such table"
init_db()


def save_session_context(session_id: str, state: dict):
    """Save or update session context. Only overwrites fields with non-None values."""
    conn = get_connection()

    # Read existing turn_count if present, increment it
    existing = conn.execute(
        "SELECT turn_count FROM session_context WHERE session_id = ?", (session_id,)
    ).fetchone()
    turn_count = (existing["turn_count"] + 1) if existing else 1

    conn.execute("""
        INSERT INTO session_context
            (session_id, raw_input, service_type, location, time_preference,
             language_detected, turn_count, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(session_id) DO UPDATE SET
            raw_input         = COALESCE(excluded.raw_input,         session_context.raw_input),
            service_type      = COALESCE(excluded.service_type,      session_context.service_type),
            location          = COALESCE(excluded.location,          session_context.location),
            time_preference   = COALESCE(excluded.time_preference,   session_context.time_preference),
            language_detected = COALESCE(excluded.language_detected, session_context.language_detected),
            turn_count        = excluded.turn_count,
            updated_at        = excluded.updated_at
    """, (
        session_id,
        state.get("raw_input"),
        state.get("service_type"),
        state.get("location"),
        state.get("time_preference"),
        state.get("language_detected"),
        turn_count,
        datetime.now().isoformat(),
    ))
    conn.commit()
    conn.close()
    print(f"💾 Saved session {session_id}  turn={turn_count}  slots={ {k: state.get(k) for k in ['service_type','location','time_preference']} }")


def get_session_context(session_id: str) -> dict | None:
    """Fetch session context. Returns None if not found or expired."""
    conn = get_connection()
    row = conn.execute(
        "SELECT * FROM session_context WHERE session_id = ?", (session_id,)
    ).fetchone()
    conn.close()

    if not row:
        return None

    # TTL check — drop stale sessions
    try:
        last_updated = datetime.fromisoformat(row["updated_at"])
        age = datetime.now() - last_updated
        if age > timedelta(minutes=SESSION_TTL_MINUTES):
            print(f"⏰ Session {session_id} expired ({age.total_seconds()/60:.1f}min old) — clearing.")
            delete_session_context(session_id)
            return None
    except (TypeError, ValueError):
        pass

    return dict(row)


def delete_session_context(session_id: str):
    conn = get_connection()
    conn.execute("DELETE FROM session_context WHERE session_id = ?", (session_id,))
    conn.commit()
    conn.close()


def cleanup_expired_sessions():
    """Optional housekeeping — can be called periodically."""
    cutoff = (datetime.now() - timedelta(minutes=SESSION_TTL_MINUTES)).isoformat()
    conn = get_connection()
    cursor = conn.execute("DELETE FROM session_context WHERE updated_at < ?", (cutoff,))
    deleted = cursor.rowcount
    conn.commit()
    conn.close()
    if deleted:
        print(f"🧹 Cleaned up {deleted} expired session(s)")
    return deleted


def get_all_bookings() -> list:
    conn = get_connection()
    rows = conn.execute(
        "SELECT data FROM bookings ORDER BY created_at DESC"
    ).fetchall()
    conn.close()
    return [json.loads(row["data"]) for row in rows]


def save_booking(booking: dict):
    conn = get_connection()
    conn.execute(
        "INSERT OR REPLACE INTO bookings (booking_id, data, created_at) VALUES (?, ?, ?)",
        (booking["booking_id"], json.dumps(booking), booking["created_at"]),
    )
    conn.commit()
    conn.close()