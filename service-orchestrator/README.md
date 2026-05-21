# UstaadNow AI — Agentic Service Orchestrator

> AI-powered service booking platform for Pakistan's informal economy — built with LangGraph, LangChain, faster-whisper, and FastAPI.

---

## Table of Contents

1. [Problem Statement](#problem-statement)
2. [Solution Overview](#solution-overview)
3. [System Architecture](#system-architecture)
4. [Tech Stack](#tech-stack)
5. [Agents Developed](#agents-developed)
6. [Mock and Real APIs Used](#mock-and-real-apis-used)
7. [Integrations Implemented](#integrations-implemented)
8. [Pricing Mechanism](#pricing-mechanism)
9. [Project Structure](#project-structure)
10. [Agentic Pipeline (LangGraph)](#agentic-pipeline-langgraph)
11. [API Endpoints](#api-endpoints)
12. [Multi-turn Conversations](#multi-turn-conversations-session-context)
13. [Quick Start](#quick-start)
14. [Environment Variables](#environment-variables)
15. [Demo Walkthrough](#demo-walkthrough)
16. [Future Roadmap](#future-roadmap)

---

## Problem Statement

Millions of skilled workers in Pakistan's informal economy — plumbers, electricians, AC technicians, carpenters, tutors, beauticians — are discovered almost exclusively through word-of-mouth or WhatsApp. There is no structured, reliable way for customers to find, compare, and book these providers, and providers have no fair, transparent way to price their work against market demand.

UstaadNow AI fixes both sides of this problem:

- **For users** — describe what you need in **Urdu, Roman Urdu, or English** (text or voice). Agents extract intent, find the best provider, estimate the price, and book — end-to-end. Once the booking is confirmed, you can call the provider directly on their provided phone number.
- **For providers** — get matched fairly and receive structured job leads with location + time + price already negotiated.

---

## Solution Overview

UstaadNow AI is a **multi-agent orchestrator** built on LangGraph. A single shared `AgentState` flows through 5 specialized agents:

| Agent | Responsibility |
|---|---|
| **Intent Agent** | Extract `service_type`, `location`, `time_preference`, `language` from free-form Urdu / Roman Urdu / English input via LLM structured output. |
| **Discovery Agent** | Geocode the user's location, search Google Places (or fall back to a mock SQLite DB), compute haversine distance to each provider. |
| **Matching Agent** | Score and rank providers using a weighted formula (rating + proximity + availability), pick the best, generate human-readable LLM reasoning. |
| **Booking Agent** | LLM-resolve the user's vague time expression ("kal subah", "8 baje raat") into a concrete slot, create a `BK-XXXXXX` ID, persist to SQLite, build a localized confirmation. |
| **Follow-up Agent** | If required slots are missing → ask the user a natural follow-up question in their language. If booking exists → schedule simulated SMS notifications and reminders. |

Every node is `@traceable` to LangSmith for end-to-end observability.

---

## System Architecture

```
                Voice / Text Input  (Urdu / Roman Urdu / English)
                            │
              ┌─────────────┴──────────────┐
              ▼                            ▼
     POST /api/request            POST /api/request/audio
        (text JSON)             (audio + lang="ur"|"en")
                                          │
                                          ▼
                         faster-whisper large-v3-turbo
                         + ffmpeg preprocessing (16kHz mono,
                           highpass, loudnorm) + hallucination
                           filter + VAD
                                          │
                                          ▼
              ┌─────── LangGraph StateGraph Orchestrator ────────┐
              │                                                   │
              │   ┌──────────────┐   ┌─────────────────┐         │
              │   │ Intent Agent │──▶│ Discovery Agent │──┐      │
              │   └──────────────┘   └─────────────────┘  │      │
              │          │                                ▼      │
              │     [no service]                  ┌──────────────┐│
              │          ▼                         │ Matching     ││
              │   ┌──────────────┐                 │ Agent        ││
              │   │ Error Node   │                 └──────┬───────┘│
              │   └──────────────┘                        │        │
              │                                           ▼        │
              │                                  [all slots filled]│
              │                                ┌──────────┴──────┐ │
              │                                ▼                 ▼ │
              │                       ┌──────────────┐  ┌──────────┴┐
              │                       │ Booking      │  │ Follow-up │
              │                       │ Agent        │  │ (ask Qs)  │
              │                       └──────┬───────┘  └───────────┘
              │                              ▼                       │
              │                       ┌──────────────┐               │
              │                       │ Follow-up    │               │
              │                       │ (notify)     │               │
              │                       └──────────────┘               │
              └────────────────────────────────────────────────────┘
                                          │
                                          ▼
                       SQLite (bookings + session_context)
                                          │
                                          ▼
                            LangSmith Trace Dashboard
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Orchestration | **LangGraph** `StateGraph` with conditional edges |
| LLM Chains | **LangChain** + **Azure OpenAI** (gpt-4o-mini) with `.with_structured_output()` |
| Speech-to-Text | **faster-whisper** `large-v3-turbo` + **ffmpeg** preprocessing + VAD |
| Observability | **LangSmith** (`@traceable` on every agent + the pipeline) |
| API Server | **FastAPI** + **Uvicorn** |
| Provider Discovery | **Google Places API (New)** + mock SQLite fallback |
| Storage | **SQLite** (bookings + multi-turn session context with TTL) |
| Validation | **Pydantic** v2 models + `TypedDict` AgentState |
| Audio Formats | WAV, MP3, OGG, FLAC, M4A, WebM |
| Languages | Urdu (`اردو`), Roman Urdu, English |

---

## Agents Developed

### 1. Intent Agent — `agents/intent_agent.py`

Uses Azure OpenAI's native structured-output mode to parse free-form Urdu / Roman Urdu / English into a Pydantic `IntentOutput`:

Honours pre-set language (from the audio endpoint's `lang` form field) as authoritative.

### 2. Discovery Agent — `agents/discovery_agent.py`

- Searches providers via **Google Places API (New)** `places:searchText`.
- Falls back to the mock SQLite DB if Places is unavailable.
- Computes the **haversine distance** from user → each provider.
- Returns the top 10 sorted by proximity.

### 3. Matching Agent — `agents/matching_agent.py`

Weighted scoring formula for selecting the best provider:
```
score = (rating/5.0) * 0.4 + (1 - min(distance_km, 10)/10) * 0.4 + (0.2 if available else 0.0)
```
The top-ranked provider is passed back to an LLM that produces a 1–2 sentence human-readable explanation (`reasoning`).

### 4. Booking Agent — `agents/booking_agent.py`

Uses Azure OpenAI structured output (`SlotResolution`) to resolve vague time expressions:

- `"kal subah"` → `day=tomorrow, time=10:00 AM, user_was_specific=False`
- `"abhi"` → `day=today, time=(soonest in-window), user_was_specific=False`

Generates a `BK-XXXXXX` booking ID, builds a fully localized confirmation message in the user's language, and persists to SQLite. Once the booking is confirmed, the customer can easily call the provider on their designated phone number to coordinate further.

### 5. Follow-up Agent — `agents/followup_agent.py`

Two paths:

| Path | Trigger | Action |
|---|---|---|
| Missing-slots path | Required fields absent, no booking yet | LLM generates a natural one-sentence follow-up question **strictly in the user's language**. Falls back to a hand-curated question table for each (language × missing-fields) combination if the LLM fails. |
| Notifications path | Booking exists | Schedules 3 simulated notifications (customer SMS, provider SMS, reminder). |

---

## Mock and Real APIs Used

| API | Mode | Purpose |
|---|---|---|
| **Google Places API (New)** | Real | Live provider discovery near the user (text search with location bias). Note: Google Places does not return reliable `priceLevel` data for Pakistan's informal economy. |
| **Azure OpenAI (gpt-4o-mini)** | Real | Intent extraction, time-slot resolution, matching reasoning, follow-up question generation. |
| **faster-whisper large-v3-turbo** | Real (local, HuggingFace) | Speech-to-text for Urdu + English audio. |
| **LangSmith** | Real (optional) | Trace dashboard for every agent invocation. |
| **Mock SQLite Provider DB** | Mock | Fallback provider catalog used when Places API is unreachable or rate-limited. Since Places API lacks `priceLevel` for these services, we use mock base rates from this database, though the final price is still computed for each provider based on their rating. Seeded from `data/providers.json`. |
| **Simulated SMS Gateway** | Mock | Notifications are emitted as structured JSON in the response instead of hitting a real SMS provider. |

---

## Integrations Implemented

- **LangChain ↔ Azure OpenAI** — `AzureChatOpenAI` with `.with_structured_output(Pydantic)` for every LLM call that needs reliable JSON.
- **LangGraph ↔ LangSmith** — `@traceable(name=..., run_type="chain")` on each node + the top-level pipeline.
- **FastAPI ↔ faster-whisper** — Whisper is preloaded on FastAPI's `lifespan` startup hook so the first request isn't slow. CUDA is auto-detected via CTranslate2; falls back to CPU/int8 silently.
- **FastAPI ↔ ffmpeg** — Audio is preprocessed (16 kHz mono, highpass 80 Hz, EBU R128 loudness normalization `-16 LUFS`) before being handed to Whisper. Hallucination filter blocks common Whisper failure modes.
- **LangGraph ↔ SQLite** — Bookings and multi-turn session context are persisted with a 30-minute TTL on sessions.
- **Multi-turn merge** — `_merge_session_context` does a **structured slot-by-slot merge** (not string concatenation), then re-runs the pipeline once all slots are filled.

---

## Pricing Mechanism

Instead of a complex real-time demand-driven node, pricing is established through a straightforward modifier on top of base rates stored in the database. When providers are returned, their cost is calculated via `get_price_estimate` in the Mock DB logic.

### Why Mock Data for Pricing?

Real-time pricing data is unavailable for this category because the **Google Places API does not return price information for informal service providers** (home services, local ustads, tradesmen, etc.). This is a known gap in the API — it only surfaces pricing for formal businesses like restaurants or hotels.

Since this project targets **Pakistan's informal economy**, where service pricing is negotiated, unstructured, and not listed on any platform, mock base rates were defined manually based on realistic local market estimates. This allows the system to function end-to-end without a live pricing backend.

### Formula

```
multiplier = 1.0 + max(0.0, (rating - 3.0) / 10.0)
min_price = base_min_price * multiplier
max_price = base_max_price * multiplier
```

### How It Works

Providers with a rating above 3.0 receive a premium on their base rates up to +20%, simulating an informal economy environment where highly-rated ustads can command a higher fee. The base rates themselves are seeded in the mock database and reflect approximate market rates for common services in Pakistan (e.g., plumbing, electrical work, carpentry).

### Future Improvement

Once a community-sourced or scraped pricing dataset becomes available for Pakistani informal services, the mock DB layer can be replaced with a live pricing node without changing the formula or the rest of the pipeline.

---

## Project Structure

```
service-orchestrator/
├── main.py                       # FastAPI entry — text + audio endpoints, session merge
├── run_demo.py                   # CLI demo runner
├── requirements.txt
├── ustaadnow.db                  # auto-generated SQLite (bookings + sessions)
├── .env                          # secrets (not committed)
│
├── agents/
│   ├── intent_agent.py           # LLM intent parser
│   ├── discovery_agent.py        # Geocode + Places search + haversine
│   ├── matching_agent.py         # Weighted score + LLM reasoning
│   ├── booking_agent.py          # LLM slot resolution + SQLite persistence
│   └── followup_agent.py         # Missing-data Qs + simulated SMS
│
├── graph/
│   └── orchestrator.py           # LangGraph StateGraph, conditional edges, pipeline entry
│
├── tools/
│   ├── maps_tool.py              # Google Places API (New)
│   ├── mock_db.py                # SQLite bookings + session context (30-min TTL) + Pricing
│   └── whisper_tool.py           # faster-whisper + ffmpeg + hallucination filter
│
├── models/
│   └── schemas.py                # Pydantic models + AgentState TypedDict
│
├── data/
│   ├── providers.json            # Mock provider catalog (fallback)
│   └── bookings.json             # Seeded sample bookings
│
└── utils/
    └── logger.py                 # Structured per-agent log records
```

---

## Agentic Pipeline (LangGraph)

```
START → intent_node ──┬─[service_type=None]─→ error_node ──→ END
                      │
                      └─→ discovery_node → matching_node ──┐
                                                           │
                                           ┌─[missing slots]──────────────┘
                                           │
                                           ▼
                                     followup_node (ask) ──→ END
                                           │
                                           │  [all slots present]
                                           ▼
                                      booking_node ──→ followup_node (notify) ──→ END
```

---

## API Endpoints

### Core

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/request` | Text service request (JSON body: `input`, `session_id?`). |
| `POST` | `/api/request/audio` | Audio service request (FormData: `audio` file, `lang` = `"ur"`/`"en"`, `session_id?`). |
| `GET` | `/api/bookings` | List all confirmed bookings. |
| `POST` | `/api/bookings` | Create a direct booking (skip intent/discovery). |
| `GET` | `/api/health` | Health check. |

Swagger UI: **`http://localhost:8002/docs`**

---

## Multi-turn Conversations (Session Context)

If the user leaves out `location` or `time_preference`:

1. The graph terminates at `followup_node`, returning `{ followup: { status: "incomplete", followup_question: "..." } }`.
2. The current partial state is saved to the `session_context` SQLite table keyed on `session_id` (with a 30-minute TTL).
3. The next request with the same `session_id` triggers a **structured slot-by-slot merge**.
4. Once all three required slots are present, the pipeline re-runs with a composed prompt.

---

## Quick Start

### Prerequisites

- Python 3.9+
- Azure OpenAI API key + deployment (`gpt-4o-mini`)
- `ffmpeg` on PATH (audio normalization)
- (Optional) Google Maps API key for live Places search

### Setup

```bash
cd service-orchestrator
pip install -r requirements.txt
cp .env.example .env       # fill in your keys
```
*(Note: LangGraph requires manual installation if missing as it was not included in `requirements.txt`: `pip install langgraph`)*

### Run the server
```bash
uvicorn main:app --host 0.0.0.0 --port 8002 --reload
```

---

## Environment Variables

| Variable | Required | Purpose |
|---|---|---|
| `AZURE_OPENAI_API_KEY` | yes | LLM for intent, slot resolution, reasoning, follow-up. |
| `AZURE_OPENAI_ENDPOINT` | yes | Azure resource endpoint. |
| `AZURE_OPENAI_VERSION` | yes | API version (e.g. `2024-08-01-preview`). |
| `AZURE_OPENAI_MODEL_NAME` | yes | Deployment name (e.g. `gpt-4o-mini`). |
| `GOOGLE_PLACES_API_KEY` | yes | Live provider discovery. Falls back to mock DB if absent. |
| `GOOGLE_MAPS_API_KEY` | yes | Live provider discovery alternate key. |
| `LANGCHAIN_API_KEY` | optional | Enable LangSmith trace dashboard. |
| `LANGCHAIN_TRACING_V2` | optional | Set to `true` to send traces. |

---

## Demo Walkthrough

1. **Single-shot Urdu text** — `"Mujhe kal subah G-13 mein AC technician chahiye"` → full booking in one turn. Upon confirmation, you can directly call the provider on their given number.
2. **Multi-turn follow-up** — `"Plumber chahiye"` → asks `"Aapka address kya hai aur kab chahiye?"` → user replies `"G-13 mein"` → asks `"Service kab chahiye?"` → user replies `"kal subah"` → booking confirmed.
3. **Voice (Urdu)** — Upload an Urdu audio clip with `lang=ur` → Whisper transcribes → same pipeline runs.

---

## Future Roadmap

- Real SMS provider (Twilio / SMS Pakistan) wired into `followup_agent`.
- Provider-side mobile app with job acceptance + earnings dashboard.
- Multi-city expansion beyond Islamabad/Rawalpindi.
- Pakistan-specific payment integration (JazzCash / EasyPaisa).

---

## License

Hackathon submission — UstaadNow AI © 2026.
