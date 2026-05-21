

import os
from langsmith import traceable
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import HumanMessage

from models.schemas import AgentState
from utils.logger import create_agent_log, create_error_log


FOLLOWUP_PROMPT = """You are a helpful service booking assistant for Pakistan.
A user wants to book a service but some required information is missing.

Information collected so far:
- Service Type: {service_type}
- Location: {location}
- Time Preference: {time_preference}

Missing fields: {missing_fields}

LANGUAGE REQUIREMENT — CRITICAL:
You MUST respond in {language_strict}. This is non-negotiable.
- If "English" — reply in plain English only. No Urdu words, no Roman Urdu, no Hindi.
- If "Urdu" — reply in Urdu script (نستعلیق). No English words except brand/place names.
- If "Roman Urdu" — Urdu written in English letters, casual style.

Ask the user a natural, friendly follow-up question to collect the missing information.
Keep it short (one sentence) and conversational. Ask about all missing fields in one message.
Do not repeat what you already know. Only ask for what is missing.

Respond with ONLY the question, no extra text, no language label."""


REQUIRED_FIELDS = ("service_type", "location", "time_preference")


def _get_llm():
    return AzureChatOpenAI(
        azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
        api_key=os.getenv("AZURE_OPENAI_API_KEY"),
        azure_deployment=os.getenv("AZURE_OPENAI_MODEL_NAME"),
        api_version=os.getenv("AZURE_OPENAI_VERSION"),
        temperature=0.3,
        max_tokens=150,
    )


def _get_missing_fields(state: AgentState) -> list[str]:
    return [f for f in REQUIRED_FIELDS if not state.get(f)]


def _language_label(code: str | None) -> str:
    return {
        "urdu":       "Urdu (Urdu script, نستعلیق)",
        "roman_urdu": "Roman Urdu (Urdu in English letters)",
        "english":    "English (plain English, no Urdu words)",
    }.get(code or "english", "English (plain English, no Urdu words)")


@traceable(name="followup-agent", run_type="chain")
def run_followup_agent(state: AgentState) -> AgentState:
    missing  = _get_missing_fields(state)
    has_booking = bool(state.get("booking"))

    print(
        f"   followup_agent  missing={missing}  booking={'yes' if has_booking else 'no'}  "
        f"service={state.get('service_type')}  location={state.get('location')}  "
        f"time={state.get('time_preference')}"
    )

    # ── Path 1: missing required fields, no booking yet → ask user ──────────
    if missing and not has_booking:
        try:
            llm    = _get_llm()
            prompt = FOLLOWUP_PROMPT.format(
                service_type=state.get("service_type")    or "(not provided yet)",
                location=state.get("location")            or "(not provided yet)",
                time_preference=state.get("time_preference") or "(not provided yet)",
                missing_fields=", ".join(missing),
                language_strict=_language_label(state.get("language_detected")),
            )
            response          = llm.invoke([HumanMessage(content=prompt)])
            followup_question = response.content.strip()
        except Exception as e:
            print(f"   followup_agent  ⚠ LLM call failed — using fallback: {e}")
            followup_question = _fallback_question(missing, state.get("language_detected"))

        print(f"   followup_agent  ✔ asking: {followup_question!r}")

        state["followup"] = {
            "status":         "incomplete",
            "missing_fields": missing,
            "collected_fields": {
                "service_type":    state.get("service_type"),
                "location":        state.get("location"),
                "time_preference": state.get("time_preference"),
            },
            "followup_question": followup_question,
        }
        state["agent_logs"].append(create_agent_log(
            agent_name="followup_agent",
            input_summary=f"Missing fields: {missing}",
            output_summary=f"Asked follow-up: {followup_question}",
        ))
        return state

    # ── Path 2: booking exists → schedule notifications ──────────────────────
    booking = state.get("booking")
    if not booking:
        state["agent_logs"].append(create_error_log(
            "followup_agent",
            "No booking and no missing fields — unexpected state."
        ))
        return state

    print(f"   followup_agent  ✔ scheduling notifications for {booking['booking_id']}")

    state["followup"] = {
        "status":         "complete",
        "booking_id":     booking["booking_id"],
        "reminder_scheduled": "1 hour before appointment",
        "reminder_message": (
            f"Reminder: Your {state['service_type']} with {booking['provider_name']} "
            f"is in 1 hour at {state['location']}!"
        ),
        "status_update": "Provider notified. Booking CONFIRMED.",
        "completion_confirmation": (
            "After service, you will receive a rating request and digital receipt."
        ),
        "simulated_notifications": [
            {
                "type":         "SMS",
                "recipient":    "customer",
                "message": (
                    f"Booking confirmed! {state['service_type']} - {booking['slot_time']} - "
                    f"{booking['provider_name']} - ID: {booking['booking_id']}"
                ),
                "scheduled_at": "immediately",
            },
            {
                "type":         "SMS",
                "recipient":    "provider",
                "message": (
                    f"New job: {state['service_type']} at {state['location']} "
                    f"{booking['slot_time']}. ID: {booking['booking_id']}"
                ),
                "scheduled_at": "immediately",
            },
            {
                "type":         "reminder",
                "recipient":    "customer",
                "message":      "Your appointment is in 1 hour!",
                "scheduled_at": "1 hour before slot",
            },
        ],
    }

    state["agent_logs"].append(create_agent_log(
        agent_name="followup_agent",
        input_summary=f"Booking: {booking['booking_id']}",
        output_summary="3 notifications scheduled. Status: complete",
    ))
    return state


def _fallback_question(missing: list[str], language: str | None) -> str:
    lang = language or "roman_urdu"
    questions = {
        "roman_urdu": {
            ("service_type",):                            "Aap kaunsi service chahte hain?",
            ("location",):                                "Aapka address kya hai?",
            ("time_preference",):                         "Service kab chahiye?",
            ("service_type", "location"):                 "Aap kaunsi service chahte hain aur kahan se?",
            ("service_type", "time_preference"):          "Aap kaunsi service chahte hain aur kab?",
            ("location", "time_preference"):              "Aapka address kya hai aur kab chahiye?",
            ("service_type", "location", "time_preference"): "Kaunsi service, kahan se, aur kab chahiye?",
        },
        "english": {
            ("service_type",):                            "What service do you need?",
            ("location",):                                "What's your address?",
            ("time_preference",):                         "When do you need it?",
            ("service_type", "location"):                 "What service do you need and where?",
            ("service_type", "time_preference"):          "What service do you need and when?",
            ("location", "time_preference"):              "What's your address and when do you need it?",
            ("service_type", "location", "time_preference"): "What service, where, and when do you need it?",
        },
        "urdu": {
            ("service_type",):                            "آپ کونسی سروس چاہتے ہیں؟",
            ("location",):                                "آپ کا پتہ کیا ہے؟",
            ("time_preference",):                         "سروس کب چاہیے؟",
            ("service_type", "location"):                 "آپ کونسی سروس چاہتے ہیں اور کہاں سے؟",
            ("service_type", "time_preference"):          "آپ کونسی سروس چاہتے ہیں اور کب؟",
            ("location", "time_preference"):              "آپ کا پتہ کیا ہے اور کب چاہیے؟",
            ("service_type", "location", "time_preference"): "کونسی سروس، کہاں سے، اور کب چاہیے؟",
        },
    }
    lang_map = questions.get(lang, questions["roman_urdu"])
    key      = tuple(missing)
    return lang_map.get(key, lang_map[("service_type", "location", "time_preference")])