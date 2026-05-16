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
    temperature=0.3,
    max_tokens=150,
)


def _score_provider(p: dict) -> float:
    rating_score   = (p["rating"] / 5.0) * 0.4
    distance_score = (1 - min(p["distance_km"], 10) / 10) * 0.4
    avail_score    = 0.2 if p["available"] else 0.0
    return round(rating_score + distance_score + avail_score, 4)


@traceable(name="matching-agent", run_type="chain")
def run_matching_agent(state: AgentState) -> AgentState:
    providers = state.get("providers_found", [])
    if not providers:
        state["agent_logs"].append(create_error_log("matching_agent", "No providers to rank"))
        return state

    for p in providers:
        p["score"] = _score_provider(p)

    ranked = sorted(providers, key=lambda p: p["score"], reverse=True)
    state["ranked_providers"] = ranked
    best = dict(ranked[0])

    try:
        response = _llm.invoke([
            SystemMessage(content="You explain provider selections in 1-2 friendly sentences."),
            HumanMessage(content=(
                f"Provider: {best['name']}, Rating: {best['rating']}/5, "
                f"Distance: {best['distance_km']}km, Available: {best['available']}, "
                f"Score: {best['score']:.2f}. Why is this the best choice?"
            )),
        ])
        best["reasoning"] = response.content.strip()
    except Exception:
        best["reasoning"] = f"Top-ranked by rating, proximity, and availability. (score={best['score']:.2f})"

    state["selected_provider"] = best

    state["agent_logs"].append(create_agent_log(
        agent_name="matching_agent",
        input_summary=f"Ranking {len(providers)} providers",
        output_summary=f"Selected: {best['name']} (score={best['score']:.2f}, dist={best['distance_km']}km)",
    ))
    return state
