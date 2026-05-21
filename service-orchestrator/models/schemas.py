from typing import TypedDict, Optional
from pydantic import BaseModel


class ServiceRequest(BaseModel):
    raw_input: str
    service_type: Optional[str] = None
    location: Optional[str] = None
    time_preference: Optional[str] = None
    language_detected: Optional[str] = None
    selected_provider: Optional[dict] = None    # ✅ ADD THIS
    is_booking_confirmed: bool = False           # ✅ ADD THIS


class Provider(BaseModel):
    id: str
    name: str
    service_type: str
    location: str
    lat: float
    lng: float
    rating: float
    reviews_count: int
    distance_km: float = 0.0
    available: bool
    phone: str


class BookingConfirmation(BaseModel):
    booking_id: str
    provider: dict
    slot_time: str
    status: str
    confirmation_message: str


class FollowUp(BaseModel):
    booking_id: str
    reminder_time: str
    status_update: str
    completion_confirmation: str


class AgentState(TypedDict):
    raw_input: str
    service_type: Optional[str]
    location: Optional[str]
    time_preference: Optional[str]
    language_detected: Optional[str]
    providers_found: list
    ranked_providers: list
    selected_provider: Optional[dict]
    is_booking_confirmed: bool
    booking: Optional[dict]
    followup: Optional[dict]
    agent_logs: list
    error: Optional[str]
