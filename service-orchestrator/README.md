# UstaadNow — Service Orchestrator
> AI-powered service booking for Pakistan's informal economy

---

## Hackathon Submission
- **Challenge:** AI Service Orchestrator for Informal Economy
- **Stack:** LangChain + LangGraph + LangSmith + FastAPI + faster-whisper

---

## Problem Statement
Millions of skilled workers in Pakistan's informal economy — plumbers, electricians, AC technicians, carpenters — are discovered through word-of-mouth or WhatsApp. There is no structured, reliable way for customers to find, compare, and book these providers.

UstaadNow solves this by letting users describe their need in **Urdu, Roman Urdu, or English** (via text or voice), and automatically finding, ranking, and booking the best available provider — end to end, with full agent tracing.

---

## System Architecture

```
Voice / Text Input (Urdu / Roman Urdu / English)
        ↓
[faster-whisper STT]  ← audio path only
        ↓
FastAPI  POST /api/request  |  POST /api/request/audio
        ↓
[LangGraph StateGraph Orchestrator]
        │
        ├── Node 1: Intent Agent      → Extracts service / location / time via LLM
        ├── Node 2: Discovery Agent   → Finds providers via Google Places API / Mock DB
        ├── Node 3: Matching Agent    → Scores & ranks providers, picks best
        ├── Node 4: Booking Agent     → Confirms booking, writes to JSON store
        └── Node 5: Follow-Up Agent   → Schedules reminders, notifies provider
        ↓
LangSmith Trace Dashboard
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Orchestration | LangGraph (StateGraph) |
| LLM Chains | LangChain + Azure OpenAI (gpt-4o-mini) |
| Speech-to-Text | faster-whisper (large-v3-turbo) |
| Observability | LangSmith (`@traceable`) |
| API Server | FastAPI + Uvicorn |
| Provider Discovery | Google Places API (New) + Mock JSON DB fallback |
| Storage | JSON flat files |
| Language Support | Urdu, Roman Urdu, English |

---

## Project Structure

```
service-orchestrator/
├── main.py                  # FastAPI entry point (text + audio endpoints)
├── run_demo.py              # CLI demo runner
├── agents/
│   ├── intent_agent.py      # LLM intent parser (service/location/time/language)
│   ├── discovery_agent.py   # Provider search + haversine distance
│   ├── matching_agent.py    # Scoring + LLM reasoning
│   ├── booking_agent.py     # Booking creation + JSON persistence
│   └── followup_agent.py    # Reminders + simulated SMS notifications
├── graph/
│   └── orchestrator.py      # LangGraph StateGraph + run_pipeline()
├── tools/
│   ├── maps_tool.py         # Google Places API (New) via requests
│   ├── mock_db.py           # Mock provider + bookings database
│   └── whisper_tool.py      # faster-whisper STT + language detection
├── models/
│   └── schemas.py           # Pydantic models + AgentState TypedDict
├── utils/
│   └── logger.py            # Structured per-agent logging
└── data/
    ├── providers.json        # 32 mock providers across 8 categories
    └── bookings.json         # Persisted booking records
```

---

## Agentic Pipeline (LangGraph)

The pipeline is a `StateGraph` that passes a single `AgentState` TypedDict through 5 nodes:

```
START → intent_node → [has service_type?] → discovery_node
                              ↓ No                ↓
                          error_node       matching_node
                              ↓                  ↓
                             END           booking_node
                                                ↓
                                         followup_node → END
