
import os
from dotenv import load_dotenv
from langchain_openai import AzureChatOpenAI
from langsmith import traceable
from pydantic import BaseModel
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
    max_tokens=300,
)

# ── Structured output schema ──────────────────────────────────────────────────

class IntentOutput(BaseModel):
    service_type:      Optional[str] = None
    location:          Optional[str] = None
    time_preference:   Optional[str] = None
    language_detected: Optional[str] = None   # "urdu" | "roman_urdu" | "english"

# ── System prompt ─────────────────────────────────────────────────────────────

_SYSTEM_PROMPT = """You are an intent parser for a Pakistani service booking app.
Extract structured information from user input.

Extract these fields:
- service_type: one of [AC Technician, Plumber, Electrician, Home Tutor, Beautician,
  Carpenter, Painter, CCTV Installer] or null
- location: area name in Islamabad/Rawalpindi (e.g. G-13, F-10, Bahria Town) or null
- time_preference: normalized string preserving the EXACT time mentioned by the user.
  See rules and examples below.
- language_detected: detect the language of the user's input as one of:
  "urdu" (Urdu script), "roman_urdu" (Urdu in English letters),
  or "english" (plain English).

TIME PREFERENCE RULES — CRITICAL:
1. If the user mentions a SPECIFIC HOUR (e.g. "4pm", "3 baje", "11 baje raat",
   "around 6", "6:30"), preserve it EXACTLY. Never collapse it into a vague period.
   - "4pm"           → "today 4:00 PM"
   - "4pm tomorrow"  → "tomorrow 4:00 PM"
   - "kal 3 baje"    → "tomorrow 3:00 PM"
   - "aaj 8 baje raat" → "today 8:00 PM"

2. If the user gives ONLY a vague period with no hour, use the period word as-is:
   - "morning"       → "tomorrow morning"
   - "subah"         → "tomorrow morning"
   - "afternoon"     → "today afternoon"
   - "shaam"         → "today evening"
   - "raat"          → "today night"

3. If no time is mentioned at all → null

4. NEVER convert a specific hour into a vague period label.
   "4pm" must NEVER become "afternoon". "8 baje raat" must NEVER become "night".

5. If the message contains both a location and a time (e.g. "4pm in I-8 Markaz"),
   extract BOTH fields independently. Do not lose the time because of the location.

EXAMPLES:
- "AC repair kal subah G-13 mein"     → service=AC Technician, location=G-13, time="tomorrow morning"
- "aaj 4 baje F-10"                   → location=F-10, time="today 4:00 PM"
- "4pm in I-8 Markaz"                 → location=I-8 Markaz, time="today 4:00 PM"
- "kal 8 baje raat Bahria Town"       → location=Bahria Town, time="tomorrow 8:00 PM"
- "plumber tomorrow afternoon"        → service=Plumber, time="tomorrow afternoon"
- "electrician G-11 morning"          → service=Electrician, location=G-11, time="tomorrow morning"
- "around 6 kal"                      → time="tomorrow 6:00 PM"

IMPORTANT: If the user message contains a line stating that the language has been
pre-set, you MUST use that exact value for language_detected. Do not infer language
from the text in that case."""

_agent = _llm.with_structured_output(IntentOutput)


@traceable(name="intent-agent", run_type="chain")
def run_intent_agent(state: AgentState) -> AgentState:
    preset_language       = state.get("language_detected")
    language_is_authoritative = bool(preset_language)

    print(
        f"   intent_agent  input={state['raw_input'][:60]!r}  "
        f"preset_lang={preset_language or 'auto'}"
    )

    extra_hint = ""
    if preset_language:
        extra_hint = (
            f"\n\nThe user has explicitly chosen language: '{preset_language}'. "
            "Use this exact value for language_detected. Respond using vocabulary "
            "and locations consistent with this language."
        )

    user_message = state["raw_input"] + extra_hint
    messages = [
        {"role": "system", "content": _SYSTEM_PROMPT},
        {"role": "user",   "content": user_message},
    ]

    try:
        parsed: IntentOutput = _agent.invoke(messages)

        print(
            f"   intent_agent  ✔ service={parsed.service_type}  "
            f"location={parsed.location}  time={parsed.time_preference}  "
            f"lang_parsed={parsed.language_detected}  lang_preset={preset_language}"
        )

        # state["service_type"]    = parsed.service_type
        # state["location"]        = parsed.location
        # state["time_preference"] = parsed.time_preference

         # With this:
        if parsed.service_type:
            state["service_type"] = parsed.service_type
        if parsed.location:
            state["location"] = parsed.location
        if parsed.time_preference:
            state["time_preference"] = parsed.time_preference

        # Preset language always wins over LLM-detected language.
        if language_is_authoritative:
            state["language_detected"] = preset_language
        else:
            state["language_detected"] = parsed.language_detected or "english"

        state["agent_logs"].append(create_agent_log(
            agent_name="intent_agent",
            input_summary=f"Raw: {state['raw_input'][:80]}",
            output_summary=(
                f"service={state['service_type']}, location={state['location']}, "
                f"time={state['time_preference']}, lang={state['language_detected']}"
            ),
        ))

    except Exception as e:
        state["service_type"] = None
        state["agent_logs"].append(create_error_log("intent_agent", str(e)))
        print(f"   intent_agent  ✖ ERROR: {e}")

    return state