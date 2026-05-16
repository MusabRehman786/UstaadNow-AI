import os
from functools import lru_cache
from faster_whisper import WhisperModel

# Roman Urdu words commonly spoken — used to distinguish from plain English
_ROMAN_URDU_MARKERS = {
    "mujhe", "chahiye", "mein", "hai", "ka", "ki", "ko", "se", "nay", "kal",
    "aaj", "subah", "shaam", "dopahar", "jaldi", "please", "bhai", "yaar",
    "ghar", "abhi", "zaroor", "theek", "achha", "haan", "nahi", "koi", "kuch",
    "wala", "wali", "karein", "karo", "chahta", "chahti", "lagao", "bulao",
}


@lru_cache(maxsize=1)
def _load_model() -> WhisperModel:
    device = "cuda" if _cuda_available() else "cpu"
    compute = "float16" if device == "cuda" else "int8"
    return WhisperModel("large-v3-turbo", device=device, compute_type=compute)


def _cuda_available() -> bool:
    try:
        import torch
        return torch.cuda.is_available()
    except ImportError:
        return False


def _map_language(whisper_lang: str, transcript: str) -> str:
    """Map whisper language code to our three categories."""
    if whisper_lang == "ur":
        return "urdu"
    if whisper_lang == "en":
        words = set(transcript.lower().split())
        if words & _ROMAN_URDU_MARKERS:
            return "roman_urdu"
        return "english"
    # For any other detected language, check for Roman Urdu markers as fallback
    words = set(transcript.lower().split())
    if words & _ROMAN_URDU_MARKERS:
        return "roman_urdu"
    return "english"


def transcribe_audio(audio_path: str) -> dict:
    """
    Transcribe an audio file and detect language.

    Returns:
        {
          "transcript": str,
          "language_detected": "urdu" | "roman_urdu" | "english",
          "whisper_language": str,   # raw code from Whisper, e.g. "ur", "en"
          "confidence": float,
        }
    """
    model = _load_model()
    segments, info = model.transcribe(
        audio_path,
        beam_size=5,
        language=None,          # auto-detect
        task="transcribe",
        vad_filter=True,        # remove silence
        vad_parameters={"min_silence_duration_ms": 500},
    )

    transcript = " ".join(seg.text.strip() for seg in segments).strip()
    whisper_lang = info.language
    confidence = round(info.language_probability, 3)
    language_label = _map_language(whisper_lang, transcript)

    return {
        "transcript": transcript,
        "language_detected": language_label,
        "whisper_language": whisper_lang,
        "confidence": confidence,
    }
