# from uuid import uuid4
# from langsmith import traceable
# # pyrefly: ignore [missing-import]
# from langgraph.graph import StateGraph, END

# from models.schemas import AgentState
# from agents.intent_agent import run_intent_agent
# from agents.discovery_agent import run_discovery_agent
# from agents.matching_agent import run_matching_agent
# from agents.booking_agent import run_booking_agent
# from agents.followup_agent import run_followup_agent


# def intent_node(state: AgentState) -> AgentState:
#     return run_intent_agent(state)


# def discovery_node(state: AgentState) -> AgentState:
#     return run_discovery_agent(state)


# def matching_node(state: AgentState) -> AgentState:
#     return run_matching_agent(state)


# def booking_node(state: AgentState) -> AgentState:
#     return run_booking_agent(state)


# def followup_node(state: AgentState) -> AgentState:
#     return run_followup_agent(state)


# def error_node(state: AgentState) -> AgentState:
#     state["error"] = (
#         "Could not understand the service type. Please specify what service you need "
#         "(e.g., plumber, AC technician, electrician)."
#     )
#     return state


# def route_after_intent(state: AgentState) -> str:
#     if state.get("service_type") is None:
#         return "error_node"
#     return "discovery_node"


# graph = StateGraph(AgentState)
# graph.add_node("intent_node", intent_node)
# graph.add_node("discovery_node", discovery_node)
# graph.add_node("matching_node", matching_node)
# graph.add_node("booking_node", booking_node)
# graph.add_node("followup_node", followup_node)
# graph.add_node("error_node", error_node)

# graph.set_entry_point("intent_node")
# graph.add_conditional_edges(
#     "intent_node",
#     route_after_intent,
#     {"discovery_node": "discovery_node", "error_node": "error_node"},
# )
# graph.add_edge("discovery_node", "matching_node")
# graph.add_edge("matching_node", "booking_node")
# graph.add_edge("booking_node", "followup_node")
# graph.add_edge("followup_node", END)
# graph.add_edge("error_node", END)

# app = graph.compile()


# @traceable(name="service-orchestrator-pipeline", run_type="chain")
# def run_pipeline(user_input: str) -> dict:
#     initial_state: AgentState = {
#         "raw_input": user_input,
#         "service_type": None,
#         "location": None,
#         "time_preference": None,
#         "language_detected": None,
#         "providers_found": [],
#         "ranked_providers": [],
#         "selected_provider": None,
#         "booking": None,
#         "followup": None,
#         "agent_logs": [],
#         "error": None,
#     }
#     config = {"metadata": {"session_id": str(uuid4()), "user_input": user_input}}
#     result = app.invoke(initial_state, config=config)
#     return result




# from uuid import uuid4
# from langsmith import traceable
# # pyrefly: ignore [missing-import]
# from langgraph.graph import StateGraph, END

# from models.schemas import AgentState
# from agents.intent_agent import run_intent_agent
# from agents.discovery_agent import run_discovery_agent
# from agents.matching_agent import run_matching_agent
# from agents.booking_agent import run_booking_agent
# from agents.followup_agent import run_followup_agent


# def intent_node(state: AgentState) -> AgentState:
#     return run_intent_agent(state)


# def discovery_node(state: AgentState) -> AgentState:
#     return run_discovery_agent(state)


# def matching_node(state: AgentState) -> AgentState:
#     return run_matching_agent(state)


# def booking_node(state: AgentState) -> AgentState:
#     return run_booking_agent(state)


# def followup_node(state: AgentState) -> AgentState:
#     return run_followup_agent(state)


# def error_node(state: AgentState) -> AgentState:
#     state["error"] = (
#         "Could not understand the service type. Please specify what service you need "
#         "(e.g., plumber, AC technician, electrician)."
#     )
#     return state


# def route_after_intent(state: AgentState) -> str:
#     if state.get("service_type") is None:
#         return "error_node"
#     return "discovery_node"


# def route_after_matching(state: AgentState) -> str:
#     missing = []
#     if not state.get("location"):
#         missing.append("location")
#     if not state.get("time_preference"):
#         missing.append("time_preference")
#     if not state.get("selected_provider"):
#         missing.append("selected_provider")

#     print(f"ROUTE_AFTER_MATCHING: missing={missing}")  # ← ADD THIS
    
#     if missing:
#         return "followup_node"
#     return "booking_node"


# graph = StateGraph(AgentState)
# graph.add_node("intent_node", intent_node)
# graph.add_node("discovery_node", discovery_node)
# graph.add_node("matching_node", matching_node)
# graph.add_node("booking_node", booking_node)
# graph.add_node("followup_node", followup_node)
# graph.add_node("error_node", error_node)

# graph.set_entry_point("intent_node")
# graph.add_conditional_edges(
#     "intent_node",
#     route_after_intent,
#     {"discovery_node": "discovery_node", "error_node": "error_node"},
# )
# graph.add_edge("discovery_node", "matching_node")
# graph.add_conditional_edges(
#     "matching_node",
#     route_after_matching,
#     {"booking_node": "booking_node", "followup_node": "followup_node"},
# )
# graph.add_edge("booking_node", "followup_node")
# graph.add_edge("followup_node", END)
# graph.add_edge("error_node", END)

# app = graph.compile()


# @traceable(name="service-orchestrator-pipeline", run_type="chain")
# def run_pipeline(user_input: str, session_id: str = None) -> dict:
#     from tools.mock_db import init_db
#     init_db()  # ensure tables exist
    
#     initial_state: AgentState = {
#         "raw_input": user_input,
#         "service_type": None,
#         "location": None,
#         "time_preference": None,
#         "language_detected": None,
#         "providers_found": [],
#         "ranked_providers": [],
#         "selected_provider": None,
#         "is_booking_confirmed": False,
#         "booking": None,
#         "followup": None,
#         "agent_logs": [],
#         "error": None,
#     }
#     _session_id = session_id or str(uuid4())
#     config = {"metadata": {"session_id": _session_id, "user_input": user_input}}
#     result = app.invoke(initial_state, config=config)
#     return result



# import os
# import tempfile
# import traceback
# from contextlib import asynccontextmanager
# from dotenv import load_dotenv
# from fastapi import FastAPI, HTTPException, UploadFile, File, Form
# from fastapi.middleware.cors import CORSMiddleware
# from models.schemas import AgentState, ServiceRequest

# load_dotenv()


# @asynccontextmanager
# async def lifespan(app: FastAPI):
#     yield


# app = FastAPI(
#     title="Khadamat AI — Service Orchestrator",
#     description="AI-powered informal economy service booking for Pakistan",
#     version="1.0.0",
#     lifespan=lifespan,
# )

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# SUPPORTED_AUDIO_TYPES: dict[str, str] = {
#     "audio/wav":                 ".wav",
#     "audio/x-wav":               ".wav",
#     "audio/wave":                ".wav",
#     "audio/mpeg":                ".mp3",
#     "audio/mp3":                 ".mp3",
#     "audio/mp4":                 ".m4a",
#     "audio/x-m4a":               ".m4a",
#     "audio/ogg":                 ".ogg",
#     "audio/webm":                ".webm",
#     "audio/flac":                ".flac",
#     "audio/x-flac":              ".flac",
#     "application/octet-stream":  ".wav",
# }

# from tools.whisper_tool import transcribe_audio


# # ===========================================================================
# # Routes
# # ===========================================================================

# @app.get("/api/health")
# async def health_check():
#     return {"status": "ok"}


# # ---------------------------------------------------------------------------
# # Text pipeline
# # ---------------------------------------------------------------------------
# @app.post("/api/request")
# async def handle_request(body: dict):
#     from graph import run_pipeline
#     from tools.mock_db import get_session_context, delete_session_context
#     try:
#         user_input = body.get("input")
#         session_id = body.get("session_id")

#         if not user_input:
#             raise HTTPException(status_code=400, detail="Request body must contain 'input' field")

#         merged_input = user_input
#         if session_id:
#             ctx = get_session_context(session_id)
#             if ctx:
#                 parts = []
#                 if ctx.get("service_type"):
#                     parts.append(ctx["service_type"])
#                 if ctx.get("location"):
#                     parts.append(ctx["location"])
#                 if ctx.get("time_preference"):
#                     parts.append(ctx["time_preference"])
#                 merged_input = f"{' '.join(parts)} {user_input}".strip()
#                 print(f"MERGED INPUT: {merged_input}")

#         result = run_pipeline(merged_input, session_id=session_id)

#         if session_id:
#             followup = result.get("followup", {})
#             if followup and followup.get("status") == "incomplete":
#                 from tools.mock_db import save_session_context
#                 save_session_context(session_id, result)
#             else:
#                 delete_session_context(session_id)

#         return result
#     except HTTPException:
#         raise
#     except Exception as e:
#         print("\n" + "=" * 70)
#         print("❌ ERROR in /api/request")
#         print("=" * 70)
#         traceback.print_exc()
#         print("=" * 70 + "\n")
#         raise HTTPException(status_code=500, detail=str(e))


