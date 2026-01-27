import os
import tempfile
import speech_recognition as sr
from pydub import AudioSegment


def transcribe_audio(file_path: str) -> str:
    """
    Normalizes and transcribes audio file to text using Google Speech Recognition.
    Tries Nepali first, then falls back to English.
    """

    if not os.path.isfile(file_path):
        raise FileNotFoundError(f"Audio file not found: {file_path}")

    wav_filename = None
    work_file = file_path

    try:
        # 1. Normalize audio
        try:
            print(f"🔄 Processing audio: {file_path}")
            audio = AudioSegment.from_file(file_path)

            with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
                wav_filename = tmp.name

            audio = audio.set_frame_rate(16000).set_channels(1)
            audio.export(wav_filename, format="wav")

            work_file = wav_filename
            print(
                f"✅ Audio normalized: "
                f"{audio.duration_seconds:.2f}s, "
                f"{audio.frame_rate}Hz, {audio.channels}ch"
            )

        except Exception as e:
            print(f"⚠️ Audio normalization failed: {e}")
            print("   Using original file.")
            work_file = file_path

        # 2. Transcription
        r = sr.Recognizer()
        print("▶️ Starting transcription...")

        with sr.AudioFile(work_file) as source:
            audio_data = r.record(source)

        # Try Nepali first
        try:
            text = r.recognize_google(audio_data, language="ne-NP")
            print(f"🎤 Transcribed (NE): \"{text}\"")
        except sr.UnknownValueError:
            print("⚠️ Nepali failed, trying English...")
            text = r.recognize_google(audio_data, language="en-US")
            print(f"🎤 Transcribed (EN): \"{text}\"")

        return text

    finally:
        if wav_filename and os.path.exists(wav_filename):
            try:
                os.remove(wav_filename)
            except Exception as e:
                print(f"⚠️ Temp file cleanup failed: {e}")
