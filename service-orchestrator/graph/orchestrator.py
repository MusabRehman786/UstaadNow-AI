
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
#     # Localized error message based on language
#     lang = state.get("language_detected") or "english"
#     if lang == "urdu":
#         state["error"] = (
#             "سروس کی قسم سمجھ نہیں آئی۔ براہ کرم بتائیں کہ آپ کو کونسی سروس چاہیے "
#             "(مثلاً پلمبر، AC ٹیکنیشن، الیکٹریشن)۔"
#         )
#     elif lang == "roman_urdu":
#         state["error"] = (
#             "Service ki qisam samajh nahi aayi. Bata dein kaunsi service chahiye "
#             "(jaise plumber, AC technician, electrician)."
#         )
#     else:
#         state["error"] = (
#             "Could not understand the service type. Please specify what service you need "
#             "(e.g., plumber, AC technician, electrician)."
#         )
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

#     print(f"ROUTE_AFTER_MATCHING: missing={missing}")

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
# def run_pipeline(user_input: str, session_id: str = None, language: str = None) -> dict:
#     """
#     Run the full agent pipeline.

#     Args:
#         user_input: The user's raw text (transcript or typed input).
#         session_id: Optional session ID for multi-turn context.
#         language: Optional explicit language label ("urdu" | "english" | "roman_urdu").
#                   When provided (e.g. from the audio endpoint's `lang` param),
#                   this is treated as authoritative — no auto-detection happens.
#     """
#     from tools.mock_db import init_db
#     init_db()

#     initial_state: AgentState = {
#         "raw_input": user_input,
#         "service_type": None,
#         "location": None,
#         "time_preference": None,
#         "language_detected": language,        # ← seeded; intent agent will respect this
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
#     config = {
#         "metadata": {
#             "session_id": _session_id,
#             "user_input": user_input,
#             "language": language,
#         }
#     }
#     result = app.invoke(initial_state, config=config)
#     return result



from uuid import uuid4
from langsmith import traceable
# pyrefly: ignore [missing-import]
from langgraph.graph import StateGraph, END

from models.schemas import AgentState
from agents.intent_agent import run_intent_agent
from agents.discovery_agent import run_discovery_agent
from agents.matching_agent import run_matching_agent
from agents.booking_agent import run_booking_agent
from agents.followup_agent import run_followup_agent

# ── Routing logger ────────────────────────────────────────────────────────────

def _log_route(from_node: str, to_node: str, reason: str = "") -> None:
    reason_str = f"  ({reason})" if reason else ""
    print(f"🔀 ROUTING  {from_node:<18} →  {to_node}{reason_str}")


# ── Node wrappers ─────────────────────────────────────────────────────────────

def intent_node(state: AgentState) -> AgentState:
    print("▶️  AGENT  intent_node")
    return run_intent_agent(state)


def discovery_node(state: AgentState) -> AgentState:
    print("▶️  AGENT  discovery_node")
    return run_discovery_agent(state)


def matching_node(state: AgentState) -> AgentState:
    print("▶️  AGENT  matching_node")
    return run_matching_agent(state)


def booking_node(state: AgentState) -> AgentState:
    print("▶️  AGENT  booking_node")
    return run_booking_agent(state)


def followup_node(state: AgentState) -> AgentState:
    print("▶️  AGENT  followup_node")
    return run_followup_agent(state)


def error_node(state: AgentState) -> AgentState:
    print("▶️  AGENT  error_node")
    lang = state.get("language_detected") or "english"
    if lang == "urdu":
        state["error"] = (
            "سروس کی قسم سمجھ نہیں آئی۔ براہ کرم بتائیں کہ آپ کو کونسی سروس چاہیے "
            "(مثلاً پلمبر، AC ٹیکنیشن، الیکٹریشن)۔"
        )
    elif lang == "roman_urdu":
        state["error"] = (
            "Service ki qisam samajh nahi aayi. Bata dein kaunsi service chahiye "
            "(jaise plumber, AC technician, electrician)."
        )
    else:
        state["error"] = (
            "Could not understand the service type. Please specify what service you need "
            "(e.g., plumber, AC technician, electrician)."
        )
    return state


# ── Conditional routers ───────────────────────────────────────────────────────

def route_after_intent(state: AgentState) -> str:
    if state.get("service_type") is None:
        _log_route("intent_node", "error_node", "service_type=None")
        return "error_node"
    _log_route("intent_node", "discovery_node", f"service_type={state['service_type']!r}")
    return "discovery_node"


def route_after_matching(state: AgentState) -> str:
    missing = []
    if not state.get("location"):
        missing.append("location")
    if not state.get("time_preference"):
        missing.append("time_preference")
    if not state.get("selected_provider"):
        missing.append("selected_provider")

    if missing:
        _log_route("matching_node", "followup_node", f"missing={missing}")
        return "followup_node"

    _log_route("matching_node", "booking_node", "all slots present")
    return "booking_node"


# ── Graph definition ──────────────────────────────────────────────────────────

graph = StateGraph(AgentState)
graph.add_node("intent_node",    intent_node)
graph.add_node("discovery_node", discovery_node)
graph.add_node("matching_node",  matching_node)
graph.add_node("booking_node",   booking_node)
graph.add_node("followup_node",  followup_node)
graph.add_node("error_node",     error_node)

graph.set_entry_point("intent_node")
graph.add_conditional_edges(
    "intent_node",
    route_after_intent,
    {"discovery_node": "discovery_node", "error_node": "error_node"},
)
graph.add_edge("discovery_node", "matching_node")
graph.add_conditional_edges(
    "matching_node",
    route_after_matching,
    {"booking_node": "booking_node", "followup_node": "followup_node"},
)
graph.add_edge("booking_node",  "followup_node")
graph.add_edge("followup_node", END)
graph.add_edge("error_node",    END)

app = graph.compile()


# ── Pipeline entry point ──────────────────────────────────────────────────────

@traceable(name="service-orchestrator-pipeline", run_type="chain")
def run_pipeline(user_input: str, session_id: str = None, language: str = None) -> dict:
    """
    Run the full agent pipeline.

    Args:
        user_input: The user's raw text (transcript or typed input).
        session_id: Optional session ID for multi-turn context.
        language: Optional explicit language label ("urdu" | "english" | "roman_urdu").
                  When provided (e.g. from the audio endpoint's `lang` param),
                  this is treated as authoritative — no auto-detection happens.
    """
    from tools.mock_db import init_db
    init_db()

    print()
    print("=" * 60)
    print(f"🚀 PIPELINE START  session={session_id or '(none)'}  lang={language or 'auto'}")
    print(f"   input: {user_input!r}")
    print("=" * 60)
    print("🔀 ROUTING  [start]            →  intent_node")

    initial_state: AgentState = {
        "raw_input":            user_input,
        "service_type":         None,
        "location":             None,
        "time_preference":      None,
        "language_detected":    language,     # seeded; intent agent will respect this
        "providers_found":      [],
        "ranked_providers":     [],
        "selected_provider":    None,
        "is_booking_confirmed": False,
        "booking":              None,
        "followup":             None,
        "agent_logs":           [],
        "error":                None,
    }
    _session_id = session_id or str(uuid4())
    config = {
        "metadata": {
            "session_id": _session_id,
            "user_input": user_input,
            "language":   language,
        }
    }
    result = app.invoke(initial_state, config=config)

    final = "booking_node" if result.get("booking") else (
        "error_node" if result.get("error") else "followup_node"
    )
    print(f"🏁 PIPELINE END    terminal node: {final}")
    print("=" * 60)
    print()

    return result