# # ---------------------------------------------------------------------------
# # Audio pipeline  — POST /api/request/audio
# # ---------------------------------------------------------------------------
# @app.post("/api/request/audio")
# async def handle_audio_request(
#     audio: UploadFile = File(...),
#     session_id: str = Form(None),
# ):
#     from graph import run_pipeline
#     from tools.mock_db import get_session_context, delete_session_context, save_session_context

#     print(f"\n📥 /api/request/audio  filename={audio.filename}  content_type={audio.content_type}  session_id={session_id}")

#     # ── 1. Validate content type ────────────────────────────────────────────
#     content_type = (audio.content_type or "").lower().split(";")[0].strip()
#     if content_type not in SUPPORTED_AUDIO_TYPES:
#         raise HTTPException(
#             status_code=415,
#             detail=(
#                 f"Unsupported audio type: '{content_type}'. "
#                 f"Supported types: {', '.join(SUPPORTED_AUDIO_TYPES.keys())}"
#             ),
#         )
#     ext = SUPPORTED_AUDIO_TYPES[content_type]

#     # ── 2. Write upload to a temp file ──────────────────────────────────────
#     tmp_path = None
#     try:
#         with tempfile.NamedTemporaryFile(suffix=ext, delete=False) as tmp:
#             tmp_path = tmp.name
#             contents = await audio.read()
#             if not contents:
#                 raise HTTPException(status_code=400, detail="Uploaded audio file is empty.")
#             tmp.write(contents)
#         print(f"💾 Saved upload  ({len(contents)} bytes)  →  {tmp_path}")
#     except HTTPException:
#         raise
#     except Exception as e:
#         print("\n" + "=" * 70)
#         print("❌ ERROR while saving audio upload")
#         print("=" * 70)
#         traceback.print_exc()
#         print("=" * 70 + "\n")
#         raise HTTPException(status_code=500, detail=f"Failed to read audio upload: {e}")

#     # ── 3. Transcribe ────────────────────────────────────────────────────────
#     try:
#         stt_result        = transcribe_audio(tmp_path)
#         transcript        = stt_result["transcript"]
#         language_detected = stt_result["language_detected"]
#     except Exception as e:
#         print("\n" + "=" * 70)
#         print("❌ ERROR during transcription")
#         print("=" * 70)
#         traceback.print_exc()
#         print("=" * 70 + "\n")
#         raise HTTPException(status_code=500, detail=f"Transcription failed: {e}")
#     finally:
#         if tmp_path:
#             try:
#                 os.unlink(tmp_path)
#             except OSError:
#                 pass

#     if not transcript:
#         raise HTTPException(
#             status_code=422,
#             detail="Could not transcribe any speech from the audio. Please speak clearly and try again.",
#         )

#     # ── 4. Merge session context if this is a follow-up turn ────────────────
#     merged_input = transcript
#     if session_id:
#         ctx = get_session_context(session_id)
#         if ctx:
#             parts = []
#             if ctx.get("service_type"):
#                 parts.append(ctx["service_type"])
#             if ctx.get("location"):
#                 parts.append(ctx["location"])
#             if ctx.get("time_preference"):
#                 parts.append(ctx["time_preference"])
#             merged_input = f"{' '.join(parts)} {transcript}".strip()
#             print(f"AUDIO MERGED INPUT: {merged_input}")

#     # ── 5. Run the LangGraph pipeline ───────────────────────────────────────
#     try:
#         result = run_pipeline(merged_input, session_id=session_id)
#     except Exception as e:
#         print("\n" + "=" * 70)
#         print("❌ ERROR inside LangGraph pipeline")
#         print("=" * 70)
#         traceback.print_exc()
#         print("=" * 70 + "\n")
#         raise HTTPException(status_code=500, detail=f"Pipeline error: {e}")

#     # ── 6. Save or clear session context ────────────────────────────────────
#     if session_id:
#         followup = result.get("followup", {})
#         if followup and followup.get("status") == "incomplete":
#             save_session_context(session_id, result)
#         else:
#             delete_session_context(session_id)

#     # ── 7. Attach STT metadata ───────────────────────────────────────────────
#     result["transcript"]        = transcript
#     result["language_detected"] = language_detected
#     result["whisper_language"]  = stt_result["whisper_language"]
#     result["stt_confidence"]    = stt_result["confidence"]

#     return result


# # ---------------------------------------------------------------------------
# # Bookings
# # ---------------------------------------------------------------------------
# @app.get("/api/bookings")
# async def get_bookings():
#     from tools.mock_db import get_all_bookings
#     return get_all_bookings()


# @app.post("/api/bookings")
# async def create_booking(body: dict):
#     from agents.booking_agent import run_booking_agent
#     try:
#         selected_provider = body.get("selected_provider") or {
#             "id":    body.get("provider_id"),
#             "name":  body.get("provider_name"),
#             "phone": body.get("provider_phone"),
#         }

#         state: AgentState = {
#             "raw_input":            body.get("raw_input", ""),
#             "service_type":         body.get("service_type"),
#             "location":             body.get("location"),
#             "time_preference":      body.get("time_preference"),
#             "language_detected":    body.get("language_detected"),
#             "providers_found":      [],
#             "ranked_providers":     [],
#             "selected_provider":    selected_provider,
#             "is_booking_confirmed": body.get("is_booking_confirmed", True),
#             "booking":              None,
#             "followup":             None,
#             "agent_logs":           [],
#             "error":                None,
#         }

#         result = run_booking_agent(state)
#         if not result.get("booking"):
#             raise HTTPException(status_code=400, detail=str(result.get("agent_logs")))
#         return result["booking"]
#     except HTTPException:
#         raise
#     except Exception as e:
#         print("\n" + "=" * 70)
#         print("❌ ERROR in /api/bookings")
#         print("=" * 70)
#         traceback.print_exc()
#         print("=" * 70 + "\n")
#         raise HTTPException(status_code=500, detail=str(e))

# @asynccontextmanager
# async def lifespan(app: FastAPI):
#     from tools.whisper_tool import _load_model
#     print("⏳ Pre-loading Whisper model at startup...")
#     _load_model()
#     print("✅ Whisper model ready.")
#     yield

# @app.get("/api/trace/{booking_id}")
# async def get_trace(booking_id: str):
#     from tools.mock_db import get_all_bookings
#     bookings = get_all_bookings()
#     booking = next((b for b in bookings if b["booking_id"] == booking_id), None)
#     if not booking:
#         raise HTTPException(status_code=404, detail="Booking not found")
#     return {"booking_id": booking_id, "agent_logs": booking.get("agent_logs_snapshot", [])}


# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=8002)



# import json
# import os
# from dotenv import load_dotenv
# from langchain_openai import AzureChatOpenAI
# from langchain_core.messages import SystemMessage, HumanMessage
# from langsmith import traceable

# from models.schemas import AgentState
# from utils.logger import create_agent_log, create_error_log

# load_dotenv()

# _llm = AzureChatOpenAI(
#     azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
#     api_key=os.getenv("AZURE_OPENAI_API_KEY"),
#     azure_deployment=os.getenv("AZURE_OPENAI_MODEL_NAME"),
#     api_version=os.getenv("AZURE_OPENAI_VERSION"),
#     temperature=0,
#     max_tokens=300,
# )

# _SYSTEM_PROMPT = """You are an intent parser for a Pakistani service booking app.
# Extract structured information from user input in Urdu, Roman Urdu, or English.
# Respond ONLY with a valid JSON object. No explanation, no markdown, no extra text.

# Extract:
# - service_type: one of [AC Technician, Plumber, Electrician, Home Tutor, Beautician, Carpenter, Painter, CCTV Installer] or null
# - location: area name in Islamabad/Rawalpindi (e.g. G-13, F-10, Bahria Town) or null
# - time_preference: normalized string like "tomorrow morning", "today afternoon", "kal subah" or null
# - language_detected: one of [urdu, roman_urdu, english]"""


# @traceable(name="intent-agent", run_type="chain")
# def run_intent_agent(state: AgentState) -> AgentState:
#     # If faster-whisper already detected the language (audio path), keep it
#     whisper_language = state.get("language_detected")

#     # Build system prompt — tell the LLM the language if whisper pre-detected it
#     system_prompt = _SYSTEM_PROMPT
#     if whisper_language:
#         system_prompt += f"\n\nNote: language has already been detected as '{whisper_language}' via speech recognition. Use this value."

#     try:
#         response = _llm.invoke([
#             SystemMessage(content=system_prompt),
#             HumanMessage(content=state["raw_input"]),
#         ])
#         raw = response.content.strip()
#         # Strip markdown code fences if present
#         if raw.startswith("```"):
#             raw = raw.split("```")[1]
#             if raw.startswith("json"):
#                 raw = raw[4:]
#         parsed = json.loads(raw)

#         state["service_type"] = parsed.get("service_type")
#         state["location"] = parsed.get("location")
#         state["time_preference"] = parsed.get("time_preference")
#         # Prefer whisper-detected language; fall back to LLM detection
#         state["language_detected"] = whisper_language or parsed.get("language_detected", "english")

