import sys
from graph import run_pipeline

TEST_INPUTS = [
    "Mujhe kal subah G-13 mein AC technician chahiye",
    "I need a plumber in F-10 today afternoon",
    "Electrician chahiye Bahria Town mein, jaldi",
]

if __name__ == "__main__":
    user_input = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else TEST_INPUTS[0]

    print(f"\n{'='*60}")
    print(f"🔍 Input: {user_input}")
    print(f"{'='*60}")

    result = run_pipeline(user_input)

    if result.get("error"):
        print(f"\n❌ Error: {result['error']}")
        sys.exit(1)

    print(f"\n📋 SERVICE REQUEST")
    print(f"   Service  : {result['service_type']}")
    print(f"   Location : {result['location']}")
    print(f"   Time     : {result['time_preference']}")
    print(f"   Language : {result['language_detected']}")

    if result.get("selected_provider"):
        p = result["selected_provider"]
        print(f"\n🏆 SELECTED PROVIDER")
        print(f"   Name      : {p['name']}")
        print(f"   Rating    : {p['rating']} ⭐  ({p.get('reviews_count', 0)} reviews)")
        print(f"   Distance  : {p['distance_km']:.1f} km")
        print(f"   Phone     : {p['phone']}")
        print(f"   Reasoning : {p.get('reasoning', 'N/A')}")

    if result.get("booking"):
        b = result["booking"]
        print(f"\n✅ BOOKING CONFIRMED")
        print(f"   Booking ID : {b['booking_id']}")
        print(f"   Slot       : {b['slot_time']}")
        print(f"   Status     : {b['status']}")
        print(f"   Message    : {b['confirmation_message']}")

    if result.get("followup"):
        f = result["followup"]
        print(f"\n🔔 FOLLOW-UP SCHEDULED")
        print(f"   Reminder : {f['reminder_scheduled']}")
        print(f"   Status   : {f['status_update']}")
        print(f"   Notifications:")
        for n in f.get("simulated_notifications", []):
            print(f"     [{n['type'].upper()}] → {n['recipient']}: {n['message'][:60]}...")

    print(f"\n🤖 AGENT TRACE")
    for log in result.get("agent_logs", []):
        icon = "✅" if log["status"] == "success" else "❌"
        print(f"   {icon} [{log['agent']}] {log.get('output_summary', log.get('error', ''))}")

    print(f"\n{'='*60}\n")
