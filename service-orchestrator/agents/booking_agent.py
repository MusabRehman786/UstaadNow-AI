import random
from datetime import datetime
from langsmith import traceable

from models.schemas import AgentState
from utils.logger import create_agent_log, create_error_log

TIME_MAP = {
    "morning":   "10:00 AM",
    "subah":     "10:00 AM",
    "afternoon": "2:00 PM",
    "dopahar":   "2:00 PM",
    "evening":   "5:00 PM",
    "shaam":     "5:00 PM",
}
DEFAULT_SLOT = "10:00 AM"


def _parse_slot(time_preference: str) -> str:
    if not time_preference:
        return DEFAULT_SLOT
    pref_lower = time_preference.lower()
    for keyword, slot in TIME_MAP.items():
        if keyword in pref_lower:
            return slot
    return DEFAULT_SLOT


@traceable(name="booking-agent", run_type="chain")
def run_booking_agent(state: AgentState) -> AgentState:
    selected = state.get("selected_provider")
    if not selected:
        state["agent_logs"].append(create_error_log("booking_agent", "No selected provider"))
        return state

    booking_id = f"BK-{random.randint(100000, 999999)}"
    slot_time = _parse_slot(state.get("time_preference", ""))

    booking = {
        "booking_id": booking_id,
        "provider_id": selected["id"],
        "provider_name": selected["name"],
        "provider_phone": selected["phone"],
        "service_type": state["service_type"],
        "location": state["location"],
        "slot_time": f"Tomorrow, {slot_time}",
        "status": "CONFIRMED",
        "confirmation_message": (
            f"Your booking with {selected['name']} is confirmed for tomorrow at {slot_time} "
            f"in {state['location']}. Provider contact: {selected['phone']}"
        ),
        "created_at": datetime.now().isoformat(),
        "agent_logs_snapshot": list(state["agent_logs"]),
    }

    try:
        from tools.mock_db import save_booking
        save_booking(booking)
    except Exception as e:
        state["agent_logs"].append(create_error_log("booking_agent", f"Save failed: {e}"))
        return state

    state["booking"] = booking

    state["agent_logs"].append(create_agent_log(
        agent_name="booking_agent",
        input_summary=f"Provider: {selected['name']}, time_pref: {state.get('time_preference')}",
        output_summary=f"Booking {booking_id} CONFIRMED for {booking['slot_time']}",
    ))
    return state