#         state["agent_logs"].append(create_agent_log(
#             agent_name="intent_agent",
#             input_summary=f"Raw: {state['raw_input'][:80]}",
#             output_summary=(
#                 f"service={state['service_type']}, location={state['location']}, "
#                 f"time={state['time_preference']}, lang={state['language_detected']}"
#             ),
#         ))
#     except Exception as e:
#         state["service_type"] = None
#         state["agent_logs"].append(create_error_log("intent_agent", str(e)))

#     return state



# import os
# from dotenv import load_dotenv
# from langchain_openai import AzureChatOpenAI
# from langsmith import traceable
# from pydantic import BaseModel
# from typing import Optional

# from models.schemas import AgentState
# from utils.logger import create_agent_log, create_error_log

# load_dotenv()

# # ── LLM ──────────────────────────────────────────────────────────────────────

# _llm = AzureChatOpenAI(
#     azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
#     api_key=os.getenv("AZURE_OPENAI_API_KEY"),
#     azure_deployment=os.getenv("AZURE_OPENAI_MODEL_NAME"),
#     api_version=os.getenv("AZURE_OPENAI_VERSION"),
#     temperature=0,
#     max_tokens=300,
# )

# # ── Structured output schema ──────────────────────────────────────────────────

# class IntentOutput(BaseModel):
#     service_type: Optional[str] = None   # AC Technician | Plumber | … | null
#     location: Optional[str] = None       # area name or null
#     time_preference: Optional[str] = None
#     language_detected: str = "urdu | roman_urdu | english"

# # ── System prompt ─────────────────────────────────────────────────────────────

# _SYSTEM_PROMPT = """You are an intent parser for a Pakistani service booking app.
# Extract structured information from user input in Urdu, Roman Urdu, or English.

# Extract:
# - service_type: one of [AC Technician, Plumber, Electrician, Home Tutor, Beautician,
#   Carpenter, Painter, CCTV Installer] or null
# - location: area name in Islamabad/Rawalpindi (e.g. G-13, F-10, Bahria Town) or null
# - time_preference: normalized string like "tomorrow morning", "today afternoon",
#   "kal subah" or null
# - language_detected: one of [urdu, roman_urdu, english]"""

# # ── Agent (created once, reused across calls) ─────────────────────────────────

# # .with_structured_output() forces the model to return a structured
# # IntentOutput rather than free-form text — no manual JSON parsing needed.
# _agent = _llm.with_structured_output(IntentOutput)

# # ── Node function ─────────────────────────────────────────────────────────────

# # @traceable(name="intent-agent", run_type="chain")
# # def run_intent_agent(state: AgentState) -> AgentState:
# #     whisper_language = state.get("language_detected")

# #     # Tell the model the language if whisper already detected it
# #     extra_hint = ""
# #     if whisper_language:
# #         extra_hint = (
# #             f"\n\nNote: language has already been detected as '{whisper_language}' "
# #             "via speech recognition. Use this value for language_detected."
# #         )

# #     user_message = state["raw_input"] + extra_hint
# #     messages = [
# #         {"role": "system", "content": _SYSTEM_PROMPT},
# #         {"role": "user", "content": user_message}
# #     ]

# #     try:
# #         parsed: IntentOutput = _agent.invoke(messages)

# #         state["service_type"]    = parsed.service_type
# #         state["location"]        = parsed.location
# #         state["time_preference"] = parsed.time_preference
# #         # Whisper takes priority over LLM-detected language
# #         state["language_detected"] = whisper_language or parsed.language_detected

# #         state["agent_logs"].append(create_agent_log(
# #             agent_name="intent_agent",
# #             input_summary=f"Raw: {state['raw_input'][:80]}",
# #             output_summary=(
# #                 f"service={state['service_type']}, location={state['location']}, "
# #                 f"time={state['time_preference']}, lang={state['language_detected']}"
# #             ),
# #         ))

# #     except Exception as e:
# #         state["service_type"] = None
# #         state["agent_logs"].append(create_error_log("intent_agent", str(e)))

# #     return state


# @traceable(name="intent-agent", run_type="chain")
# def run_intent_agent(state: AgentState) -> AgentState:
#     whisper_language = state.get("language_detected")

#     extra_hint = ""
#     if whisper_language:
#         extra_hint = (
#             f"\n\nNote: language has already been detected as '{whisper_language}' "
#             "via speech recognition. Use this value for language_detected."
#         )

#     user_message = state["raw_input"] + extra_hint
#     messages = [
#         {"role": "system", "content": _SYSTEM_PROMPT},
#         {"role": "user", "content": user_message}
#     ]

#     try:
#         parsed: IntentOutput = _agent.invoke(messages)

#         # ← ADD THIS
#         print(f"INTENT PARSED: service={parsed.service_type}, location={parsed.location}, time={parsed.time_preference}")

#         state["service_type"]    = parsed.service_type
#         state["location"]        = parsed.location
#         state["time_preference"] = parsed.time_preference
#         state["language_detected"] = whisper_language or parsed.language_detected

#         state["agent_logs"].append(create_agent_log(
#             agent_name="intent_agent",
#             input_summary=f"Raw: {state['raw_input'][:80]}",
#             output_summary=(
#                 f"service={state['service_type']}, location={state['location']}, "
#                 f"time={state['time_preference']}, lang={state['language_detected']}"
#             ),
#         ))

#     except Exception as e:
#         state["service_type"] = None
#         state["agent_logs"].append(create_error_log("intent_agent", str(e)))

#     return state


# import math
# from langsmith import traceable

# from models.schemas import AgentState
# from utils.logger import create_agent_log, create_error_log

# AREA_COORDS = {
#     "G-13": (33.6844, 72.9748),
#     "F-10": (33.7141, 73.0237),
#     "I-8":  (33.6796, 73.0552),
#     "G-9":  (33.6938, 73.0237),
#     "G-11": (33.7020, 73.0100),
#     "E-11": (33.7200, 73.0000),
#     "Bahria Town": (33.5300, 73.1000),
#     "DHA":  (33.5180, 73.1070),
#     "Saddar": (33.6007, 73.0679),
#     "F-7":  (33.7229, 73.0436),
#     "Gauri Town": (33.6368, 73.1460),
# }
# DEFAULT_COORDS = (33.6844, 72.9748)


# def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
#     R = 6371
#     dlat = math.radians(lat2 - lat1)
#     dlon = math.radians(lon2 - lon1)
#     a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
#     return R * 2 * math.asin(math.sqrt(a))


# def _find_user_coords(location: str) -> tuple:
#     if not location:
#         return DEFAULT_COORDS
#     for key, coords in AREA_COORDS.items():
#         if key.lower() in location.lower() or location.lower() in key.lower():
#             return coords
#     return DEFAULT_COORDS


# @traceable(name="discovery-agent", run_type="chain")
# def run_discovery_agent(state: AgentState) -> AgentState:
#     service_type = state.get("service_type", "")
#     location = state.get("location", "")
#     user_lat, user_lng = _find_user_coords(location)

#     try:
#         from tools.maps_tool import search_nearby_providers
#         providers = search_nearby_providers(service_type, user_lat, user_lng)
#         source = "Google Maps"
#     except Exception:
#         from tools.mock_db import get_providers_by_service
#         providers = get_providers_by_service(service_type)
#         source = "mock DB"

#     for p in providers:
#         p["distance_km"] = round(_haversine(user_lat, user_lng, p["lat"], p["lng"]), 2)

#     providers_sorted = sorted(providers, key=lambda p: p["distance_km"])[:10]
#     state["providers_found"] = providers_sorted

#     state["agent_logs"].append(create_agent_log(
#         agent_name="discovery_agent",
#         input_summary=f"service={service_type}, location={location}",
#         output_summary=f"Found {len(providers_sorted)} providers via {source}",
#     ))
#     return state

# import random
# from datetime import datetime
# from langsmith import traceable

# from models.schemas import AgentState
# from utils.logger import create_agent_log, create_error_log

# TIME_MAP = {
#     "morning":   "10:00 AM",
#     "subah":     "10:00 AM",
#     "afternoon": "2:00 PM",
#     "dopahar":   "2:00 PM",
#     "evening":   "5:00 PM",
#     "shaam":     "5:00 PM",
# }
# DEFAULT_SLOT = "10:00 AM"


# def _parse_slot(time_preference: str) -> str:
#     if not time_preference:
#         return DEFAULT_SLOT
#     pref_lower = time_preference.lower()
#     for keyword, slot in TIME_MAP.items():
#         if keyword in pref_lower:
#             return slot
#     return DEFAULT_SLOT


# @traceable(name="booking-agent", run_type="chain")
# def run_booking_agent(state: AgentState) -> AgentState:
#     selected = state.get("selected_provider")
#     if not selected:
#         state["agent_logs"].append(create_error_log("booking_agent", "No selected provider"))
#         return state
#     # ✅ Add this guard
#     if not state.get("is_booking_confirmed", False):
#         state["agent_logs"].append(create_error_log("booking_agent", "User has not confirmed booking"))
#         return state

