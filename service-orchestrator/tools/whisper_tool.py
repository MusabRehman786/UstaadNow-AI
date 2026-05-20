

import os
import subprocess
import traceback
from functools import lru_cache
from faster_whisper import WhisperModel


_ROMAN_URDU_MARKERS = {
    "mujhe", "chahiye", "mein", "hai", "ka", "ki", "ko", "se", "nay", "kal",
    "aaj", "subah", "shaam", "dopahar", "jaldi", "please", "bhai", "yaar",
    "ghar", "abhi", "zaroor", "theek", "achha", "haan", "nahi", "koi", "kuch",
    "wala", "wali", "karein", "karo", "chahta", "chahti", "lagao", "bulao",
}

_HALLUCINATION_PATTERNS = {
    "thank you.", "thanks for watching.", "thank you for watching.",
    "you", ".", "...", "bye.", "thank you so much.",
    "subscribe", "please subscribe", "thanks for watching",
    "شکریہ", "شکریہ۔",
}


def _cuda_available() -> bool:
    """Ask CTranslate2 (the actual runtime faster-whisper uses) about CUDA."""
    try:
        import ctranslate2
        count = ctranslate2.get_cuda_device_count()
        if count > 0:
            print(f"🟢 CTranslate2 sees {count} CUDA device(s)")
            return True
        print("🔵 CTranslate2 reports no CUDA devices")
        return False
    except Exception as e:
        print(f"⚠️ CUDA detection failed: {e}")
        return False


@lru_cache(maxsize=1)
def _load_model() -> WhisperModel:
    if _cuda_available():
        device = "cuda"
        compute = "float16"
    else:
        device = "cpu"
        compute = "int8"

    print(f"🚀 Whisper device: {device}  compute_type: {compute}")

    model_id = "mobiuslabsgmbh/faster-whisper-large-v3-turbo"
    print(f"✅ Loading Whisper model: {model_id}")
    try:
        return WhisperModel(model_id, device=device, compute_type=compute)
    except Exception as e:
        print(f"⚠️ Failed to load {model_id} on {device}: {e}")
        if device == "cuda":
            print("⚠️ Falling back to CPU/int8")
            try:
                return WhisperModel(model_id, device="cpu", compute_type="int8")
            except Exception as e2:
                print(f"⚠️ CPU load also failed: {e2}")
        print("⚠️ Falling back to standard 'large-v3-turbo'")
        return WhisperModel("large-v3-turbo", device=device, compute_type=compute)


def _convert_to_wav(input_path: str) -> str:
    """Convert any audio format to 16kHz mono WAV, with highpass + loudness normalize."""
    wav_path = os.path.splitext(input_path)[0] + "_converted.wav"
    subprocess.run(
        [
            "ffmpeg", "-y", "-i", input_path,
            "-ar", "16000", "-ac", "1",
            "-af", "highpass=f=80,loudnorm=I=-16:TP=-1.5:LRA=11",
            wav_path,
        ],
        check=True,
        capture_output=True,
    )
    return wav_path


def _audio_duration(path: str) -> float:
    """Get audio duration in seconds via ffprobe. Returns -1 if ffprobe is unavailable."""
    try:
        result = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration",
             "-of", "default=noprint_wrappers=1:nokey=1", path],
            check=True, capture_output=True, text=True,
        )
        return float(result.stdout.strip())
    except FileNotFoundError:
        print("⚠️ ffprobe not found on PATH — skipping duration check.")
        return -1.0
    except (subprocess.CalledProcessError, ValueError) as e:
        print(f"⚠️ ffprobe failed: {e}")
        return -1.0


def _is_hallucination(text: str) -> bool:
    if not text:
        return True
    cleaned = text.strip().lower()
    if len(cleaned) < 2:
        return True
    if cleaned in _HALLUCINATION_PATTERNS:
        return True
    tokens = cleaned.split()
    if len(tokens) >= 3 and len(set(tokens)) == 1:
        return True
    return False


def _map_language(whisper_lang: str, transcript: str) -> str:
    if whisper_lang == "ur":
        return "urdu"
    if whisper_lang == "en":
        words = set(transcript.lower().split())
        if words & _ROMAN_URDU_MARKERS:
            return "roman_urdu"
        return "english"
    words = set(transcript.lower().split())
    if words & _ROMAN_URDU_MARKERS:
        return "roman_urdu"
    return "english"


