import math
from langsmith import traceable

from models.schemas import AgentState
from utils.logger import create_agent_log, create_error_log

AREA_COORDS = {
    "G-13": (33.6844, 72.9748),
    "F-10": (33.7141, 73.0237),
    "I-8":  (33.6796, 73.0552),
    "G-9":  (33.6938, 73.0237),
    "G-11": (33.7020, 73.0100),
    "E-11": (33.7200, 73.0000),
    "Bahria Town": (33.5300, 73.1000),
    "DHA":  (33.5180, 73.1070),
    "Saddar": (33.6007, 73.0679),
    "F-7":  (33.7229, 73.0436),
}
DEFAULT_COORDS = (33.6844, 72.9748)


def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    return R * 2 * math.asin(math.sqrt(a))


def _find_user_coords(location: str) -> tuple:
    if not location:
        return DEFAULT_COORDS
    for key, coords in AREA_COORDS.items():
        if key.lower() in location.lower() or location.lower() in key.lower():
            return coords
    return DEFAULT_COORDS


@traceable(name="discovery-agent", run_type="chain")
def run_discovery_agent(state: AgentState) -> AgentState:
    service_type = state.get("service_type", "")
    location = state.get("location", "")
    user_lat, user_lng = _find_user_coords(location)

    try:
        from tools.maps_tool import search_nearby_providers
        providers = search_nearby_providers(service_type, user_lat, user_lng)
        source = "Google Maps"
    except Exception:
        from tools.mock_db import get_providers_by_service
        providers = get_providers_by_service(service_type)
        source = "mock DB"

    for p in providers:
        p["distance_km"] = round(_haversine(user_lat, user_lng, p["lat"], p["lng"]), 2)

    providers_sorted = sorted(providers, key=lambda p: p["distance_km"])[:10]
    state["providers_found"] = providers_sorted

    state["agent_logs"].append(create_agent_log(
        agent_name="discovery_agent",
        input_summary=f"service={service_type}, location={location}",
        output_summary=f"Found {len(providers_sorted)} providers via {source}",
    ))
    return state
