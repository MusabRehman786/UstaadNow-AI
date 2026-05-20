
import os
import random
from datetime import datetime, timedelta
from dotenv import load_dotenv
from langchain_openai import AzureChatOpenAI
from langsmith import traceable
from pydantic import BaseModel, Field
from typing import Optional

from models.schemas import AgentState
from utils.logger import create_agent_log, create_error_log

load_dotenv()

# ── LLM ──────────────────────────────────────────────────────────────────────

_llm = AzureChatOpenAI(
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
    azure_deployment=os.getenv("AZURE_OPENAI_MODEL_NAME"),
    api_version=os.getenv("AZURE_OPENAI_VERSION"),
    temperature=0,
    max_tokens=200,
)


# ── Structured output schema ──────────────────────────────────────────────────

class SlotResolution(BaseModel):
    """Resolved appointment slot."""
    day: str = Field(
        description="One of: 'today', 'tomorrow', 'day_after_tomorrow', or a "
                    "specific date in YYYY-MM-DD format if user named a date."
    )
    time_24h: str = Field(
        description="The appointment start time in 24-hour HH:MM format "
                    "(e.g. '09:00', '14:30', '19:00')."
    )
    time_display: str = Field(
        description="Human-readable time in 12-hour format with AM/PM "
                    "(e.g. '9:00 AM', '2:30 PM', '7:00 PM')."
    )
    user_was_specific: bool = Field(
        description="True if the user mentioned an exact time (e.g. '3pm', "
                    "'11 baje', '8 baje raat'). False if they only said a vague "
                    "period (e.g. 'morning', 'subah', 'evening') and we picked a default."
    )
    confidence: float = Field(
        description="0.0 to 1.0 — how confident the parse is.",
        ge=0.0, le=1.0,
    )


# ── System prompt ─────────────────────────────────────────────────────────────

_SYSTEM_PROMPT = """You are a time-slot resolver for a Pakistani home-services booking app.

Your job: convert the user's free-form time preference (in Urdu, Roman Urdu, or English)
into a concrete appointment slot.

CRITICAL RULES:
1. If the user mentions a SPECIFIC TIME (e.g. "3pm", "11 baje", "8 baje raat", "around 4",
   "Tuesday 6pm"), use EXACTLY that time. Do not round to a default slot.
   Set user_was_specific = true.

2. If the user only gives a VAGUE PERIOD (e.g. "morning", "subah", "afternoon", "dopahar",
   "evening", "shaam", "night", "raat"), pick a sensible default within that period:
     - morning / subah        → 10:00 AM
     - afternoon / dopahar    → 2:00 PM
     - evening / shaam        → 5:00 PM
     - night / raat           → 7:00 PM
   Set user_was_specific = false.

3. If the user says nothing about time, default to tomorrow 10:00 AM. user_was_specific = false.

4. Service operating window is 8:00 AM to 9:00 PM. If the user requests something outside
   that window, snap to the nearest in-window time and set user_was_specific = false.

5. Day resolution:
   - "today" / "aaj"                    → today
   - "tomorrow" / "kal"                 → tomorrow  (default if nothing said)
   - "day after tomorrow" / "parsoon"   → day_after_tomorrow
   - Specific weekday or date           → return YYYY-MM-DD

ROMAN URDU TIME EXPRESSIONS REFERENCE:
- "subah" = morning, "dopahar" = afternoon, "shaam" = evening, "raat" = night
- "X baje" = X o'clock (e.g. "8 baje" = 8:00)
- "kal" = tomorrow, "aaj" = today, "parsoon" = day after tomorrow
- "abhi" / "abi" = now/right away → soonest available in-window time today

EXAMPLES:
- "kal subah"                        → day=tomorrow, time=10:00 AM, user_was_specific=false
- "kal 8 baje raat"                  → day=tomorrow, time=8:00 PM (20:00), user_was_specific=true
- "aaj 3pm"                          → day=today, time=3:00 PM, user_was_specific=true
- "morning"                          → day=tomorrow (default), time=10:00 AM, user_was_specific=false
- "around 4 in the afternoon tomorrow" → day=tomorrow, time=4:00 PM, user_was_specific=true
- "abhi"                             → day=today, time=(soonest in-window), user_was_specific=false
"""

_slot_resolver = _llm.with_structured_output(SlotResolution)


def _resolve_slot_with_llm(time_preference: str, language: str = "english") -> SlotResolution:
    """LLM-based slot resolution. Falls back to a safe default on any failure."""
    today_str = datetime.now().strftime("%Y-%m-%d (%A)")
    user_msg = (
        f"Today is {today_str}.\n"
        f"User language: {language}\n"
        f"User's time preference: \"{time_preference or '(not specified)'}\"\n\n"
        "Resolve this to a concrete slot."
    )
    messages = [
        {"role": "system", "content": _SYSTEM_PROMPT},
        {"role": "user",   "content": user_msg},
    ]
    return _slot_resolver.invoke(messages)


