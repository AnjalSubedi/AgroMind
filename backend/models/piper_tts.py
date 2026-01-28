# Piper TTS Module for Hindi and English Text-to-Speech
import os
import subprocess
import tempfile
import wave
import urllib.request
from pathlib import Path

# Directory to store voice models
MODELS_DIR = Path(__file__).parent / "piper_models"
MODELS_DIR.mkdir(exist_ok=True)

# Available voice models
VOICE_MODELS = {
    "en": {
        "name": "en_US-lessac-medium",
        "url": "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx",
        "config_url": "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json"
    },
    "hi": {
        "name": "hi_IN-rohan-medium", 
        "url": "https://huggingface.co/rhasspy/piper-voices/resolve/main/hi/hi_IN/rohan/medium/hi_IN-rohan-medium.onnx",
        "config_url": "https://huggingface.co/rhasspy/piper-voices/resolve/main/hi/hi_IN/rohan/medium/hi_IN-rohan-medium.onnx.json"
    }
}

def get_model_path(language: str) -> tuple:
    """Get paths to model and config files for a language"""
    if language not in VOICE_MODELS:
        raise ValueError(f"Unsupported language: {language}. Supported: {list(VOICE_MODELS.keys())}")
    
    model_info = VOICE_MODELS[language]
    model_path = MODELS_DIR / f"{model_info['name']}.onnx"
    config_path = MODELS_DIR / f"{model_info['name']}.onnx.json"
    
    return model_path, config_path

def download_model(language: str) -> bool:
    """Download voice model for specified language"""
    if language not in VOICE_MODELS:
        print(f"[ERROR] Unknown language: {language}")
        return False
    
    model_info = VOICE_MODELS[language]
    model_path, config_path = get_model_path(language)
    
    try:
        # Download model file
        if not model_path.exists():
            print(f"[DOWNLOAD] Downloading {model_info['name']} model...")
            urllib.request.urlretrieve(model_info['url'], model_path)
            print(f"[OK] Downloaded: {model_path.name}")
        else:
            print(f"[OK] Model already exists: {model_path.name}")
        
        # Download config file
        if not config_path.exists():
            print(f"[DOWNLOAD] Downloading {model_info['name']} config...")
            urllib.request.urlretrieve(model_info['config_url'], config_path)
            print(f"[OK] Downloaded: {config_path.name}")
        else:
            print(f"[OK] Config already exists: {config_path.name}")
        
        return True
        
    except Exception as e:
        print(f"[ERROR] Error downloading model: {e}")
        return False

def is_model_available(language: str) -> bool:
    """Check if model files exist for a language"""
    try:
        model_path, config_path = get_model_path(language)
        return model_path.exists() and config_path.exists()
    except ValueError:
        return False

def text_to_speech(text: str, language: str = "en", output_file: str = None) -> str:
    """
    Convert text to speech using Piper TTS
    """
    # Ensure model is downloaded
    if not is_model_available(language):
        print(f"[DOWNLOAD] Model for {language} not found. Downloading...")
        if not download_model(language):
            raise RuntimeError(f"Failed to download model for {language}")
    
    model_path, config_path = get_model_path(language)
    
    # Create output file if not specified
    if output_file is None:
        fd, output_file = tempfile.mkstemp(suffix=".wav")
        os.close(fd)
    
    try:
        # Use piper command line tool
        cmd = [
            "piper",
            "--model", str(model_path),
            "--config", str(config_path),
            "--output_file", output_file
        ]
        
        # Run piper with text input
        # We must set PYTHONIOENCODING=utf-8 to ensure subprocess reads stdin correctly
        env = os.environ.copy()
        env["PYTHONIOENCODING"] = "utf-8"
        
        process = subprocess.run(
            cmd,
            input=text,
            text=True,
            capture_output=True,
            timeout=30,
            encoding='utf-8',
            env=env
        )
        
        if process.returncode != 0:
            raise RuntimeError(f"Piper TTS failed: {process.stderr}")
        
        print(f"[OK] Audio generated: {output_file}")
        return output_file
        
    except subprocess.TimeoutExpired:
        raise RuntimeError("TTS generation timed out")
    except FileNotFoundError:
        raise RuntimeError("Piper not found. Please install with: pip install piper-tts")

def text_to_speech_bytes(text: str, language: str = "en") -> bytes:
    """Convert text to speech and return audio bytes"""
    # Simplification: No mixed language support needed for now as we have specific buttons
    output_file = text_to_speech(text, language)
    
    try:
        with open(output_file, "rb") as f:
            audio_bytes = f.read()
        return audio_bytes
    finally:
        # Clean up temp file
        if os.path.exists(output_file):
            os.remove(output_file)

def get_available_voices() -> dict:
    """Get information about available voices"""
    voices = {}
    for lang, info in VOICE_MODELS.items():
        voices[lang] = {
            "name": info["name"],
            "available": is_model_available(lang),
            "language_name": "English" if lang == "en" else "Hindi"
        }
    return voices