def transcribe_audio(audio_path: str, language: str | None = None) -> dict:
    """
    Transcribe an audio file. If `language` is provided ("ur", "en", or one
    of our labels), Whisper is told the language explicitly — far more accurate
    than auto-detect for short Urdu/Roman Urdu clips and noisy phone audio.

    Returns:
        {
          "transcript": str,
          "language_detected": "urdu" | "english",
          "whisper_language": str,
          "confidence": float,
          "is_empty": bool,
        }
    """
    try:
        if not os.path.exists(audio_path):
            raise FileNotFoundError(f"Audio file does not exist: {audio_path}")

        file_size = os.path.getsize(audio_path)
        print(f"🎙️  transcribe_audio  path={audio_path}  size={file_size} bytes  lang_hint={language}")

        if file_size == 0:
            print("⚠️ File is 0 bytes — skipping.")
            return {
                "transcript": "",
                "language_detected": "english",
                "whisper_language": "unknown",
                "confidence": 0.0,
                "is_empty": True,
            }

        duration = _audio_duration(audio_path)
        if 0 <= duration < 0.3:
            print(f"⚠️ Audio too short ({duration:.2f}s) — skipping.")
            return {
                "transcript": "",
                "language_detected": "english",
                "whisper_language": "unknown",
                "confidence": 0.0,
                "is_empty": True,
            }

        wav_path = None
        try:
            wav_path = _convert_to_wav(audio_path)
            model_input = wav_path
            print(f"🔄 Converted to WAV: {wav_path}")
        except subprocess.CalledProcessError as e:
            stderr = e.stderr.decode()[:500] if e.stderr else "(no stderr)"
            print(f"⚠️ ffmpeg conversion failed, using original.\nstderr: {stderr}")
            model_input = audio_path
        except FileNotFoundError:
            print("⚠️ ffmpeg not found on PATH — using original file.")
            model_input = audio_path

        # Normalize language hint to ISO code Whisper expects
        whisper_lang_hint = None
        if language:
            lang_lower = language.strip().lower()
            whisper_lang_hint = {
                "ur": "ur", "urdu": "ur", "roman_urdu": "ur",
                "en": "en", "english": "en",
            }.get(lang_lower)
            if whisper_lang_hint:
                print(f"🌐 Whisper language pinned to: {whisper_lang_hint}")

        model = _load_model()
        segments, info = model.transcribe(
            model_input,
            beam_size=5,
            language=whisper_lang_hint,
            task="transcribe",
            vad_filter=True,
            vad_parameters={
                "min_silence_duration_ms": 500,
                "threshold": 0.5,
                "min_speech_duration_ms": 250,
            },
            no_speech_threshold=0.6,
            log_prob_threshold=-1.0,
            compression_ratio_threshold=2.4,
            condition_on_previous_text=False,
        )

        segs = list(segments)
        transcript = " ".join(seg.text.strip() for seg in segs).strip()
        whisper_lang = info.language
        confidence = round(info.language_probability, 3)

        is_empty = False
        if _is_hallucination(transcript) or confidence < 0.4:
            print(f"⚠️ Rejected as hallucination/low-confidence: '{transcript}' (conf={confidence})")
            transcript = ""
            is_empty = True

        # When the user pinned the language, that label wins over Whisper's report
        if whisper_lang_hint:
            language_label = "urdu" if whisper_lang_hint == "ur" else "english"
        else:
            language_label = _map_language(whisper_lang, transcript)

        print(f"TRANSCRIPT: '{transcript}'")
        print(f"WHISPER LANG: {whisper_lang} (confidence: {confidence}, duration: {duration:.2f}s)")

        if wav_path and os.path.exists(wav_path):
            try:
                os.unlink(wav_path)
            except OSError:
                pass

        return {
            "transcript": transcript,
            "language_detected": language_label,
            "whisper_language": whisper_lang,
            "confidence": confidence,
            "is_empty": is_empty,
        }

    except Exception as e:
        print("\n" + "=" * 70)
        print("❌ ERROR inside transcribe_audio")
        print("=" * 70)
        traceback.print_exc()
        print("=" * 70 + "\n")
        raise



