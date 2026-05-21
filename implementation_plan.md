# Khadamat AI — Complete Implementation Plan & Workflow

> Comprehensive reference for hackathon recording / demo walkthrough

---

## 1. High-Level System Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        A["Flutter App / Postman / CLI"]
    end

    subgraph "API Layer — FastAPI (main.py)"
        B["POST /api/request<br/>(Text)"]
        C["POST /api/request/audio<br/>(Voice)"]
        D["GET /api/bookings"]
        E["GET /api/trace/{id}"]
        F["POST /api/bookings"]
        G["GET /api/health"]
    end

    subgraph "STT Layer"
        H["faster-whisper<br/>large-v3-turbo<br/>(whisper_tool.py)"]
    end

    subgraph "Orchestration — LangGraph (orchestrator.py)"
        I["StateGraph Pipeline"]
    end

    subgraph "Agents"
        J["Intent Agent"]
        K["Discovery Agent"]
        L["Matching Agent"]
        M["Booking Agent"]
        N["Follow-Up Agent"]
    end

    subgraph "Data Layer"
        O["SQLite DB<br/>(khadamat.db)"]
        P["Google Maps API"]
        Q["Azure OpenAI<br/>(gpt-4o-mini)"]
    end

    subgraph "Observability"
        R["LangSmith Traces"]
    end

    A -->|Text| B
    A -->|Audio + lang| C
    C --> H
    H -->|Transcript| I
    B -->|User Input| I
    I --> J --> K --> L
    L -->|"Missing slots?"| N
    L -->|"All slots OK"| M --> N
    J & K & L & M & N --> Q
    K --> P
    M & N --> O
    D & E & F --> O
    I -.->|"@traceable"| R
```

---

## 2. LangGraph Pipeline — Detailed Flow

This is the core of the system. A `StateGraph` passes a shared [AgentState](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/models/schemas.py#44-58) TypedDict through nodes.

```mermaid
flowchart TD
    START(["🟢 START"])
    INTENT["**Intent Agent**<br/>LLM Structured Output<br/>→ service_type, location,<br/>time_preference, language"]
    ROUTE1{"service_type<br/>detected?"}
    ERROR["**Error Node**<br/>Localized error message<br/>(Urdu / Roman Urdu / English)"]
    DISCOVERY["**Discovery Agent**<br/>Google Maps Geocoding<br/>→ Find nearby providers<br/>+ Haversine distance"]
    MATCHING["**Matching Agent**<br/>Score = rating×0.4 +<br/>proximity×0.4 + avail×0.2<br/>+ LLM reasoning"]
    ROUTE2{"location +<br/>time_preference +<br/>selected_provider<br/>all present?"}
    FOLLOWUP_Q["**Follow-Up Agent**<br/>(Missing Slots Path)<br/>→ LLM generates question<br/>in user's language"]
    BOOKING["**Booking Agent**<br/>LLM slot resolution<br/>→ BK-XXXXXX ID<br/>→ SQLite persistence"]
    FOLLOWUP_N["**Follow-Up Agent**<br/>(Notifications Path)<br/>→ 3 simulated SMS"]
    END_NODE(["🔴 END"])

    START --> INTENT
    INTENT --> ROUTE1
    ROUTE1 -->|"Yes"| DISCOVERY
    ROUTE1 -->|"No"| ERROR
    ERROR --> END_NODE
    DISCOVERY --> MATCHING
    MATCHING --> ROUTE2
    ROUTE2 -->|"Yes"| BOOKING
    ROUTE2 -->|"No"| FOLLOWUP_Q
    BOOKING --> FOLLOWUP_N
    FOLLOWUP_Q --> END_NODE
    FOLLOWUP_N --> END_NODE

    style INTENT fill:#4A90D9,color:#fff
    style DISCOVERY fill:#7B68EE,color:#fff
    style MATCHING fill:#E67E22,color:#fff
    style BOOKING fill:#27AE60,color:#fff
    style FOLLOWUP_Q fill:#E74C3C,color:#fff
    style FOLLOWUP_N fill:#27AE60,color:#fff
    style ERROR fill:#C0392B,color:#fff