#     booking_id = f"BK-{random.randint(100000, 999999)}"
#     slot_time = _parse_slot(state.get("time_preference", ""))

#     booking = {
#         "booking_id": booking_id,
#         "provider_id": selected["id"],
#         "provider_name": selected["name"],
#         "provider_phone": selected["phone"],
#         "service_type": state["service_type"],
#         "location": state["location"],
#         "slot_time": f"Tomorrow, {slot_time}",
#         "status": "CONFIRMED",
#         "confirmation_message": (
#             f"Your booking with {selected['name']} is confirmed for tomorrow at {slot_time} "
#             f"in {state['location']}. Provider contact: {selected['phone']}"
#         ),
#         "created_at": datetime.now().isoformat(),
#         "agent_logs_snapshot": list(state["agent_logs"]),
#     }

#     try:
#         from tools.mock_db import save_booking
#         save_booking(booking)
#     except Exception as e:
#         state["agent_logs"].append(create_error_log("booking_agent", f"Save failed: {e}"))
#         return state

#     state["booking"] = booking

#     state["agent_logs"].append(create_agent_log(
#         agent_name="booking_agent",
#         input_summary=f"Provider: {selected['name']}, time_pref: {state.get('time_preference')}",
#         output_summary=f"Booking {booking_id} CONFIRMED for {booking['slot_time']}",
#     ))
#     return state


# import os
# from functools import lru_cache
# from faster_whisper import WhisperModel

# # Roman Urdu words commonly spoken — used to distinguish from plain English
# _ROMAN_URDU_MARKERS = {
#     "mujhe", "chahiye", "mein", "hai", "ka", "ki", "ko", "se", "nay", "kal",
#     "aaj", "subah", "shaam", "dopahar", "jaldi", "please", "bhai", "yaar",
#     "ghar", "abhi", "zaroor", "theek", "achha", "haan", "nahi", "koi", "kuch",
#     "wala", "wali", "karein", "karo", "chahta", "chahti", "lagao", "bulao",
# }


# @@lru_cache(maxsize=1)
# def _load_model() -> WhisperModel:
#     device = "cuda" if _cuda_available() else "cpu"
#     compute = "float16" if device == "cuda" else "int8"

#     model_path = os.path.expanduser(
#         "~/.cache/huggingface/hub/models--mobiuslabsgmbh--faster-whisper-large-v3-turbo"
#         "/snapshots/0a363e9161cbc7ed1431c9597a8ceaf0c4f78fcf"
#     )

#     if os.path.exists(model_path):
#         print(f"✅ Loading Whisper from local cache: {model_path}")
#         return WhisperModel(model_path, device=device, compute_type=compute)

#     # Fallback
#     print("⚠️ Local cache not found, downloading...")
#     return WhisperModel("large-v3-turbo", device=device, compute_type=compute)


# def _cuda_available() -> bool:
#     try:
#         import torch
#         return torch.cuda.is_available()
#     except ImportError:
#         return False


# def _map_language(whisper_lang: str, transcript: str) -> str:
#     """Map whisper language code to our three categories."""
#     if whisper_lang == "ur":
#         return "urdu"
#     if whisper_lang == "en":
#         words = set(transcript.lower().split())
#         if words & _ROMAN_URDU_MARKERS:
#             return "roman_urdu"
#         return "english"
#     # For any other detected language, check for Roman Urdu markers as fallback
#     words = set(transcript.lower().split())
#     if words & _ROMAN_URDU_MARKERS:
#         return "roman_urdu"
#     return "english"


# def transcribe_audio(audio_path: str) -> dict:
#     """
#     Transcribe an audio file and detect language.

#     Returns:
#         {
#           "transcript": str,
#           "language_detected": "urdu" | "roman_urdu" | "english",
#           "whisper_language": str,   # raw code from Whisper, e.g. "ur", "en"
#           "confidence": float,
#         }
#     """
#     model = _load_model()
#     segments, info = model.transcribe(
#         audio_path,
#         beam_size=5,
#         language=None,          # auto-detect
#         task="transcribe",
#         vad_filter=True,        # remove silence
#         vad_parameters={"min_silence_duration_ms": 500},
#     )

#     transcript = " ".join(seg.text.strip() for seg in segments).strip()
#     whisper_lang = info.language
#     confidence = round(info.language_probability, 3)
#     language_label = _map_language(whisper_lang, transcript)

#     return {
#         "transcript": transcript,
#         "language_detected": language_label,
#         "whisper_language": whisper_lang,
#         "confidence": confidence,
#     }



# import os
# import random
# from datetime import datetime, timedelta
# from dotenv import load_dotenv
# from langchain_openai import AzureChatOpenAI
# from langsmith import traceable
# from pydantic import BaseModel, Field
# from typing import Optional

# from models.schemas import AgentState
# from utils.logger import create_agent_log, create_error_log

# load_dotenv()

# # ── LLM ──────────────────────────────────────────────────────────────────────

# _llm = AzureChatOpenAI(
#     azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
#     api_key=os.getenv("AZURE_OPENAI_API_KEY"),
#     azure_deployment=os.getenv("AZURE_OPENAI_MODEL_NAME"),
#     api_version=os.getenv("AZURE_OPENAI_VERSION"),
#     temperature=0,
#     max_tokens=200,
# )


# # ── Structured output schema ──────────────────────────────────────────────────

# class SlotResolution(BaseModel):
#     """Resolved appointment slot."""
#     day: str = Field(
#         description="One of: 'today', 'tomorrow', 'day_after_tomorrow', or a "
#                     "specific date in YYYY-MM-DD format if user named a date."
#     )
#     time_24h: str = Field(
#         description="The appointment start time in 24-hour HH:MM format "
#                     "(e.g. '09:00', '14:30', '19:00')."
#     )
#     time_display: str = Field(
#         description="Human-readable time in 12-hour format with AM/PM "
#                     "(e.g. '9:00 AM', '2:30 PM', '7:00 PM')."
#     )
#     user_was_specific: bool = Field(
#         description="True if the user mentioned an exact time (e.g. '3pm', "
#                     "'11 baje', '8 baje raat'). False if they only said a vague "
#                     "period (e.g. 'morning', 'subah', 'evening') and we picked a default."
#     )
#     confidence: float = Field(
#         description="0.0 to 1.0 — how confident the parse is.",
#         ge=0.0, le=1.0,
#     )


# # ── System prompt ─────────────────────────────────────────────────────────────

# _SYSTEM_PROMPT = """You are a time-slot resolver for a Pakistani home-services booking app.

# Your job: convert the user's free-form time preference (in Urdu, Roman Urdu, or English)
# into a concrete appointment slot.

# CRITICAL RULES:
# 1. If the user mentions a SPECIFIC TIME (e.g. "3pm", "11 baje", "8 baje raat", "around 4",
#    "Tuesday 6pm"), use EXACTLY that time. Do not round to a default slot.
#    Set user_was_specific = true.

# 2. If the user only gives a VAGUE PERIOD (e.g. "morning", "subah", "afternoon", "dopahar",
#    "evening", "shaam", "night", "raat"), pick a sensible default within that period:
#      - morning / subah        → 10:00 AM
#      - afternoon / dopahar    → 2:00 PM
#      - evening / shaam        → 5:00 PM
#      - night / raat           → 7:00 PM
#    Set user_was_specific = false.

# 3. If the user says nothing about time, default to tomorrow 10:00 AM. user_was_specific = false.

# 4. Service operating window is 8:00 AM to 9:00 PM. If the user requests something outside
#    that window, snap to the nearest in-window time and set user_was_specific = false.

# 5. Day resolution:
#    - "today" / "aaj"          → today
#    - "tomorrow" / "kal"       → tomorrow  (default if nothing said)
#    - "day after tomorrow" / "parsoon" → day_after_tomorrow
#    - Specific weekday or date → return YYYY-MM-DD

# ROMAN URDU TIME EXPRESSIONS REFERENCE:
# - "subah" = morning, "dopahar" = afternoon, "shaam" = evening, "raat" = night
# - "X baje" = X o'clock (e.g. "8 baje" = 8:00)
# - "kal" = tomorrow, "aaj" = today, "parsoon" = day after tomorrow
# - "abhi" / "abi" = now/right away → soonest available in-window time today

# EXAMPLES:
# - "kal subah" → day=tomorrow, time=10:00 AM, user_was_specific=false
# - "kal 8 baje raat" → day=tomorrow, time=8:00 PM (20:00), user_was_specific=true
# - "aaj 3pm" → day=today, time=3:00 PM, user_was_specific=true
# - "morning" → day=tomorrow (default), time=10:00 AM, user_was_specific=false
# - "around 4 in the afternoon tomorrow" → day=tomorrow, time=4:00 PM, user_was_specific=true
# - "abhi" → day=today, time=(soonest in-window), user_was_specific=false
# """

# _slot_resolver = _llm.with_structured_output(SlotResolution)


