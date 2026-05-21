
# import os
# import tempfile
# import traceback
# from contextlib import asynccontextmanager
# from dotenv import load_dotenv
# from fastapi import FastAPI, HTTPException, UploadFile, File, Form
# from fastapi.middleware.cors import CORSMiddleware
# from models.schemas import AgentState, ServiceRequest

# load_dotenv()


# # ---------------------------------------------------------------------------
# # Lifespan — pre-load Whisper at startup so the first request is fast
# # ---------------------------------------------------------------------------
# @asynccontextmanager
# async def lifespan(app: FastAPI):
#     from tools.whisper_tool import _load_model
#     print("⏳ Pre-loading Whisper model at startup...")
#     try:
#         _load_model()
#         print("✅ Whisper model ready.")
#     except Exception as e:
#         print(f"⚠️ Whisper pre-load failed (will retry on first request): {e}")
#         traceback.print_exc()
#     yield


# app = FastAPI(
#     title="UstaadNow AI ",
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

# REQUIRED_SLOTS = ("service_type", "location", "time_preference")

# from tools.whisper_tool import transcribe_audio


# # ---------------------------------------------------------------------------
# # Helper — merge prior session context with the new pipeline result
# # ---------------------------------------------------------------------------
# def _merge_session_context(result: dict, prior_ctx: dict | None) -> dict:
#     """
#     Structured slot merge: for each required slot, prefer the NEW extraction;
#     fall back to whatever was previously collected for this session.

#     This replaces the older approach of concatenating strings and re-parsing,
#     which produced bad intent extraction on follow-up turns.
#     """
#     if not prior_ctx:
#         return result

#     for field in REQUIRED_SLOTS:
#         if not result.get(field) and prior_ctx.get(field):
#             result[field] = prior_ctx[field]
#             print(f"🔁 Merged from session: {field}={prior_ctx[field]}")

#     # Preserve language preference across turns if the new turn didn't detect one
#     if not result.get("language_detected") and prior_ctx.get("language_detected"):
#         result["language_detected"] = prior_ctx["language_detected"]

#     return result


# def _has_all_slots(result: dict) -> bool:
#     return all(result.get(f) for f in REQUIRED_SLOTS)


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
#     from tools.mock_db import get_session_context, delete_session_context, save_session_context

#     try:
#         user_input = body.get("input")
#         session_id = body.get("session_id")

#         if not user_input:
#             raise HTTPException(status_code=400, detail="Request body must contain 'input' field")

#         print(f"\n📥 /api/request  session_id={session_id}  input={user_input!r}")

#         # ── Run pipeline on the NEW input only (no string concatenation) ────
#         result = run_pipeline(user_input, session_id=session_id)

#         # ── Structured slot merge with prior session context ─────────────────
#         if session_id:
#             prior_ctx = get_session_context(session_id)
#             result = _merge_session_context(result, prior_ctx)

#             if not result.get("language_detected") and prior_ctx.get("language_detected"):
#                 result["language_detected"] = prior_ctx["language_detected"]

#             # If the merge filled in everything that was missing but no booking
#             # yet exists, re-run the pipeline now that we have full state.
#             if _has_all_slots(result) and not result.get("booking"):
#                 print("✅ All slots filled after merge — re-running pipeline with full context")
#                 # Rebuild a clean prompt from the structured slots
#                 composed = (
#                     f"{result['service_type']} chahiye "
#                     f"{result['location']} mein "
#                     f"{result['time_preference']}"
#                 )
#                 result = run_pipeline(composed, session_id=session_id)
#                 # Re-merge in case the second pass produced new None values
#                 result = _merge_session_context(result, prior_ctx)

#         # ── Persist or clear session context ────────────────────────────────
#         if session_id:
#             followup = result.get("followup") or {}
#             if followup.get("status") == "incomplete":
#                 save_session_context(session_id, result)
#             elif result.get("booking"):
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
# # @app.post("/api/request/audio")
# # async def handle_audio_request(
# #     audio: UploadFile = File(...),
# #     session_id: str = Form(None),
# # ):
# #     from graph import run_pipeline
# #     from tools.mock_db import get_session_context, delete_session_context, save_session_context

