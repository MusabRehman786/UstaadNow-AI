from datetime import datetime


def create_agent_log(agent_name: str, input_summary: str, output_summary: str) -> dict:
    return {
        "agent": agent_name,
        "timestamp": datetime.now().isoformat(),
        "input_summary": input_summary,
        "output_summary": output_summary,
        "status": "success",
    }


def create_error_log(agent_name: str, error: str) -> dict:
    return {
        "agent": agent_name,
        "timestamp": datetime.now().isoformat(),
        "status": "error",
        "error": error,
    }