# def _resolve_slot_with_llm(time_preference: str, language: str = "english") -> SlotResolution:
#     """LLM-based slot resolution. Falls back to a safe default on any failure."""
#     today_str = datetime.now().strftime("%Y-%m-%d (%A)")
#     user_msg = (
#         f"Today is {today_str}.\n"
#         f"User language: {language}\n"
#         f"User's time preference: \"{time_preference or '(not specified)'}\"\n\n"
#         "Resolve this to a concrete slot."
#     )

#     messages = [
#         {"role": "system", "content": _SYSTEM_PROMPT},
#         {"role": "user", "content": user_msg},
#     ]
#     return _slot_resolver.invoke(messages)


# def _safe_fallback_slot() -> SlotResolution:
#     """Hard-coded default used if the LLM call fails."""
#     return SlotResolution(
#         day="tomorrow",
#         time_24h="10:00",
#         time_display="10:00 AM",
#         user_was_specific=False,
#         confidence=0.5,
#     )


# def _format_slot_for_booking(resolution: SlotResolution) -> str:
#     """Turn the structured resolution into the display string the booking uses."""
#     day_label = {
#         "today":              "Today",
#         "tomorrow":           "Tomorrow",
#         "day_after_tomorrow": "Day after tomorrow",
#     }.get(resolution.day, resolution.day)  # specific dates fall through as YYYY-MM-DD

#     return f"{day_label}, {resolution.time_display}"


# # ── Agent ─────────────────────────────────────────────────────────────────────

# @traceable(name="booking-agent", run_type="chain")
# def run_booking_agent(state: AgentState) -> AgentState:
#     selected = state.get("selected_provider")
#     if not selected:
#         state["agent_logs"].append(create_error_log("booking_agent", "No selected provider"))
#         return state

#     if not state.get("is_booking_confirmed", False):
#         state["agent_logs"].append(create_error_log("booking_agent", "User has not confirmed booking"))
#         return state

#     time_preference = state.get("time_preference") or ""
#     language = state.get("language_detected") or "english"

#     # ── LLM-resolved slot ────────────────────────────────────────────────────
#     try:
#         resolution = _resolve_slot_with_llm(time_preference, language)
#         print(
#             f"⏰ SLOT RESOLVED: day={resolution.day}  time={resolution.time_display}  "
#             f"specific={resolution.user_was_specific}  confidence={resolution.confidence}"
#         )
#     except Exception as e:
#         print(f"⚠️ Slot LLM failed, using fallback: {e}")
#         resolution = _safe_fallback_slot()
#         state["agent_logs"].append(create_error_log(
#             "booking_agent",
#             f"Slot LLM failed ({e}), used fallback {resolution.time_display}",
#         ))

#     slot_display = _format_slot_for_booking(resolution)
#     booking_id = f"BK-{random.randint(100000, 999999)}"

#     # ── Build localized confirmation message ────────────────────────────────
#     if language == "urdu":
#         confirmation = (
#             f"آپ کی بکنگ {selected['name']} کے ساتھ {slot_display} کو "
#             f"{state['location']} میں کنفرم ہو گئی ہے۔ "
#             f"رابطہ: {selected['phone']}"
#         )
#     elif language == "roman_urdu":
#         confirmation = (
#             f"Aap ki booking {selected['name']} ke saath {slot_display} ko "
#             f"{state['location']} mein confirm ho gayi hai. "
#             f"Contact: {selected['phone']}"
#         )
#     else:
#         confirmation = (
#             f"Your booking with {selected['name']} is confirmed for {slot_display} "
#             f"in {state['location']}. Provider contact: {selected['phone']}"
#         )

#     booking = {
#         "booking_id":           booking_id,
#         "provider_id":          selected["id"],
#         "provider_name":        selected["name"],
#         "provider_phone":       selected["phone"],
#         "service_type":         state["service_type"],
#         "location":             state["location"],
#         "slot_time":            slot_display,
#         "slot_time_24h":        resolution.time_24h,
#         "slot_day":             resolution.day,
#         "user_specified_time":  resolution.user_was_specific,
#         "status":               "CONFIRMED",
#         "confirmation_message": confirmation,
#         "created_at":           datetime.now().isoformat(),
#         "agent_logs_snapshot":  list(state["agent_logs"]),
#     }

#     try:
#         from tools.mock_db import save_booking
#         save_booking(booking)
#     except Exception as e:
#         state["agent_logs"].append(create_error_log("booking_agent", f"Save failed: {e}"))
#         return state

#     state["booking"] = booking

#     state["agent_logs"].append(create_agent_log(
#         agent_name="booking_agent",
#         input_summary=(
#             f"Provider: {selected['name']}, time_pref: '{time_preference}', "
#             f"lang: {language}"
#         ),
#         output_summary=(
#             f"Booking {booking_id} CONFIRMED for {slot_display} "
#             f"(user_was_specific={resolution.user_was_specific})"
#         ),
#     ))
#     return state





# import math
# import os
# import requests
# from functools import lru_cache
# from langsmith import traceable

# from models.schemas import AgentState
# from utils.logger import create_agent_log, create_error_log

# # Fallback coordinates (Islamabad city center) used only if geocoding fails
# DEFAULT_COORDS = (33.6844, 72.9748)
# DEFAULT_REGION = "Islamabad, Pakistan"


# def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
#     R = 6371
#     dlat = math.radians(lat2 - lat1)
#     dlon = math.radians(lon2 - lon1)
#     a = (
#         math.sin(dlat / 2) ** 2
#         + math.cos(math.radians(lat1))
#         * math.cos(math.radians(lat2))
#         * math.sin(dlon / 2) ** 2
#     )
#     return R * 2 * math.asin(math.sqrt(a))


# @lru_cache(maxsize=256)
# def _geocode_location(location: str) -> tuple:
#     """
#     Resolve a free-text location to (lat, lng) using Google's Geocoding API.
#     Results are cached in-process to avoid repeated API calls for the same input.
#     Falls back to DEFAULT_COORDS on any failure.
#     """
#     if not location or not location.strip():
#         return DEFAULT_COORDS

#     api_key = os.getenv("GOOGLE_MAPS_API_KEY")
#     if not api_key:
#         # No key configured — can't geocode, return default
#         return DEFAULT_COORDS

#     # Bias results toward Islamabad/Rawalpindi so short inputs like "G-13"
#     # or "DHA" resolve to the right city rather than an unrelated match.
#     query = location.strip()
#     if "islamabad" not in query.lower() and "rawalpindi" not in query.lower():
#         query = f"{query}, {DEFAULT_REGION}"

#     try:
#         resp = requests.get(
#             "https://maps.googleapis.com/maps/api/geocode/json",
#             params={
#                 "address": query,
#                 "key": api_key,
#                 "region": "pk",
#                 # Bounding box around Islamabad/Rawalpindi to bias matches
#                 "bounds": "33.45,72.85|33.78,73.25",
#             },
#             timeout=5,
#         )
#         data = resp.json()
#         if data.get("status") == "OK" and data.get("results"):
#             loc = data["results"][0]["geometry"]["location"]
#             return (loc["lat"], loc["lng"])
#     except Exception:
#         pass

#     return DEFAULT_COORDS


# @traceable(name="discovery-agent", run_type="chain")
# def run_discovery_agent(state: AgentState) -> AgentState:
#     service_type = state.get("service_type", "")
#     # Prefer an explicit location from the query; fall back to state["location"]
#     query = state.get("query", "") or ""
#     location = state.get("location", "") or _extract_location_from_query(query)

#     user_lat, user_lng = _geocode_location(location)
#     geocoded = (user_lat, user_lng) != DEFAULT_COORDS or bool(location)

#     try:
#         from tools.maps_tool import search_nearby_providers
#         providers = search_nearby_providers(service_type, user_lat, user_lng)
#         source = "Google Maps"
#     except Exception:
#         from tools.mock_db import get_providers_by_service
#         providers = get_providers_by_service(service_type)
#         source = "mock DB"

#     for p in providers:
#         p["distance_km"] = round(
#             _haversine(user_lat, user_lng, p["lat"], p["lng"]), 2
#         )

#     providers_sorted = sorted(providers, key=lambda p: p["distance_km"])[:10]
#     state["providers_found"] = providers_sorted
#     state["user_coords"] = {"lat": user_lat, "lng": user_lng}
#     state["resolved_location"] = location or DEFAULT_REGION

#     state["agent_logs"].append(create_agent_log(
#         agent_name="discovery_agent",
#         input_summary=f"service={service_type}, location={location or '(none)'}",
#         output_summary=(
#             f"Found {len(providers_sorted)} providers via {source} "
#             f"near ({user_lat:.4f}, {user_lng:.4f}) "
#             f"[{'geocoded' if geocoded else 'default'}]"
#         ),
#     ))
#     return state


