
import math
import os
import requests
from functools import lru_cache
from langsmith import traceable

from models.schemas import AgentState
from utils.logger import create_agent_log, create_error_log

# Fallback coordinates (Islamabad city center) used only if geocoding fails
DEFAULT_COORDS = (33.6844, 72.9748)
DEFAULT_REGION = "Islamabad, Pakistan"


def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(dlon / 2) ** 2
    )
    return R * 2 * math.asin(math.sqrt(a))


@lru_cache(maxsize=256)
def _geocode_location(location: str) -> tuple:
    """
    Resolve a free-text location to (lat, lng) using Google's Geocoding API.
    Results are cached in-process to avoid repeated API calls for the same input.
    Falls back to DEFAULT_COORDS on any failure.
    """
    if not location or not location.strip():
        return DEFAULT_COORDS

    api_key = os.getenv("GOOGLE_MAPS_API_KEY")
    if not api_key:
        return DEFAULT_COORDS

    query = location.strip()
    if "islamabad" not in query.lower() and "rawalpindi" not in query.lower():
        query = f"{query}, {DEFAULT_REGION}"

    try:
        resp = requests.get(
            "https://maps.googleapis.com/maps/api/geocode/json",
            params={
                "address": query,
                "key":     api_key,
                "region":  "pk",
                "bounds":  "33.45,72.85|33.78,73.25",
            },
            timeout=5,
        )
        data = resp.json()
        if data.get("status") == "OK" and data.get("results"):
            loc = data["results"][0]["geometry"]["location"]
            return (loc["lat"], loc["lng"])
    except Exception:
        pass

    return DEFAULT_COORDS


@traceable(name="discovery-agent", run_type="chain")
def run_discovery_agent(state: AgentState) -> AgentState:
    service_type = state.get("service_type", "")
    query        = state.get("query", "") or ""
    location     = state.get("location", "") or _extract_location_from_query(query)

    print(
        f"   discovery_agent  service={service_type!r}  location={location!r}"
    )

    user_lat, user_lng = _geocode_location(location)
    geocoded = (user_lat, user_lng) != DEFAULT_COORDS or bool(location)

    try:
        from tools.maps_tool import search_nearby_providers
        providers = search_nearby_providers(service_type, user_lat, user_lng)
        source = "Google Maps"
    except Exception:
        from tools.mock_db import get_providers_by_service
        providers = get_providers_by_service(service_type)
        source = "mock DB"

    for p in providers:
        p["distance_km"] = round(
            _haversine(user_lat, user_lng, p["lat"], p["lng"]), 2
        )

    providers_sorted = sorted(providers, key=lambda p: p["distance_km"])[:10]
    state["providers_found"]   = providers_sorted
    state["user_coords"]       = {"lat": user_lat, "lng": user_lng}
    state["resolved_location"] = location or DEFAULT_REGION

    print(
        f"   discovery_agent  ✔ found={len(providers_sorted)} via {source}  "
        f"coords=({user_lat:.4f}, {user_lng:.4f})  "
        f"{'[geocoded]' if geocoded else '[default coords]'}"
    )

    state["agent_logs"].append(create_agent_log(
        agent_name="discovery_agent",
        input_summary=f"service={service_type}, location={location or '(none)'}",
        output_summary=(
            f"Found {len(providers_sorted)} providers via {source} "
            f"near ({user_lat:.4f}, {user_lng:.4f}) "
            f"[{'geocoded' if geocoded else 'default'}]"
        ),
    ))
    return state


def _extract_location_from_query(query: str) -> str:
    if not query:
        return ""
    import re
    pattern = r"\b(?:in|near|at|around|close to)\s+([A-Za-z0-9\-\s,]+?)(?:[.?!]|$)"
    m = re.search(pattern, query, flags=re.IGNORECASE)
    if m:
        return m.group(1).strip(" ,.")
    return ""