def _safe_fallback_slot() -> SlotResolution:
    """Hard-coded default used if the LLM call fails."""
    return SlotResolution(
        day="tomorrow",
        time_24h="10:00",
        time_display="10:00 AM",
        user_was_specific=False,
        confidence=0.5,
    )


def _format_slot_for_booking(resolution: SlotResolution) -> str:
    day_label = {
        "today":              "Today",
        "tomorrow":           "Tomorrow",
        "day_after_tomorrow": "Day after tomorrow",
    }.get(resolution.day, resolution.day)
    return f"{day_label}, {resolution.time_display}"


# ── Agent ─────────────────────────────────────────────────────────────────────

@traceable(name="booking-agent", run_type="chain")
def run_booking_agent(state: AgentState) -> AgentState:
    selected = state.get("selected_provider")

    print(
        f"   booking_agent  provider={selected['name'] if selected else 'NONE'}  "
        f"confirmed={state.get('is_booking_confirmed', False)}  "
        f"time_pref={state.get('time_preference')!r}  "
        f"lang={state.get('language_detected')}"
    )

    if not selected:
        state["agent_logs"].append(create_error_log("booking_agent", "No selected provider"))
        return state

    if not state.get("is_booking_confirmed", False):
        state["agent_logs"].append(
            create_error_log("booking_agent", "User has not confirmed booking")
        )
        return state

    time_preference = state.get("time_preference") or ""
    language        = state.get("language_detected") or "english"
    pricing         = selected.get("pricing")

    # ── LLM-resolved slot ────────────────────────────────────────────────────
    try:
        resolution = _resolve_slot_with_llm(time_preference, language)
        print(
            f"   booking_agent  ⏰ slot={resolution.day} {resolution.time_display}  "
            f"specific={resolution.user_was_specific}  confidence={resolution.confidence}"
        )
    except Exception as e:
        print(f"   booking_agent  ⚠ slot LLM failed — using fallback: {e}")
        resolution = _safe_fallback_slot()
        state["agent_logs"].append(create_error_log(
            "booking_agent",
            f"Slot LLM failed ({e}), used fallback {resolution.time_display}",
        ))

    slot_display = _format_slot_for_booking(resolution)
    booking_id   = f"BK-{random.randint(100000, 999999)}"

    # ── Build localized confirmation message ─────────────────────────────────
    pricing_str = pricing.get("display", "N/A") if pricing else "N/A"

    if language == "urdu":
        confirmation = (
            f"آپ کی بکنگ {selected['name']} کے ساتھ {slot_display} کو "
            f"{state['location']} میں کنفرم ہو گئی ہے۔ "
            f"تخمینی قیمت: {pricing_str}۔ "
            f"رابطہ: {selected['phone']}"
        )
    elif language == "roman_urdu":
        confirmation = (
            f"Aap ki booking {selected['name']} ke saath {slot_display} ko "
            f"{state['location']} mein confirm ho gayi hai. "
            f"Estimated price: {pricing_str}. "
            f"Contact: {selected['phone']}"
        )
    else:
        confirmation = (
            f"Your booking with {selected['name']} is confirmed for {slot_display} "
            f"in {state['location']}. "
            f"Estimated price: {pricing_str}. "
            f"Provider contact: {selected['phone']}"
        )

    booking = {
        "booking_id":           booking_id,
        "provider_id":          selected["id"],
        "provider_name":        selected["name"],
        "provider_phone":       selected["phone"],
        "service_type":         state["service_type"],
        "location":             state["location"],
        "slot_time":            slot_display,
        "slot_time_24h":        resolution.time_24h,
        "slot_day":             resolution.day,
        "user_specified_time":  resolution.user_was_specific,
        "status":               "CONFIRMED",
        "pricing":              pricing,           # ← persisted into SQLite
        "confirmation_message": confirmation,
        "created_at":           datetime.now().isoformat(),
        "agent_logs_snapshot":  list(state["agent_logs"]),
    }

    try:
        from tools.mock_db import save_booking
        save_booking(booking)
    except Exception as e:
        state["agent_logs"].append(create_error_log("booking_agent", f"Save failed: {e}"))
        return state

    state["booking"] = booking

    print(
        f"   booking_agent  ✔ booking created  id={booking_id}  "
        f"slot={slot_display}  pricing={pricing_str}"
    )

    state["agent_logs"].append(create_agent_log(
        agent_name="booking_agent",
        input_summary=(
            f"Provider: {selected['name']}, time_pref: '{time_preference}', "
            f"lang: {language}, pricing: {pricing_str}"
        ),
        output_summary=(
            f"Booking {booking_id} CONFIRMED for {slot_display} "
            f"(user_was_specific={resolution.user_was_specific}, pricing={pricing_str})"
        ),
    ))
    return state