# #     print(
# #         f"\n📥 /api/request/audio  filename={audio.filename}  "
# #         f"content_type={audio.content_type}  session_id={session_id}"
# #     )

# #     # ── 1. Validate content type ────────────────────────────────────────────
# #     content_type = (audio.content_type or "").lower().split(";")[0].strip()
# #     if content_type not in SUPPORTED_AUDIO_TYPES:
# #         raise HTTPException(
# #             status_code=415,
# #             detail=(
# #                 f"Unsupported audio type: '{content_type}'. "
# #                 f"Supported types: {', '.join(SUPPORTED_AUDIO_TYPES.keys())}"
# #             ),
# #         )
# #     ext = SUPPORTED_AUDIO_TYPES[content_type]

# #     # ── 2. Write upload to a temp file ──────────────────────────────────────
# #     tmp_path = None
# #     try:
# #         with tempfile.NamedTemporaryFile(suffix=ext, delete=False) as tmp:
# #             tmp_path = tmp.name
# #             contents = await audio.read()
# #             if not contents:
# #                 raise HTTPException(status_code=400, detail="Uploaded audio file is empty.")
# #             tmp.write(contents)
# #         print(f"💾 Saved upload  ({len(contents)} bytes)  →  {tmp_path}")
# #     except HTTPException:
# #         raise
# #     except Exception as e:
# #         print("\n" + "=" * 70)
# #         print("❌ ERROR while saving audio upload")
# #         print("=" * 70)
# #         traceback.print_exc()
# #         print("=" * 70 + "\n")
# #         raise HTTPException(status_code=500, detail=f"Failed to read audio upload: {e}")

# #     # ── 3. Transcribe ────────────────────────────────────────────────────────
# #     try:
# #         stt_result        = transcribe_audio(tmp_path)
# #         transcript        = stt_result["transcript"]
# #         language_detected = stt_result["language_detected"]
# #     except Exception as e:
# #         print("\n" + "=" * 70)
# #         print("❌ ERROR during transcription")
# #         print("=" * 70)
# #         traceback.print_exc()
# #         print("=" * 70 + "\n")
# #         raise HTTPException(status_code=500, detail=f"Transcription failed: {e}")
# #     finally:
# #         if tmp_path:
# #             try:
# #                 os.unlink(tmp_path)
# #             except OSError:
# #                 pass

# #     if not transcript:
# #         raise HTTPException(
# #             status_code=422,
# #             detail="Could not transcribe any speech from the audio. Please speak clearly and try again.",
# #         )

# #     # ── 4. Run pipeline on transcript (no string merge — pure new input) ────
# #     try:
# #         result = run_pipeline(transcript, session_id=session_id)
# #     except Exception as e:
# #         print("\n" + "=" * 70)
# #         print("❌ ERROR inside LangGraph pipeline")
# #         print("=" * 70)
# #         traceback.print_exc()
# #         print("=" * 70 + "\n")
# #         raise HTTPException(status_code=500, detail=f"Pipeline error: {e}")

# #     # ── 5. Structured slot merge with prior session context ─────────────────
# #     prior_ctx = None
# #     if session_id:
# #         prior_ctx = get_session_context(session_id)
# #         result = _merge_session_context(result, prior_ctx)

# #         # If merge completed the slot set but no booking yet → re-run downstream
# #         if _has_all_slots(result) and not result.get("booking"):
# #             print("✅ All slots filled after merge — re-running pipeline with full context")
# #             composed = (
# #                 f"{result['service_type']} chahiye "
# #                 f"{result['location']} mein "
# #                 f"{result['time_preference']}"
# #             )
# #             try:
# #                 result = run_pipeline(composed, session_id=session_id)
# #                 result = _merge_session_context(result, prior_ctx)
# #             except Exception as e:
# #                 print(f"⚠️ Re-run after merge failed: {e}")
# #                 traceback.print_exc()
# #                 # Fall through with whatever we have

# #     # ── 6. Persist or clear session context ──────────────────────────────────
# #     if session_id:
# #         followup = result.get("followup") or {}
# #         if followup.get("status") == "incomplete":
# #             save_session_context(session_id, result)
# #         elif result.get("booking"):
# #             delete_session_context(session_id)

