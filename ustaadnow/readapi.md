# UstaadNow-AI
UstaadNow AI is an agentic mobile service-booking prototype for Pakistan’s informal economy, transforming Urdu, Roman Urdu, and English service requests into provider matching, AI ranking, simulated booking, follow-up reminders, and traceable workflow logs.


# API Endpoints — UstaadNow Service Orchestrator

Base URL: `http://localhost:8000`
Swagger UI: `http://localhost:8000/docs`

---

## POST `/api/request`
**Purpose:** Submit a text-based service request and run the full 5-agent pipeline.

**Request:**
```json
{ "input": "Mujhe kal subah G-13 mein AC technician chahiye" }
```

**Returns:** Full `AgentState` — detected intent, matched provider, booking confirmation, follow-up notifications, and agent trace logs.

---

## POST `/api/request/audio`
**Purpose:** Submit an audio file — faster-whisper transcribes it and detects language (Urdu / Roman Urdu / English), then runs the same pipeline.

**Request:** `multipart/form-data` with field `file` (WAV, MP3, M4A, etc.)

**Returns:** Same as `/api/request` plus `whisper_transcript` and `whisper_language` fields.

---

## GET `/api/bookings`
**Purpose:** Retrieve all confirmed bookings saved to `data/bookings.json`.

**Returns:**
```json
[
  {
    "booking_id": "BK-343403",
    "provider_name": "Ali AC Services",
    "service_type": "AC Technician",
    "location": "G-13",
    "slot_time": "Tomorrow, 10:00 AM",
    "status": "CONFIRMED"
  }
]
```

---

## GET `/api/trace/{booking_id}`
**Purpose:** Get the full agent log trace for a specific booking — useful for debugging and LangSmith-style observability.

**Example:** `GET /api/trace/BK-343403`

**Returns:**
```json
{
  "booking_id": "BK-343403",
  "agent_logs": [
    { "agent": "intent_agent",    "status": "success", "output_summary": "service=AC Technician, location=G-13" },
    { "agent": "discovery_agent", "status": "success", "output_summary": "Found 4 providers via mock DB" },
    { "agent": "matching_agent",  "status": "success", "output_summary": "Selected: Ali AC Services (score=0.98)" }
  ]
}
```

Returns `404` if booking ID not found.

---

## GET `/api/health`
**Purpose:** Quick health check to confirm the server is running.

**Returns:**
```json
{ "status": "ok" }
```

---

## Summary Table

| Method | Endpoint | Input | Key Output |
|---|---|---|---|
| POST | `/api/request` | `{ "input": "..." }` | Booking + agent trace |
| POST | `/api/request/audio` | Audio file (multipart) | Transcript + booking + agent trace |
| GET | `/api/bookings` | — | All saved bookings |
| GET | `/api/trace/{id}` | Booking ID in URL | Per-agent log entries |
| GET | `/api/health` | — | `{ "status": "ok" }` |