```

Each node:
1. Receives the full shared state
2. Calls its agent function
3. Returns the updated state

---

## Agents

### 1. Intent Agent
Uses Azure OpenAI to parse free-form Urdu/Roman Urdu/English text into structured fields. If faster-whisper already detected the language from audio, that value is preserved and passed to the LLM as context.

### 2. Discovery Agent
Tries Google Places API (New) first; falls back to `mock_db` on any error. Computes haversine distance from the user's area to each provider. Returns top 10 sorted by proximity.

**Area coordinates supported:** G-13, F-10, I-8, G-9, G-11, E-11, Bahria Town, DHA, Saddar, F-7

### 3. Matching Agent
Scores every provider using:
```
score = (rating/5.0 × 0.4) + ((1 - distance/10) × 0.4) + (available × 0.2)
```
Selects the top scorer and generates a 1–2 sentence human-readable reasoning via LLM.

### 4. Booking Agent
Generates a `BK-XXXXXX` booking ID, maps time keywords (`subah→10AM`, `shaam→5PM`, `dopahar→2PM`), persists the booking to `data/bookings.json`, and sets status to `CONFIRMED`.

### 5. Follow-Up Agent
Builds 3 simulated notifications (2× SMS to customer + provider, 1× reminder) and schedules a 1-hour-before reminder message.

---

## Speech-to-Text (faster-whisper)

`tools/whisper_tool.py` loads the `large-v3-turbo` model and:
- Transcribes audio (WAV, MP3, M4A, etc.)
- Auto-detects language (`ur` → `urdu`, `en` + Urdu markers → `roman_urdu`, `en` → `english`)
- Uses GPU (`float16`) if CUDA is available, otherwise CPU (`int8`)
- Returns transcript + language label + confidence score

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/request` | Submit text service request |
| POST | `/api/request/audio` | Submit audio file — whisper transcribes first |
| GET | `/api/bookings` | List all confirmed bookings |
| GET | `/api/trace/{id}` | Get agent log trace for a booking |
| GET | `/api/health` | Health check |

Swagger UI: **`http://localhost:8000/docs`**

---

## Quick Start

### Prerequisites
- Python 3.11+
- Azure OpenAI API key

### Setup
```bash
cd service-orchestrator
pip install -r requirements.txt
cp .env.example .env   # fill in your Azure OpenAI keys
```

### Run the server
```bash
uvicorn main:app --reload
```

### Run CLI demo
```bash
python run_demo.py "Mujhe kal subah G-13 mein AC technician chahiye"
python run_demo.py "I need a plumber in F-10 today afternoon"
python run_demo.py "Electrician chahiye Bahria Town mein"
```

---

## Environment Variables

| Variable | Required | Purpose |
|---|---|---|
| `AZURE_OPENAI_API_KEY` | Yes | LLM for intent + reasoning |
| `AZURE_OPENAI_ENDPOINT` | Yes | Azure resource endpoint |
| `AZURE_OPENAI_VERSION` | Yes | API version |
| `AZURE_OPENAI_MODEL_NAME` | Yes | Deployment name |
| `GOOGLE_PLACES_API_KEY` | Optional | Real provider search (mock fallback built-in) |
| `LANGCHAIN_API_KEY` | Optional | LangSmith trace dashboard |
| `LANGCHAIN_TRACING_V2` | Optional | Enable LangSmith (`true`) |

---

## Mock Provider Data

32 providers across 8 service categories and 10 Islamabad/Rawalpindi areas:

| Category | Count |
|---|---|
| AC Technician | 4 |
| Plumber | 4 |
| Electrician | 4 |
| Home Tutor | 4 |
| Beautician | 4 |
| Carpenter | 4 |
| Painter | 4 |
| CCTV Installer | 4 |

---

## Example Output

```
Input: Mujhe kal subah G-13 mein AC technician chahiye

SERVICE REQUEST
   Service  : AC Technician
   Location : G-13
   Time     : kal subah
   Language : urdu

SELECTED PROVIDER
   Name      : Ali AC Services
   Rating    : 4.8 (145 reviews)
   Distance  : 0.1 km
   Phone     : +92 300 1234567
   Reasoning : Ali AC Services stands out due to its 4.8/5 rating and proximity of 0.08km...

BOOKING CONFIRMED
   Booking ID : BK-343403
   Slot       : Tomorrow, 10:00 AM
   Status     : CONFIRMED

AGENT TRACE
   ✅ [intent_agent]     service=AC Technician, location=G-13, time=kal subah, lang=urdu
   ✅ [discovery_agent]  Found 4 providers via mock DB
   ✅ [matching_agent]   Selected: Ali AC Services (score=0.98, dist=0.08km)
   ✅ [booking_agent]    Booking BK-343403 CONFIRMED for Tomorrow, 10:00 AM
   ✅ [followup_agent]   3 notifications scheduled
```

---

## Assumptions & Limitations

1. Provider data is mocked — real deployment would connect to a live provider registry
2. Bookings are stored in a local JSON file — not suitable for concurrent multi-user production use
3. Roman Urdu detection relies on a keyword heuristic alongside Whisper's language code
4. Google Places API fallback to mock DB means results may not reflect real-world availability
5. Follow-up notifications are simulated — no actual SMS gateway is connected
6. faster-whisper model downloads on first run (~1.5GB for large-v3-turbo)
