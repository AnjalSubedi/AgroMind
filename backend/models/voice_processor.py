import os
import speech_recognition as sr
from pydub import AudioSegment

def transcribe_audio(file_path: str) -> str:
    """
    Normalizes and transcribes audio file to text using Google Speech Recognition.
    
    Args:
        file_path (str): Path to the audio file (wav, mp3, m4a, etc.)
        
    Returns:
        str: The transcribed text.
        
    Raises:
        sr.UnknownValueError: If audio is unintelligible
        sr.RequestError: If API call fails
        Exception: For other errors
    """
    wav_filename = None
    work_file = file_path
    
    try:
        # 1. Normalize Audio (Convert to 16kHz Mono WAV)
        try:
            print(f"🔄 Processing audio: {file_path}")
            audio = AudioSegment.from_file(file_path)
            
            # Create a temporary converted file path
            wav_filename = file_path + "_converted.wav"
            
            # Normalize: 16kHz, Mono (1 channel) - Ideal for Speech Recognition
            audio = audio.set_frame_rate(16000).set_channels(1)
            audio.export(wav_filename, format="wav")
            
            work_file = wav_filename
            print(f"✅ Audio normalized: {audio.duration_seconds:.2f}s, {audio.frame_rate}Hz, {audio.channels}ch")
            
        except Exception as e:
            print(f"⚠️ Audio normalization warning: {e}")
            print("   Attempting to use original file directly (ffmpeg might be missing).")
            # Fallback to original file
            work_file = file_path

        # 2. Transcribe via Google Speech Recognition
        print("▶️ Starting Transcription...")
        r = sr.Recognizer()
        
        with sr.AudioFile(work_file) as source:
            print("   Reading audio data...")
            audio_data = r.record(source)
            
            print("   Sending to Google Speech API...")
            # recognize_google is free and doesn't verify API key for low volume
            text = r.recognize_google(audio_data)
            print(f"🎤 Transcribed: \"{text}\"")
            
            return text

    finally:
        # Cleanup the temporary converted file if it exists
        if wav_filename and os.path.exists(wav_filename):
            try:
                os.remove(wav_filename)
            except Exception:
                pass