```

---

## 3. Multi-Turn Conversation Flow

When a user doesn't provide all 3 required slots (`service_type`, [location](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/discovery_agent.py#98-139), `time_preference`), the system enters a multi-turn loop.

```mermaid
sequenceDiagram
    participant User as 👤 User
    participant API as 🌐 FastAPI
    participant Pipeline as ⚙️ LangGraph
    participant DB as 💾 SQLite

    Note over User,DB: Turn 1 — Incomplete request
    User->>API: POST /api/request<br/>{"input": "Plumber chahiye", "session_id": "abc123"}
    API->>Pipeline: run_pipeline("Plumber chahiye")
    Pipeline-->>API: service_type=Plumber, location=null, time=null
    API->>DB: save_session_context("abc123", {service_type: "Plumber"})
    API-->>User: followup.status = "incomplete"<br/>followup_question = "Aapka address kya<br/>hai aur kab chahiye?"

    Note over User,DB: Turn 2 — Partial fill
    User->>API: POST /api/request<br/>{"input": "G-13 mein", "session_id": "abc123"}
    API->>DB: get_session_context("abc123")
    DB-->>API: {service_type: "Plumber"}
    API->>Pipeline: run_pipeline("G-13 mein")
    Pipeline-->>API: location=G-13, time=null
    API->>API: _merge_session_context()<br/>→ service_type=Plumber + location=G-13
    API->>DB: save_session_context(updated)
    API-->>User: followup.status = "incomplete"<br/>followup_question = "Service kab chahiye?"

    Note over User,DB: Turn 3 — All slots filled
    User->>API: POST /api/request<br/>{"input": "kal subah", "session_id": "abc123"}
    API->>DB: get_session_context("abc123")
    DB-->>API: {service_type: "Plumber", location: "G-13"}
    API->>Pipeline: run_pipeline("kal subah")
    Pipeline-->>API: time_preference=kal subah
    API->>API: _merge → all slots filled!<br/>Re-run pipeline with composed input
    API->>Pipeline: run_pipeline("Plumber chahiye G-13 mein kal subah")
    Pipeline-->>API: Full booking result
    API->>DB: delete_session_context("abc123")
    API-->>User: booking.status = "CONFIRMED"<br/>booking_id = "BK-343403"
```

---

## 4. Audio Pipeline Flow

```mermaid
flowchart TD
    A["📱 Client sends audio<br/>+ lang='ur' or 'en'<br/>+ session_id (optional)"]
    B["🔍 Validate lang<br/>('ur' or 'en' required)"]
    C["🔍 Validate content type<br/>(WAV, MP3, OGG, etc.)"]
    D["💾 Save to temp file"]
    E["🔄 ffmpeg preprocessing<br/>→ 16kHz mono WAV<br/>+ highpass + loudnorm"]
    F["🧠 faster-whisper<br/>transcribe with<br/>language pinned"]
    G{"Hallucination<br/>check passed?"}
    H["❌ 422: No speech detected"]
    I["⚙️ run_pipeline<br/>(transcript, language)"]
    J["🔁 Structured slot merge<br/>with session context"]
    K{"All slots<br/>filled?"}
    L["🔄 Re-run pipeline<br/>with composed slots"]
    M["📤 Return result +<br/>STT metadata"]

    A --> B --> C --> D --> E --> F --> G
    G -->|"No"| H
    G -->|"Yes"| I --> J --> K
    K -->|"Yes + no booking"| L --> M
    K -->|"No / already booked"| M

    style F fill:#4A90D9,color:#fff
    style I fill:#7B68EE,color:#fff
    style L fill:#E67E22,color:#fff
```

---

## 5. Agent Details

### 5.1 Intent Agent — [intent_agent.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/intent_agent.py)

```mermaid
flowchart LR
    A["Raw user input"] --> B{"Language<br/>pre-set?"}
    B -->|"Yes (audio path)"| C["Append language hint<br/>to user message"]
    B -->|"No (text path)"| D["Send raw input"]
    C --> E["Azure OpenAI<br/>.with_structured_output()"]
    D --> E
    E --> F["IntentOutput<br/>(Pydantic model)"]
    F --> G["Update AgentState"]
