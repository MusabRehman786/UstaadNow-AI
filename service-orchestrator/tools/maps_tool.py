import os
import json
import requests
from dotenv import load_dotenv

load_dotenv()

PLACES_API_URL = "https://places.googleapis.com/v1/places:searchText"

FIELD_MASK = ",".join([
    "places.id",
    "places.displayName",
    "places.formattedAddress",
    "places.location",
    "places.rating",
    "places.userRatingCount",
    "places.nationalPhoneNumber",
])


def search_nearby_providers(service_type: str, lat: float, lng: float) -> list:
    api_key = os.getenv("GOOGLE_PLACES_API_KEY") or os.getenv("GOOGLE_MAPS_API_KEY")
    if not api_key:
        raise ValueError("GOOGLE_PLACES_API_KEY not set")

    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": api_key,
        "X-Goog-FieldMask": FIELD_MASK,
    }

    payload = {
        "textQuery": f"{service_type} near Islamabad",
        "locationBias": {
            "circle": {
                "center": {"latitude": lat, "longitude": lng},
                "radius": 5000.0,
            }
        },
        "maxResultCount": 10,
    }

    response = requests.post(PLACES_API_URL, headers=headers, data=json.dumps(payload))
    response.raise_for_status()

    places = response.json().get("places", [])
    providers = []
    for p in places:
        providers.append({
            "id": p.get("id", ""),
            "name": p.get("displayName", {}).get("text", "Unknown"),
            "service_type": service_type,
            "location": p.get("formattedAddress", ""),
            "lat": p.get("location", {}).get("latitude", lat),
            "lng": p.get("location", {}).get("longitude", lng),
            "rating": p.get("rating", 4.0),
            "reviews_count": p.get("userRatingCount", 0),
            "available": True,
            "phone": p.get("nationalPhoneNumber", "N/A"),
        })
    return providers