# def _extract_location_from_query(query: str) -> str:
#     """
#     Very lightweight extractor: pulls a location phrase from the user query
#     when state['location'] isn't set. Looks for 'in <place>', 'near <place>',
#     'at <place>', or 'around <place>'. Returns '' if nothing is found, and
#     geocoding will then fall back to DEFAULT_COORDS.
#     """
#     if not query:
#         return ""
#     import re
#     pattern = r"\b(?:in|near|at|around|close to)\s+([A-Za-z0-9\-\s,]+?)(?:[.?!]|$)"
#     m = re.search(pattern, query, flags=re.IGNORECASE)
#     if m:
#         return m.group(1).strip(" ,.")
#     return ""



# import os
# from langsmith import traceable
# from langchain_openai import AzureChatOpenAI
# from langchain_core.messages import HumanMessage

# from models.schemas import AgentState
# from utils.logger import create_agent_log, create_error_log


# FOLLOWUP_PROMPT = """You are a helpful service booking assistant for Pakistan.
# A user wants to book a service but some required information is missing.

# Information collected so far:
# - Service Type: {service_type}
# - Location: {location}
# - Time Preference: {time_preference}

# Missing fields: {missing_fields}

# LANGUAGE REQUIREMENT — CRITICAL:
# You MUST respond in {language_strict}. This is non-negotiable.
# - If "English" — reply in plain English only. No Urdu words, no Roman Urdu, no Hindi.
# - If "Urdu" — reply in Urdu script (نستعلیق). No English words except brand/place names.
# - If "Roman Urdu" — Urdu written in English letters, casual style.

# Ask the user a natural, friendly follow-up question to collect the missing information.
# Keep it short (one sentence) and conversational. Ask about all missing fields in one message.
# Do not repeat what you already know. Only ask for what is missing.

# Respond with ONLY the question, no extra text, no language label."""


# REQUIRED_FIELDS = ("service_type", "location", "time_preference")


# def _get_llm():
#     return AzureChatOpenAI(
#         azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
#         api_key=os.getenv("AZURE_OPENAI_API_KEY"),
#         azure_deployment=os.getenv("AZURE_OPENAI_MODEL_NAME"),
#         api_version=os.getenv("AZURE_OPENAI_VERSION"),
#         temperature=0.3,
#         max_tokens=150,
#     )


# def _get_missing_fields(state: AgentState) -> list[str]:
#     return [f for f in REQUIRED_FIELDS if not state.get(f)]


# def _language_label(code: str | None) -> str:
#     return {
#         "urdu":       "Urdu (Urdu script, نستعلیق)",
#         "roman_urdu": "Roman Urdu (Urdu in English letters)",
#         "english":    "English (plain English, no Urdu words)",
#     }.get(code or "english", "English (plain English, no Urdu words)")


# @traceable(name="followup-agent", run_type="chain")
# def run_followup_agent(state: AgentState) -> AgentState:
#     print(
#         f"FOLLOWUP AGENT  service={state.get('service_type')}  "
#         f"location={state.get('location')}  time={state.get('time_preference')}  "
#         f"booking={'yes' if state.get('booking') else 'no'}"
#     )

#     missing = _get_missing_fields(state)

#     # ── Path 1: missing required fields, no booking yet → ask user ─────────
#     if missing and not state.get("booking"):
#         try:
#             llm = _get_llm()
#             prompt = FOLLOWUP_PROMPT.format(
#                 service_type=state.get("service_type") or "(not provided yet)",
#                 location=state.get("location") or "(not provided yet)",
#                 time_preference=state.get("time_preference") or "(not provided yet)",
#                 missing_fields=", ".join(missing),
#                 language_strict=_language_label(state.get("language_detected")),
#             )
#             response = llm.invoke([HumanMessage(content=prompt)])
#             followup_question = response.content.strip()
#         except Exception as e:
#             # LLM failed — use a safe fallback so the user still gets a question
#             print(f"⚠️ Follow-up LLM call failed: {e}")
#             followup_question = _fallback_question(missing, state.get("language_detected"))

#         state["followup"] = {
#             "status": "incomplete",
#             "missing_fields": missing,
#             "collected_fields": {
#                 "service_type":    state.get("service_type"),
#                 "location":        state.get("location"),
#                 "time_preference": state.get("time_preference"),
#             },
#             "followup_question": followup_question,
#         }
#         state["agent_logs"].append(create_agent_log(
#             agent_name="followup_agent",
#             input_summary=f"Missing fields: {missing}",
#             output_summary=f"Asked follow-up: {followup_question}",
#         ))
#         return state

#     # ── Path 2: booking exists → schedule notifications ────────────────────
#     booking = state.get("booking")
#     if not booking:
#         state["agent_logs"].append(create_error_log(
#             "followup_agent",
#             "No booking and no missing fields — unexpected state."
#         ))
#         return state

#     state["followup"] = {
#         "status": "complete",
#         "booking_id": booking["booking_id"],
#         "reminder_scheduled": "1 hour before appointment",
#         "reminder_message": (
#             f"Reminder: Your {state['service_type']} with {booking['provider_name']} "
#             f"is in 1 hour at {state['location']}!"
#         ),
#         "status_update": "Provider notified. Booking CONFIRMED.",
#         "completion_confirmation": "After service, you will receive a rating request and digital receipt.",
#         "simulated_notifications": [
#             {
#                 "type": "SMS",
#                 "recipient": "customer",
#                 "message": (
#                     f"Booking confirmed! {state['service_type']} - {booking['slot_time']} - "
#                     f"{booking['provider_name']} - ID: {booking['booking_id']}"
#                 ),
#                 "scheduled_at": "immediately",
#             },
#             {
#                 "type": "SMS",
#                 "recipient": "provider",
#                 "message": (
#                     f"New job: {state['service_type']} at {state['location']} "
#                     f"{booking['slot_time']}. ID: {booking['booking_id']}"
#                 ),
#                 "scheduled_at": "immediately",
#             },
#             {
#                 "type": "reminder",
#                 "recipient": "customer",
#                 "message": "Your appointment is in 1 hour!",
#                 "scheduled_at": "1 hour before slot",
#             },
#         ],
#     }

#     state["agent_logs"].append(create_agent_log(
#         agent_name="followup_agent",
#         input_summary=f"Booking: {booking['booking_id']}",
#         output_summary=f"3 notifications scheduled. Status: complete",
#     ))
#     return state


# def _fallback_question(missing: list[str], language: str | None) -> str:
#     """Hard-coded fallback questions used when the LLM call fails."""
#     lang = language or "roman_urdu"

#     questions = {
#         "roman_urdu": {
#             ("service_type",): "Aap kaunsi service chahte hain?",
#             ("location",): "Aapka address kya hai?",
#             ("time_preference",): "Service kab chahiye?",
#             ("service_type", "location"): "Aap kaunsi service chahte hain aur kahan se?",
#             ("service_type", "time_preference"): "Aap kaunsi service chahte hain aur kab?",
#             ("location", "time_preference"): "Aapka address kya hai aur kab chahiye?",
#             ("service_type", "location", "time_preference"): "Kaunsi service, kahan se, aur kab chahiye?",
#         },
#         "english": {
#             ("service_type",): "What service do you need?",
#             ("location",): "What's your address?",
#             ("time_preference",): "When do you need it?",
#             ("service_type", "location"): "What service do you need and where?",
#             ("service_type", "time_preference"): "What service do you need and when?",
#             ("location", "time_preference"): "What's your address and when do you need it?",
#             ("service_type", "location", "time_preference"): "What service, where, and when do you need it?",
#         },
#         "urdu": {
#             ("service_type",): "آپ کونسی سروس چاہتے ہیں؟",
#             ("location",): "آپ کا پتہ کیا ہے؟",
#             ("time_preference",): "سروس کب چاہیے؟",
#             ("service_type", "location"): "آپ کونسی سروس چاہتے ہیں اور کہاں سے؟",
#             ("service_type", "time_preference"): "آپ کونسی سروس چاہتے ہیں اور کب؟",
#             ("location", "time_preference"): "آپ کا پتہ کیا ہے اور کب چاہیے؟",
#             ("service_type", "location", "time_preference"): "کونسی سروس، کہاں سے، اور کب چاہیے؟",
#         },
#     }

#     lang_map = questions.get(lang, questions["roman_urdu"])
#     key = tuple(missing)
#     return lang_map.get(key, lang_map[("service_type", "location", "time_preference")])





# import os
# from dotenv import load_dotenv
# from langchain_openai import AzureChatOpenAI
# from langsmith import traceable
# from pydantic import BaseModel
# from typing import Optional

# from models.schemas import AgentState
# from utils.logger import create_agent_log, create_error_log

# load_dotenv()

# # ── LLM ──────────────────────────────────────────────────────────────────────

# _llm = AzureChatOpenAI(
#     azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
#     api_key=os.getenv("AZURE_OPENAI_API_KEY"),
#     azure_deployment=os.getenv("AZURE_OPENAI_MODEL_NAME"),
#     api_version=os.getenv("AZURE_OPENAI_VERSION"),
#     temperature=0,
#     max_tokens=300,
# )

# # ── Structured output schema ──────────────────────────────────────────────────