# #     # ── 7. Attach STT metadata ───────────────────────────────────────────────
# #     result["transcript"]        = transcript
# #     result["language_detected"] = result.get("language_detected") or language_detected
# #     result["whisper_language"]  = stt_result["whisper_language"]
# #     result["stt_confidence"]    = stt_result["confidence"]

# #     return result


# # Add near SUPPORTED_AUDIO_TYPES
# SUPPORTED_LANGUAGES = {"ur", "en"}
# LANG_TO_LABEL = {"ur": "urdu", "en": "english"}


# @app.post("/api/request/audio")
# async def handle_audio_request(
#     audio: UploadFile = File(...),
#     lang: str = Form(...),                 # REQUIRED: "ur" or "en"
#     session_id: str = Form(None),
# ):
#     from graph import run_pipeline
#     from tools.mock_db import get_session_context, delete_session_context, save_session_context

#     print(
#         f"\n📥 /api/request/audio  filename={audio.filename}  "
#         f"content_type={audio.content_type}  lang={lang}  session_id={session_id}"
#     )

#     # ── 0. Validate language ────────────────────────────────────────────────
#     lang = (lang or "").strip().lower()
#     if lang not in SUPPORTED_LANGUAGES:
#         raise HTTPException(
#             status_code=400,
#             detail=f"Invalid 'lang' value: '{lang}'. Must be one of: {sorted(SUPPORTED_LANGUAGES)}",
#         )
#     language_label = LANG_TO_LABEL[lang]

#     # ── 1. Validate audio content type ──────────────────────────────────────
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

#     # ── 3. Transcribe with the user-specified language ──────────────────────
#     try:
#         stt_result = transcribe_audio(tmp_path, language=lang)
#         transcript = stt_result["transcript"]
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

#     # ── 4. Run pipeline with language pinned ────────────────────────────────
#     try:
#         result = run_pipeline(transcript, session_id=session_id, language=language_label)
#     except Exception as e:
#         print("\n" + "=" * 70)
#         print("❌ ERROR inside LangGraph pipeline")
#         print("=" * 70)
#         traceback.print_exc()
#         print("=" * 70 + "\n")
#         raise HTTPException(status_code=500, detail=f"Pipeline error: {e}")

#     # User's lang choice is authoritative — overwrite anything pipeline produced
#     result["language_detected"] = language_label

#     # ── 5. Structured slot merge with prior session context ─────────────────
#     prior_ctx = None
#     if session_id:
#         prior_ctx = get_session_context(session_id)
#         result = _merge_session_context(result, prior_ctx)
#         result["language_detected"] = language_label   # lang choice still wins

#         if _has_all_slots(result) and not result.get("booking"):
#             print("✅ All slots filled after merge — re-running pipeline with full context")
#             composed = (
#                 f"{result['service_type']} chahiye "
#                 f"{result['location']} mein "
#                 f"{result['time_preference']}"
#             )
#             try:
#                 result = run_pipeline(composed, session_id=session_id, language=language_label)
#                 result = _merge_session_context(result, prior_ctx)
#                 result["language_detected"] = language_label
#             except Exception as e:
#                 print(f"⚠️ Re-run after merge failed: {e}")
#                 traceback.print_exc()

#     # ── 6. Persist or clear session context ──────────────────────────────────
#     if session_id:
#         followup = result.get("followup") or {}
#         if followup.get("status") == "incomplete":
#             save_session_context(session_id, result)
#         elif result.get("booking"):
#             delete_session_context(session_id)

#     # ── 7. Attach STT metadata ───────────────────────────────────────────────
#     result["transcript"]        = transcript
#     result["language_detected"] = language_label
#     result["lang"]              = lang                       # raw "ur"/"en" echoed back
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






import os
import tempfile
import traceback
from contextlib import asynccontextmanager
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from models.schemas import AgentState, ServiceRequest

load_dotenv()


# ---------------------------------------------------------------------------
# Lifespan — pre-load Whisper at startup so the first request is fast
# ---------------------------------------------------------------------------
@asynccontextmanager
async def lifespan(app: FastAPI):
    from tools.whisper_tool import _load_model
    print("⏳ Pre-loading Whisper model at startup...")
    try:
        _load_model()
        print("✅ Whisper model ready.")
    except Exception as e:
        print(f"⚠️ Whisper pre-load failed (will retry on first request): {e}")
        traceback.print_exc()
    yield


