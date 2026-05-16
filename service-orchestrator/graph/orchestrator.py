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


def intent_node(state: AgentState) -> AgentState:
    return run_intent_agent(state)


def discovery_node(state: AgentState) -> AgentState:
    return run_discovery_agent(state)


def matching_node(state: AgentState) -> AgentState:
    return run_matching_agent(state)


def booking_node(state: AgentState) -> AgentState:
    return run_booking_agent(state)


def followup_node(state: AgentState) -> AgentState:
    return run_followup_agent(state)


def error_node(state: AgentState) -> AgentState:
    state["error"] = (
        "Could not understand the service type. Please specify what service you need "
        "(e.g., plumber, AC technician, electrician)."
    )
    return state


def route_after_intent(state: AgentState) -> str:
    if state.get("service_type") is None:
        return "error_node"
    return "discovery_node"


graph = StateGraph(AgentState)
graph.add_node("intent_node", intent_node)
graph.add_node("discovery_node", discovery_node)
graph.add_node("matching_node", matching_node)
graph.add_node("booking_node", booking_node)
graph.add_node("followup_node", followup_node)
graph.add_node("error_node", error_node)

graph.set_entry_point("intent_node")
graph.add_conditional_edges(
    "intent_node",
    route_after_intent,
    {"discovery_node": "discovery_node", "error_node": "error_node"},
)
graph.add_edge("discovery_node", "matching_node")
graph.add_edge("matching_node", "booking_node")
graph.add_edge("booking_node", "followup_node")
graph.add_edge("followup_node", END)
graph.add_edge("error_node", END)

app = graph.compile()


@traceable(name="service-orchestrator-pipeline", run_type="chain")
def run_pipeline(user_input: str) -> dict:
    initial_state: AgentState = {
        "raw_input": user_input,
        "service_type": None,
        "location": None,
        "time_preference": None,
        "language_detected": None,
        "providers_found": [],
        "ranked_providers": [],
        "selected_provider": None,
        "booking": None,
        "followup": None,
        "agent_logs": [],
        "error": None,
    }
    config = {"metadata": {"session_id": str(uuid4()), "user_input": user_input}}
    result = app.invoke(initial_state, config=config)
    return result