# class IntentOutput(BaseModel):
#     service_type: Optional[str] = None
#     location: Optional[str] = None
#     time_preference: Optional[str] = None
#     language_detected: Optional[str] = None   # "urdu" | "roman_urdu" | "english"

# # ── System prompt ─────────────────────────────────────────────────────────────

# _SYSTEM_PROMPT = """You are an intent parser for a Pakistani service booking app.
# Extract structured information from user input.

# Extract these fields:
# - service_type: one of [AC Technician, Plumber, Electrician, Home Tutor, Beautician,
#   Carpenter, Painter, CCTV Installer] or null
# - location: area name in Islamabad/Rawalpindi (e.g. G-13, F-10, Bahria Town) or null
# - time_preference: normalized string like "tomorrow morning", "today afternoon",
#   "kal subah", "kal 8 baje raat" or null
# - language_detected: detect the language of the user's input as one of:
#   "urdu" (Urdu script), "roman_urdu" (Urdu in English letters),
#   or "english" (plain English).

# IMPORTANT: If the user message contains a line stating that the language has been
# pre-set, you MUST use that exact value for language_detected. Do not infer language
# from the text in that case."""

# _agent = _llm.with_structured_output(IntentOutput)


# @traceable(name="intent-agent", run_type="chain")
# def run_intent_agent(state: AgentState) -> AgentState:
#     # If language was explicitly set upstream (e.g. by the audio endpoint's
#     # required `lang` field), that's authoritative and is never overwritten.
#     preset_language = state.get("language_detected")
#     language_is_authoritative = bool(preset_language)

#     extra_hint = ""
#     if preset_language:
#         extra_hint = (
#             f"\n\nThe user has explicitly chosen language: '{preset_language}'. "
#             "Use this exact value for language_detected. Respond using vocabulary "
#             "and locations consistent with this language."
#         )

#     user_message = state["raw_input"] + extra_hint
#     messages = [
#         {"role": "system", "content": _SYSTEM_PROMPT},
#         {"role": "user", "content": user_message},
#     ]

#     try:
#         parsed: IntentOutput = _agent.invoke(messages)

#         print(
#             f"INTENT PARSED: service={parsed.service_type}, "
#             f"location={parsed.location}, time={parsed.time_preference}, "
#             f"lang_parsed={parsed.language_detected}, "
#             f"lang_preset={preset_language}"
#         )

#         state["service_type"]    = parsed.service_type
#         state["location"]        = parsed.location
#         state["time_preference"] = parsed.time_preference

#         # Preset language always wins. Only fall through to LLM-detected when
#         # nothing was pre-seeded (i.e. text endpoint with no language hint).
#         if language_is_authoritative:
#             state["language_detected"] = preset_language
#         else:
#             state["language_detected"] = parsed.language_detected or "english"

#         state["agent_logs"].append(create_agent_log(
#             agent_name="intent_agent",
#             input_summary=f"Raw: {state['raw_input'][:80]}",
#             output_summary=(
#                 f"service={state['service_type']}, location={state['location']}, "
#                 f"time={state['time_preference']}, lang={state['language_detected']}"
#             ),
#         ))

#     except Exception as e:
#         state["service_type"] = None
#         state["agent_logs"].append(create_error_log("intent_agent", str(e)))

#     return state



# import os
# from dotenv import load_dotenv
# from langchain_openai import AzureChatOpenAI
# from langchain_core.messages import SystemMessage, HumanMessage
# from langsmith import traceable

# from models.schemas import AgentState
# from utils.logger import create_agent_log, create_error_log

# load_dotenv()

# _llm = AzureChatOpenAI(
#     azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
#     api_key=os.getenv("AZURE_OPENAI_API_KEY"),
#     azure_deployment=os.getenv("AZURE_OPENAI_MODEL_NAME"),
#     api_version=os.getenv("AZURE_OPENAI_VERSION"),
#     temperature=0.3,
#     max_tokens=150,
# )


# def _score_provider(p: dict) -> float:
#     rating_score   = (p["rating"] / 5.0) * 0.4
#     distance_score = (1 - min(p["distance_km"], 10) / 10) * 0.4
#     avail_score    = 0.2 if p["available"] else 0.0
#     return round(rating_score + distance_score + avail_score, 4)


# @traceable(name="matching-agent", run_type="chain")
# def run_matching_agent(state: AgentState) -> AgentState:
#     providers = state.get("providers_found", [])
#     if not providers:
#         state["agent_logs"].append(create_error_log("matching_agent", "No providers to rank"))
#         return state

#     for p in providers:
#         p["score"] = _score_provider(p)

#     ranked = sorted(providers, key=lambda p: p["score"], reverse=True)
#     state["ranked_providers"] = ranked
#     best = dict(ranked[0])

#     try:
#         response = _llm.invoke([
#             SystemMessage(content="You explain provider selections in 1-2 friendly sentences."),
#             HumanMessage(content=(
#                 f"Provider: {best['name']}, Rating: {best['rating']}/5, "
#                 f"Distance: {best['distance_km']}km, Available: {best['available']}, "
#                 f"Score: {best['score']:.2f}. Why is this the best choice?"
#             )),
#         ])
#         best["reasoning"] = response.content.strip()
#     except Exception:
#         best["reasoning"] = f"Top-ranked by rating, proximity, and availability. (score={best['score']:.2f})"

#     state["selected_provider"] = best

#     state["agent_logs"].append(create_agent_log(
#         agent_name="matching_agent",
#         input_summary=f"Ranking {len(providers)} providers",
#         output_summary=f"Selected: {best['name']} (score={best['score']:.2f}, dist={best['distance_km']}km)",
#     ))
#     return state



# import sqlite3
# import json
# from datetime import datetime

# DB_PATH = "khadamat.db"

# def get_connection():
#     conn = sqlite3.connect(DB_PATH)
#     conn.row_factory = sqlite3.Row
#     return conn

# def init_db():
#     conn = get_connection()
#     cursor = conn.cursor()
    
#     # existing bookings table
#     cursor.execute("""
#         CREATE TABLE IF NOT EXISTS bookings (
#             id INTEGER PRIMARY KEY AUTOINCREMENT,
#             booking_id TEXT UNIQUE,
#             data TEXT,
#             created_at TEXT
#         )
#     """)
    
#     # new session context table
#     cursor.execute("""
#         CREATE TABLE IF NOT EXISTS session_context (
#             session_id TEXT PRIMARY KEY,
#             raw_input TEXT,
#             service_type TEXT,
#             location TEXT,
#             time_preference TEXT,
#             language_detected TEXT,
#             updated_at TEXT
#         )
#     """)
#     conn.commit()
#     conn.close()

# def save_session_context(session_id: str, state: dict):
#     conn = get_connection()
#     conn.execute("""
#         INSERT INTO session_context (session_id, raw_input, service_type, location, time_preference, language_detected, updated_at)
#         VALUES (?, ?, ?, ?, ?, ?, ?)
#         ON CONFLICT(session_id) DO UPDATE SET
#             raw_input=excluded.raw_input,
#             service_type=excluded.service_type,
#             location=excluded.location,
#             time_preference=excluded.time_preference,
#             language_detected=excluded.language_detected,
#             updated_at=excluded.updated_at
#     """, (
#         session_id,
#         state.get("raw_input"),
#         state.get("service_type"),
#         state.get("location"),
#         state.get("time_preference"),
#         state.get("language_detected"),
#         datetime.now().isoformat(),
#     ))
#     conn.commit()
#     conn.close()

# def get_session_context(session_id: str) -> dict | None:
#     conn = get_connection()
#     row = conn.execute(
#         "SELECT * FROM session_context WHERE session_id = ?", (session_id,)
#     ).fetchone()
#     conn.close()
#     return dict(row) if row else None

# def delete_session_context(session_id: str):
#     conn = get_connection()
#     conn.execute("DELETE FROM session_context WHERE session_id = ?", (session_id,))
#     conn.commit()
#     conn.close()

# def get_all_bookings() -> list:
#     conn = get_connection()
#     rows = conn.execute(
#         "SELECT data FROM bookings ORDER BY created_at DESC"
#     ).fetchall()
#     conn.close()
#     return [json.loads(row["data"]) for row in rows]


# def save_booking(booking: dict):
#     conn = get_connection()
#     conn.execute(
#         "INSERT OR REPLACE INTO bookings (booking_id, data, created_at) VALUES (?, ?, ?)",
#         (booking["booking_id"], json.dumps(booking), booking["created_at"]),
#     )
#     conn.commit()
#     conn.close()



# import os
# import random
# from datetime import datetime, timedelta
# from dotenv import load_dotenv
# from langchain_openai import AzureChatOpenAI
# from langsmith import traceable
# from pydantic import BaseModel, Field
# from typing import Optional

# from models.schemas import AgentState
# from utils.logger import create_agent_log, create_error_log

# load_dotenv()

# # ── LLM ──────────────────────────────────────────────────────────────────────

# _llm = AzureChatOpenAI(
#     azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
#     api_key=os.getenv("AZURE_OPENAI_API_KEY"),
#     azure_deployment=os.getenv("AZURE_OPENAI_MODEL_NAME"),
#     api_version=os.getenv("AZURE_OPENAI_VERSION"),
#     temperature=0,
#     max_tokens=200,
# )


