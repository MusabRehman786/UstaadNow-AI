import json
from pathlib import Path

DATA_DIR = Path(__file__).parent.parent / "data"


def get_providers_by_service(service_type: str) -> list:
    with open(DATA_DIR / "providers.json") as f:
        providers = json.load(f)
    return [p for p in providers if p["service_type"].lower() == service_type.lower()]


def save_booking(booking: dict) -> bool:
    path = DATA_DIR / "bookings.json"
    with open(path) as f:
        bookings = json.load(f)
    bookings.append(booking)
    with open(path, "w") as f:
        json.dump(bookings, f, indent=2)
    return True


def get_all_bookings() -> list:
    with open(DATA_DIR / "bookings.json") as f:
        return json.load(f)
