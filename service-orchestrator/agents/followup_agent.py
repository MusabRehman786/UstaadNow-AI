from langsmith import traceable

from models.schemas import AgentState
from utils.logger import create_agent_log, create_error_log


@traceable(name="followup-agent", run_type="chain")
def run_followup_agent(state: AgentState) -> AgentState:
    booking = state.get("booking")
    if not booking:
        state["agent_logs"].append(create_error_log("followup_agent", "No booking to follow up on"))
        return state

    followup = {
        "booking_id": booking["booking_id"],
        "reminder_scheduled": "1 hour before appointment",
        "reminder_message": (
            f"Reminder: Your {state['service_type']} with {booking['provider_name']} "
            f"is in 1 hour at {state['location']}!"
        ),
        "status_update": "Provider notified. Booking CONFIRMED.",
        "completion_confirmation": "After service, you will receive a rating request and digital receipt.",
        "simulated_notifications": [
            {
                "type": "SMS",
                "recipient": "customer",
                "message": (
                    f"Booking confirmed! {state['service_type']} - {booking['slot_time']} - "
                    f"{booking['provider_name']} - ID: {booking['booking_id']}"
                ),
                "scheduled_at": "immediately",
            },
            {
                "type": "SMS",
                "recipient": "provider",
                "message": (
                    f"New job: {state['service_type']} at {state['location']} "
                    f"{booking['slot_time']}. ID: {booking['booking_id']}"
                ),
                "scheduled_at": "immediately",
            },
            {
                "type": "reminder",
                "recipient": "customer",
                "message": "Your appointment is in 1 hour!",
                "scheduled_at": "1 hour before slot",
            },
        ],
    }

    state["followup"] = followup

    state["agent_logs"].append(create_agent_log(
        agent_name="followup_agent",
        input_summary=f"Booking: {booking['booking_id']}",
        output_summary=f"3 notifications scheduled. Status: {followup['status_update']}",
    ))
    return state