```

| Field | Type | Description |
|-------|------|-------------|
| `service_type` | `str or null` | AC Technician, Plumber, Electrician, etc. |
| [location](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/discovery_agent.py#98-139) | `str or null` | G-13, F-10, Bahria Town, etc. |
| `time_preference` | `str or null` | "kal subah", "today afternoon", "8 baje raat" |
| `language_detected` | `str` | "urdu", "roman_urdu", or "english" |

### 5.2 Discovery Agent — [discovery_agent.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/discovery_agent.py)

- **Geocodes** user location via Google Geocoding API (biased to Islamabad/Rawalpindi)
- **Searches** for providers via Google Places API → falls back to mock DB
- **Computes** haversine distance from user coords to each provider
- **Returns** top 10 providers sorted by proximity

### 5.3 Matching Agent — [matching_agent.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/matching_agent.py)

**Scoring formula:**
```
score = (rating/5.0 × 0.4) + ((1 - distance/10) × 0.4) + (available × 0.2)
```

Then asks Azure OpenAI to generate a human-readable 1-2 sentence reasoning for why the top provider was selected.

### 5.4 Booking Agent — [booking_agent.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/booking_agent.py)

```mermaid
flowchart TD
    A["Time preference string"] --> B["Azure OpenAI<br/>.with_structured_output()<br/>→ SlotResolution"]
    B --> C["SlotResolution:<br/>day, time_24h, time_display,<br/>user_was_specific, confidence"]
    C --> D["Generate BK-XXXXXX ID"]
    D --> E["Build localized<br/>confirmation message<br/>(Urdu / Roman Urdu / English)"]
    E --> F["Save to SQLite"]
```

**Key feature:** The LLM resolves vague time expressions like "kal subah", "8 baje raat", "parsoon dopahar" into concrete [SlotResolution](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/booking_agent.py#106-129) objects with day + time + confidence.

### 5.5 Follow-Up Agent — [followup_agent.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/followup_agent.py)

**Two paths:**

| Path | Trigger | Action |
|------|---------|--------|
| **Missing Slots** | [missing_fields](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/followup_agent.py#237-239) exist, no booking | LLM generates follow-up question in user's language |
| **Post-Booking** | [booking](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/graph/orchestrator.py#236-238) exists | Schedules 3 simulated notifications (2 SMS + 1 reminder) |

Has hardcoded fallback questions in Urdu, Roman Urdu, and English if the LLM call fails.

---

## 6. API Endpoint Specifications

### `POST /api/request` — Text Pipeline

**Request:**
```json
{
  "input": "Mujhe kal subah G-13 mein AC technician chahiye",
  "session_id": "optional-uuid"
}
```

**Response (complete booking):**
```json
{
  "service_type": "AC Technician",
  "location": "G-13",
  "time_preference": "kal subah",
  "language_detected": "roman_urdu",
  "selected_provider": { "name": "Ali AC Services", "rating": 4.8, "..." },
  "booking": {
    "booking_id": "BK-343403",
    "slot_time": "Tomorrow, 10:00 AM",
    "status": "CONFIRMED",
    "confirmation_message": "Aap ki booking..."
  },
  "followup": { "status": "complete", "..." },
  "agent_logs": [ "..." ]
}
```

**Response (incomplete — follow-up needed):**
```json
{
  "service_type": "Plumber",
  "location": null,
  "time_preference": null,
  "followup": {
    "status": "incomplete",
    "missing_fields": ["location", "time_preference"],
    "followup_question": "Aapka address kya hai aur kab chahiye?"
  }
}
```

---

### `POST /api/request/audio` — Audio Pipeline

**Request (FormData):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| [audio](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/tools/whisper_tool.py#171-186) | File | ✅ | Audio file (WAV, MP3, OGG, FLAC, M4A, WebM) |
| [lang](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/tools/whisper_tool.py#202-214) | String | ✅ | `"ur"` or `"en"` — pins Whisper language |
| `session_id` | String | ❌ | UUID for multi-turn sessions |

**Response:** Same as `/api/request` plus STT metadata:
```json
{
  "transcript": "Mujhe plumber chahiye G-13 mein",
  "language_detected": "urdu",
  "lang": "ur",
  "whisper_language": "ur",
  "stt_confidence": 0.94,
  "...same fields as text response..."
}
```

---

### `GET /api/bookings` — List All Bookings

Returns array of all confirmed bookings from SQLite.

### `POST /api/bookings` — Direct Booking

**Request:**
```json
{
  "service_type": "Plumber",
  "location": "G-13",
  "time_preference": "tomorrow morning",
  "selected_provider": { "id": "p1", "name": "Ali", "phone": "+92..." },
  "is_booking_confirmed": true
}
```

### `GET /api/trace/{booking_id}` — Agent Trace

Returns the `agent_logs_snapshot` for a specific booking.

### `GET /api/health` — Health Check

Returns `{ "status": "ok" }`.

---

## 7. Data Model — AgentState

The shared state TypedDict that flows through all LangGraph nodes:

```mermaid
classDiagram
    class AgentState {
        +str raw_input
        +str|null service_type
        +str|null location
        +str|null time_preference
        +str|null language_detected
        +list providers_found
        +list ranked_providers
        +dict|null selected_provider
        +bool is_booking_confirmed
        +dict|null booking
        +dict|null followup
        +list agent_logs
        +str|null error
    }