# # ── Structured output schema ──────────────────────────────────────────────────

# class SlotResolution(BaseModel):
#     """Resolved appointment slot."""
#     day: str = Field(
#         description="One of: 'today', 'tomorrow', 'day_after_tomorrow', or a "
#                     "specific date in YYYY-MM-DD format if user named a date."
#     )
#     time_24h: str = Field(
#         description="The appointment start time in 24-hour HH:MM format "
#                     "(e.g. '09:00', '14:30', '19:00')."
#     )
#     time_display: str = Field(
#         description="Human-readable time in 12-hour format with AM/PM "
#                     "(e.g. '9:00 AM', '2:30 PM', '7:00 PM')."
#     )
#     user_was_specific: bool = Field(
#         description="True if the user mentioned an exact time (e.g. '3pm', "
#                     "'11 baje', '8 baje raat'). False if they only said a vague "
#                     "period (e.g. 'morning', 'subah', 'evening') and we picked a default."
#     )
#     confidence: float = Field(
#         description="0.0 to 1.0 — how confident the parse is.",
#         ge=0.0, le=1.0,
#     )


# # ── System prompt ─────────────────────────────────────────────────────────────

# _SYSTEM_PROMPT = """You are a time-slot resolver for a Pakistani home-services booking app.

# Your job: convert the user's free-form time preference (in Urdu, Roman Urdu, or English)
# into a concrete appointment slot.

# CRITICAL RULES:
# 1. If the user mentions a SPECIFIC TIME (e.g. "3pm", "11 baje", "8 baje raat", "around 4",
#    "Tuesday 6pm"), use EXACTLY that time. Do not round to a default slot.
#    Set user_was_specific = true.

# 2. If the user only gives a VAGUE PERIOD (e.g. "morning", "subah", "afternoon", "dopahar",
#    "evening", "shaam", "night", "raat"), pick a sensible default within that period:
#      - morning / subah        → 10:00 AM
#      - afternoon / dopahar    → 2:00 PM
#      - evening / shaam        → 5:00 PM
#      - night / raat           → 7:00 PM
#    Set user_was_specific = false.

# 3. If the user says nothing about time, default to tomorrow 10:00 AM. user_was_specific = false.

# 4. Service operating window is 8:00 AM to 9:00 PM. If the user requests something outside
#    that window, snap to the nearest in-window time and set user_was_specific = false.

# 5. Day resolution:
#    - "today" / "aaj"          → today
#    - "tomorrow" / "kal"       → tomorrow  (default if nothing said)
#    - "day after tomorrow" / "parsoon" → day_after_tomorrow
#    - Specific weekday or date → return YYYY-MM-DD

# ROMAN URDU TIME EXPRESSIONS REFERENCE:
# - "subah" = morning, "dopahar" = afternoon, "shaam" = evening, "raat" = night
# - "X baje" = X o'clock (e.g. "8 baje" = 8:00)
# - "kal" = tomorrow, "aaj" = today, "parsoon" = day after tomorrow
# - "abhi" / "abi" = now/right away → soonest available in-window time today

# EXAMPLES:
# - "kal subah" → day=tomorrow, time=10:00 AM, user_was_specific=false
# - "kal 8 baje raat" → day=tomorrow, time=8:00 PM (20:00), user_was_specific=true
# - "aaj 3pm" → day=today, time=3:00 PM, user_was_specific=true
# - "morning" → day=tomorrow (default), time=10:00 AM, user_was_specific=false
# - "around 4 in the afternoon tomorrow" → day=tomorrow, time=4:00 PM, user_was_specific=true
# - "abhi" → day=today, time=(soonest in-window), user_was_specific=false
# """

# _slot_resolver = _llm.with_structured_output(SlotResolution)


# def _resolve_slot_with_llm(time_preference: str, language: str = "english") -> SlotResolution:
#     """LLM-based slot resolution. Falls back to a safe default on any failure."""
#     today_str = datetime.now().strftime("%Y-%m-%d (%A)")
#     user_msg = (
#         f"Today is {today_str}.\n"
#         f"User language: {language}\n"
#         f"User's time preference: \"{time_preference or '(not specified)'}\"\n\n"
#         "Resolve this to a concrete slot."
#     )
#     messages = [
#         {"role": "system", "content": _SYSTEM_PROMPT},
#         {"role": "user",   "content": user_msg},
#     ]
#     return _slot_resolver.invoke(messages)


# def _safe_fallback_slot() -> SlotResolution:
#     """Hard-coded default used if the LLM call fails."""
#     return SlotResolution(
#         day="tomorrow",
#         time_24h="10:00",
#         time_display="10:00 AM",
#         user_was_specific=False,
#         confidence=0.5,
#     )


# def _format_slot_for_booking(resolution: SlotResolution) -> str:
#     day_label = {
#         "today":              "Today",
#         "tomorrow":           "Tomorrow",
#         "day_after_tomorrow": "Day after tomorrow",
#     }.get(resolution.day, resolution.day)
#     return f"{day_label}, {resolution.time_display}"


# # ── Agent ─────────────────────────────────────────────────────────────────────

# @traceable(name="booking-agent", run_type="chain")
# def run_booking_agent(state: AgentState) -> AgentState:
#     selected = state.get("selected_provider")

#     print(
#         f"   booking_agent  provider={selected['name'] if selected else 'NONE'}  "
#         f"confirmed={state.get('is_booking_confirmed', False)}  "
#         f"time_pref={state.get('time_preference')!r}  "
#         f"lang={state.get('language_detected')}"
#     )

#     if not selected:
#         state["agent_logs"].append(create_error_log("booking_agent", "No selected provider"))
#         return state

#     if not state.get("is_booking_confirmed", False):
#         state["agent_logs"].append(
#             create_error_log("booking_agent", "User has not confirmed booking")
#         )
#         return state

#     time_preference = state.get("time_preference") or ""
#     language        = state.get("language_detected") or "english"

#     # ── LLM-resolved slot ────────────────────────────────────────────────────
#     try:
#         resolution = _resolve_slot_with_llm(time_preference, language)
#         print(
#             f"   booking_agent  ⏰ slot={resolution.day} {resolution.time_display}  "
#             f"specific={resolution.user_was_specific}  confidence={resolution.confidence}"
#         )
#     except Exception as e:
#         print(f"   booking_agent  ⚠ slot LLM failed — using fallback: {e}")
#         resolution = _safe_fallback_slot()
#         state["agent_logs"].append(create_error_log(
#             "booking_agent",
#             f"Slot LLM failed ({e}), used fallback {resolution.time_display}",
#         ))

#     slot_display = _format_slot_for_booking(resolution)
#     booking_id   = f"BK-{random.randint(100000, 999999)}"

#     # ── Build localized confirmation message ─────────────────────────────────
#     if language == "urdu":
#         confirmation = (
#             f"آپ کی بکنگ {selected['name']} کے ساتھ {slot_display} کو "
#             f"{state['location']} میں کنفرم ہو گئی ہے۔ "
#             f"رابطہ: {selected['phone']}"
#         )
#     elif language == "roman_urdu":
#         confirmation = (
#             f"Aap ki booking {selected['name']} ke saath {slot_display} ko "
#             f"{state['location']} mein confirm ho gayi hai. "
#             f"Contact: {selected['phone']}"
#         )
#     else:
#         confirmation = (
#             f"Your booking with {selected['name']} is confirmed for {slot_display} "
#             f"in {state['location']}. Provider contact: {selected['phone']}"
#         )

#     booking = {
#         "booking_id":           booking_id,
#         "provider_id":          selected["id"],
#         "provider_name":        selected["name"],
#         "provider_phone":       selected["phone"],
#         "service_type":         state["service_type"],
#         "location":             state["location"],
#         "slot_time":            slot_display,
#         "slot_time_24h":        resolution.time_24h,
#         "slot_day":             resolution.day,
#         "user_specified_time":  resolution.user_was_specific,
#         "status":               "CONFIRMED",
#         "confirmation_message": confirmation,
#         "created_at":           datetime.now().isoformat(),
#         "agent_logs_snapshot":  list(state["agent_logs"]),
#     }

#     try:
#         from tools.mock_db import save_booking
#         save_booking(booking)
#     except Exception as e:
#         state["agent_logs"].append(create_error_log("booking_agent", f"Save failed: {e}"))
#         return state

#     state["booking"] = booking

#     print(f"   booking_agent  ✔ booking created  id={booking_id}  slot={slot_display}")

#     state["agent_logs"].append(create_agent_log(
#         agent_name="booking_agent",
#         input_summary=(
#             f"Provider: {selected['name']}, time_pref: '{time_preference}', "
#             f"lang: {language}"
#         ),
#         output_summary=(
#             f"Booking {booking_id} CONFIRMED for {slot_display} "
#             f"(user_was_specific={resolution.user_was_specific})"
#         ),
#     ))
#     return state