app = FastAPI(
    title="UstaadNow AI",
    description="AI-powered informal economy service booking for Pakistan",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SUPPORTED_AUDIO_TYPES: dict[str, str] = {
    "audio/wav":                ".wav",
    "audio/x-wav":              ".wav",
    "audio/wave":               ".wav",
    "audio/mpeg":               ".mp3",
    "audio/mp3":                ".mp3",
    "audio/mp4":                ".m4a",
    "audio/x-m4a":              ".m4a",
    "audio/ogg":                ".ogg",
    "audio/webm":               ".webm",
    "audio/flac":               ".flac",
    "audio/x-flac":             ".flac",
    "application/octet-stream": ".wav",
}

SUPPORTED_LANGUAGES = {"ur", "en"}
LANG_TO_LABEL       = {"ur": "urdu", "en": "english"}
REQUIRED_SLOTS      = ("service_type", "location", "time_preference")

from tools.whisper_tool import transcribe_audio


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _ensure_pricing(result: dict) -> dict:
    """
    Guarantee that selected_provider always carries a pricing dict.
    Called after every pipeline run and every slot merge/re-run.
    """
    from tools.mock_db import get_price_estimate
    selected = result.get("selected_provider")
    if selected and "pricing" not in selected:
        selected["pricing"] = get_price_estimate(
            service_type=result.get("service_type", ""),
            rating=selected.get("rating", 4.0),
        )
        result["selected_provider"] = selected
        print(f"💰 Attached pricing to selected_provider: {selected['pricing']['display']}")
    return result


def _merge_session_context(result: dict, prior_ctx: dict | None) -> dict:
    """
    Structured slot merge: for each required slot, prefer the NEW extraction;
    fall back to whatever was previously collected for this session.
    Also preserves selected_provider (and its pricing) across turns.
    """
    if not prior_ctx:
        return result

    for field in REQUIRED_SLOTS:
        if not result.get(field) and prior_ctx.get(field):
            result[field] = prior_ctx[field]
            print(f"🔁 Merged from session: {field}={prior_ctx[field]}")

    if not result.get("language_detected") and prior_ctx.get("language_detected"):
        result["language_detected"] = prior_ctx["language_detected"]

    # Preserve selected_provider (and its embedded pricing) across turns
    if not result.get("selected_provider") and prior_ctx.get("selected_provider"):
        result["selected_provider"] = prior_ctx["selected_provider"]
        print(
            f"🔁 Merged from session: selected_provider="
            f"{prior_ctx['selected_provider'].get('name')}"
        )

    return result


def _has_all_slots(result: dict) -> bool:
    return all(result.get(f) for f in REQUIRED_SLOTS)


def _compose_rerun_input(result: dict) -> str:
    """Build a clean natural-language prompt from structured slots for pipeline re-run."""
    return (
        f"{result['service_type']} chahiye "
        f"{result['location']} mein "
        f"{result['time_preference']}"
    )


# ===========================================================================
# Routes
# ===========================================================================

@app.get("/api/health")
async def health_check():
    return {"status": "ok"}


# ---------------------------------------------------------------------------
# Text pipeline — POST /api/request
# ---------------------------------------------------------------------------
@app.post("/api/request")
async def handle_request(body: dict):
    from graph import run_pipeline
    from tools.mock_db import get_session_context, delete_session_context, save_session_context

    try:
        user_input = body.get("input")
        session_id = body.get("session_id")

        if not user_input:
            raise HTTPException(status_code=400, detail="Request body must contain 'input' field")

        print(f"\n📥 /api/request  session_id={session_id}  input={user_input!r}")

        # ── Run pipeline on the new input ────────────────────────────────────
        result = run_pipeline(user_input, session_id=session_id)
        result = _ensure_pricing(result)

        # ── Structured slot merge with prior session context ─────────────────
        if session_id:
            prior_ctx = get_session_context(session_id)
            result    = _merge_session_context(result, prior_ctx)
            result    = _ensure_pricing(result)

            if not result.get("language_detected") and prior_ctx and prior_ctx.get("language_detected"):
                result["language_detected"] = prior_ctx["language_detected"]

            # If merge filled everything that was missing → re-run pipeline
            if _has_all_slots(result) and not result.get("booking"):
                print("✅ All slots filled after merge — re-running pipeline with full context")
                try:
                    result = run_pipeline(_compose_rerun_input(result), session_id=session_id)
                    result = _merge_session_context(result, prior_ctx)
                    result = _ensure_pricing(result)
                except Exception as e:
                    print(f"⚠️ Re-run after merge failed: {e}")
                    traceback.print_exc()

        # ── Persist or clear session context ─────────────────────────────────
        if session_id:
            followup = result.get("followup") or {}
            if followup.get("status") == "incomplete":
                save_session_context(session_id, result)
            elif result.get("booking"):
                delete_session_context(session_id)

        return result

    except HTTPException:
        raise
    except Exception as e:
        print("\n" + "=" * 70)
        print("❌ ERROR in /api/request")
        print("=" * 70)
        traceback.print_exc()
        print("=" * 70 + "\n")
        raise HTTPException(status_code=500, detail=str(e))


# ---------------------------------------------------------------------------
# Audio pipeline — POST /api/request/audio
# ---------------------------------------------------------------------------
@app.post("/api/request/audio")
async def handle_audio_request(
    audio:      UploadFile = File(...),
    lang:       str        = Form(...),   # REQUIRED: "ur" or "en"
    session_id: str        = Form(None),
):
    from graph import run_pipeline
    from tools.mock_db import get_session_context, delete_session_context, save_session_context

    print(
        f"\n📥 /api/request/audio  filename={audio.filename}  "
        f"content_type={audio.content_type}  lang={lang}  session_id={session_id}"
    )

    # ── 0. Validate language ─────────────────────────────────────────────────
    lang = (lang or "").strip().lower()
    if lang not in SUPPORTED_LANGUAGES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid 'lang' value: '{lang}'. Must be one of: {sorted(SUPPORTED_LANGUAGES)}",
        )
    language_label = LANG_TO_LABEL[lang]

    # ── 1. Validate audio content type ───────────────────────────────────────
    content_type = (audio.content_type or "").lower().split(";")[0].strip()
    if content_type not in SUPPORTED_AUDIO_TYPES:
        raise HTTPException(
            status_code=415,
            detail=(
                f"Unsupported audio type: '{content_type}'. "
                f"Supported types: {', '.join(SUPPORTED_AUDIO_TYPES.keys())}"
            ),
        )
    ext = SUPPORTED_AUDIO_TYPES[content_type]

    # ── 2. Write upload to a temp file ───────────────────────────────────────
    tmp_path = None
    try:
        with tempfile.NamedTemporaryFile(suffix=ext, delete=False) as tmp:
            tmp_path = tmp.name
            contents = await audio.read()
            if not contents:
                raise HTTPException(status_code=400, detail="Uploaded audio file is empty.")
            tmp.write(contents)
        print(f"💾 Saved upload  ({len(contents)} bytes)  →  {tmp_path}")
    except HTTPException:
        raise
    except Exception as e:
        print("\n" + "=" * 70)
        print("❌ ERROR while saving audio upload")
        print("=" * 70)
        traceback.print_exc()
        print("=" * 70 + "\n")
        raise HTTPException(status_code=500, detail=f"Failed to read audio upload: {e}")

    # ── 3. Transcribe with the user-specified language ────────────────────────
    try:
        stt_result = transcribe_audio(tmp_path, language=lang)
        transcript = stt_result["transcript"]
    except Exception as e:
        print("\n" + "=" * 70)
        print("❌ ERROR during transcription")
        print("=" * 70)
        traceback.print_exc()
        print("=" * 70 + "\n")
        raise HTTPException(status_code=500, detail=f"Transcription failed: {e}")
    finally:
        if tmp_path:
            try:
                os.unlink(tmp_path)
            except OSError:
                pass

    if not transcript:
        raise HTTPException(
            status_code=422,
            detail="Could not transcribe any speech from the audio. Please speak clearly and try again.",
        )

    # ── 4. Run pipeline with language pinned ─────────────────────────────────
    try:
        result = run_pipeline(transcript, session_id=session_id, language=language_label)
    except Exception as e:
        print("\n" + "=" * 70)
        print("❌ ERROR inside LangGraph pipeline")
        print("=" * 70)
        traceback.print_exc()
        print("=" * 70 + "\n")
        raise HTTPException(status_code=500, detail=f"Pipeline error: {e}")

    # User's lang choice is authoritative — overwrite anything pipeline produced
    result["language_detected"] = language_label
    result = _ensure_pricing(result)

    # ── 5. Structured slot merge with prior session context ───────────────────
    prior_ctx = None
    if session_id:
        prior_ctx = get_session_context(session_id)
        result    = _merge_session_context(result, prior_ctx)
        result["language_detected"] = language_label   # lang choice still wins
        result = _ensure_pricing(result)

        if _has_all_slots(result) and not result.get("booking"):
            print("✅ All slots filled after merge — re-running pipeline with full context")
            try:
                result = run_pipeline(
                    _compose_rerun_input(result),
                    session_id=session_id,
                    language=language_label,
                )
                result = _merge_session_context(result, prior_ctx)
                result["language_detected"] = language_label
                result = _ensure_pricing(result)
            except Exception as e:
                print(f"⚠️ Re-run after merge failed: {e}")
                traceback.print_exc()

    # ── 6. Persist or clear session context ──────────────────────────────────
    if session_id:
        followup = result.get("followup") or {}
        if followup.get("status") == "incomplete":
            save_session_context(session_id, result)
        elif result.get("booking"):
            delete_session_context(session_id)

    # ── 7. Attach STT metadata ────────────────────────────────────────────────
    result["transcript"]        = transcript
    result["language_detected"] = language_label
    result["lang"]              = lang
    result["whisper_language"]  = stt_result["whisper_language"]
    result["stt_confidence"]    = stt_result["confidence"]

    return result


