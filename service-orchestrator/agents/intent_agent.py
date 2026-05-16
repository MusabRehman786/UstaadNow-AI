import json
import os
from dotenv import load_dotenv
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage
from langsmith import traceable

from models.schemas import AgentState
from utils.logger import create_agent_log, create_error_log

load_dotenv()

_llm = AzureChatOpenAI(
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
    azure_deployment=os.getenv("AZURE_OPENAI_MODEL_NAME"),
    api_version=os.getenv("AZURE_OPENAI_VERSION"),
    temperature=0,
    max_tokens=300,
)

_SYSTEM_PROMPT = """You are an intent parser for a Pakistani service booking app.
Extract structured information from user input in Urdu, Roman Urdu, or English.
Respond ONLY with a valid JSON object. No explanation, no markdown, no extra text.

Extract:
- service_type: one of [AC Technician, Plumber, Electrician, Home Tutor, Beautician, Carpenter, Painter, CCTV Installer] or null
- location: area name in Islamabad/Rawalpindi (e.g. G-13, F-10, Bahria Town) or null
- time_preference: normalized string like "tomorrow morning", "today afternoon", "kal subah" or null
- language_detected: one of [urdu, roman_urdu, english]"""


@traceable(name="intent-agent", run_type="chain")
def run_intent_agent(state: AgentState) -> AgentState:
    # If faster-whisper already detected the language (audio path), keep it
    whisper_language = state.get("language_detected")

    # Build system prompt — tell the LLM the language if whisper pre-detected it
    system_prompt = _SYSTEM_PROMPT
    if whisper_language:
        system_prompt += f"\n\nNote: language has already been detected as '{whisper_language}' via speech recognition. Use this value."

    try:
        response = _llm.invoke([
            SystemMessage(content=system_prompt),
            HumanMessage(content=state["raw_input"]),
        ])
        raw = response.content.strip()
        # Strip markdown code fences if present
        if raw.startswith("```"):
            raw = raw.split("```")[1]
            if raw.startswith("json"):
                raw = raw[4:]
        parsed = json.loads(raw)

        state["service_type"] = parsed.get("service_type")
        state["location"] = parsed.get("location")
        state["time_preference"] = parsed.get("time_preference")
        # Prefer whisper-detected language; fall back to LLM detection
        state["language_detected"] = whisper_language or parsed.get("language_detected", "english")

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

    return state