```

---

## 8. Session Context Management

```mermaid
flowchart TD
    A["New request arrives<br/>with session_id"] --> B{"Session exists<br/>in SQLite?"}
    B -->|"No"| C["Run pipeline<br/>on raw input"]
    B -->|"Yes"| D["Fetch prior context"]
    D --> E{"Session expired?<br/>(> 30 min TTL)"}
    E -->|"Yes"| F["Delete session<br/>→ treat as new"]
    E -->|"No"| G["Run pipeline<br/>on new input only"]
    F --> C
    G --> H["Structured slot merge:<br/>new value wins,<br/>fallback to prior"]
    C --> I{"All 3 slots<br/>filled?"}
    H --> I
    I -->|"No"| J["Save context to SQLite<br/>turn_count++"]
    I -->|"Yes + no booking"| K["Re-run pipeline<br/>with composed slots"]
    I -->|"Yes + booking"| L["Delete session"]
    K --> L
    J --> M["Return followup question"]
    L --> N["Return booking result"]

    style J fill:#E74C3C,color:#fff
    style L fill:#27AE60,color:#fff
```

---

## 9. Technology Stack Summary

```mermaid
graph LR
    subgraph "Frontend"
        A["Flutter Mobile App"]
    end
    subgraph "Backend"
        B["FastAPI + Uvicorn"]
    end
    subgraph "AI/ML"
        C["Azure OpenAI<br/>(gpt-4o-mini)"]
        D["faster-whisper<br/>(large-v3-turbo)"]
    end
    subgraph "Orchestration"
        E["LangGraph<br/>StateGraph"]
        F["LangChain<br/>Structured Output"]
    end
    subgraph "Storage"
        G["SQLite<br/>(khadamat.db)"]
    end
    subgraph "External"
        H["Google Maps<br/>Geocoding + Places"]
    end
    subgraph "Observability"
        I["LangSmith<br/>Traces"]
    end

    A --> B
    B --> E --> F --> C
    B --> D
    E --> G
    E --> H
    E -.-> I
```

---

## 10. File-by-File Reference

| File | Role | Key Tech |
|------|------|----------|
| [main.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/main.py) | FastAPI server, text + audio endpoints, session merge logic | FastAPI, Uvicorn |
| [orchestrator.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/graph/orchestrator.py) | LangGraph StateGraph, node wiring, conditional edges | LangGraph |
| [intent_agent.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/intent_agent.py) | LLM structured extraction of service/location/time/language | LangChain `.with_structured_output()` |
| [discovery_agent.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/discovery_agent.py) | Geocoding + provider search + haversine distance | Google Geocoding API |
| [matching_agent.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/matching_agent.py) | Weighted scoring + LLM reasoning for best provider | Azure OpenAI |
| [booking_agent.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/booking_agent.py) | LLM slot resolution + localized confirmations + SQLite persistence | `.with_structured_output()` |
| [followup_agent.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/agents/followup_agent.py) | Missing-data questioning + post-booking notification scheduling | Azure OpenAI |
| [whisper_tool.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/tools/whisper_tool.py) | STT with ffmpeg preprocessing, CUDA fallback, hallucination filter | faster-whisper |
| [mock_db.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/tools/mock_db.py) | SQLite for bookings + session context with TTL | sqlite3 |
| [schemas.py](file:///home/drasmat/Documents/AI%20Hackathon/service-orchestrator/models/schemas.py) | Pydantic models + AgentState TypedDict | Pydantic |