# ---------------------------------------------------------------------------
# Bookings
# ---------------------------------------------------------------------------
@app.get("/api/bookings")
async def get_bookings():
    from tools.mock_db import get_all_bookings
    return get_all_bookings()


@app.post("/api/bookings")
async def create_booking(body: dict):
    from agents.booking_agent import run_booking_agent
    from tools.mock_db import get_price_estimate

    try:
        selected_provider = body.get("selected_provider") or {
            "id":    body.get("provider_id"),
            "name":  body.get("provider_name"),
            "phone": body.get("provider_phone"),
        }

        # Attach pricing if the caller didn't include it
        if "pricing" not in selected_provider:
            selected_provider["pricing"] = get_price_estimate(
                service_type=body.get("service_type", ""),
                rating=selected_provider.get("rating", 4.0),
            )
            print(
                f"💰 Injected pricing into /api/bookings payload: "
                f"{selected_provider['pricing']['display']}"
            )

        state: AgentState = {
            "raw_input":            body.get("raw_input", ""),
            "service_type":         body.get("service_type"),
            "location":             body.get("location"),
            "time_preference":      body.get("time_preference"),
            "language_detected":    body.get("language_detected"),
            "providers_found":      [],
            "ranked_providers":     [],
            "selected_provider":    selected_provider,
            "is_booking_confirmed": body.get("is_booking_confirmed", True),
            "booking":              None,
            "followup":             None,
            "agent_logs":           [],
            "error":                None,
        }

        result = run_booking_agent(state)
        if not result.get("booking"):
            raise HTTPException(status_code=400, detail=str(result.get("agent_logs")))
        return result["booking"]

    except HTTPException:
        raise
    except Exception as e:
        print("\n" + "=" * 70)
        print("❌ ERROR in /api/bookings")
        print("=" * 70)
        traceback.print_exc()
        print("=" * 70 + "\n")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/trace/{booking_id}")
async def get_trace(booking_id: str):
    from tools.mock_db import get_all_bookings
    bookings = get_all_bookings()
    booking  = next((b for b in bookings if b["booking_id"] == booking_id), None)
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    return {"booking_id": booking_id, "agent_logs": booking.get("agent_logs_snapshot", [])}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
