from fastapi import FastAPI, File, UploadFile, HTTPException, Form, Request, Response
from fastapi.responses import JSONResponse
import sys
from fastapi.staticfiles import StaticFiles # [NEW]
from pydantic import BaseModel
import uvicorn
import cohere
import pandas as pd
from deep_translator import GoogleTranslator
from dotenv import load_dotenv
import json
import numpy as np
import cv2
import torch
import torch.nn as nn
from torchvision import models, transforms
from torchvision.models import efficientnet_v2_s
from ultralytics import YOLO
import yaml
import os
import io
import uuid # [NEW]
from PIL import Image
import speech_recognition as sr 
import tempfile
import shutil
from models.voice_processor import transcribe_audio


# Load .env from parent directory
load_dotenv(os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env"))

app = FastAPI(title="Crop Disease Detection API")

# [FIX] CORS Middleware
from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ------------------ IMAGE STORAGE CONFIG (AWS Alternative) ------------------
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# ------------------ SHARED CONFIG ------------------
MODEL_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_PATH = os.path.join(MODEL_DIR, "models")

# Voice/Text Diagnosis Config
COHERE_API_KEY = os.getenv("COHERE_API_KEY")
try:
    if COHERE_API_KEY:
        co = cohere.Client(COHERE_API_KEY)
    else:
        print("⚠️ WARNING: COHERE_API_KEY not found in .env")
        co = None
except Exception as e:
    print(f"⚠️ Cohere Client Init Error: {e}")
    co = None

paddy_diseases = None

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# ------------------ TOMATO CONFIG ------------------
# 10 Classes
TOMATO_CLASSES = [
    "Bacterial Spot", "Early Blight", "Healthy", "Late Blight", "Leaf Mold", 
    "Leaf_Miner", "Mosaic Virus", "Septoria", "Spider Mites", "Yellow Leaf Curl Virus"
]
TOMATO_IMG_SIZE   = 224
TOMATO_CONF_THRES = 0.4
TOMATO_PAD_RATIO  = 0.2

tomato_class_names = TOMATO_CLASSES # Alias for compatibility

# ------------------ POTATO CONFIG ------------------
# 3 Classes
potato_classes = ["Early_Blight", "Healthy", "Late_Blight"]
potato_img_size = 256
potato_mean = [0.485, 0.456, 0.406]
potato_std = [0.229, 0.224, 0.225]

# ------------------ RICE CONFIG ------------------
# 12 Classes - Must match rice_new.pth output
RICE_CLASSES = [
    "bacterial_leaf_blight", "bacterial_leaf_streak", "bacterial_panicle_blight",
    "blast", "brown_spot", "dead_heart", "downy_mildew", "hispa", 
    "leaf_smut", "normal", "sheath_blight", "tungro"
]

# Global variables for models
tomato_detector = None
tomato_classifier = None

potato_model = None

rice_model = None

# ------------------ HEALTH LOGIC ------------------

def load_csv():
    global paddy_diseases
    csv_path = os.path.join(MODEL_DIR, "disease_guide.csv")
    
    if not os.path.exists(csv_path):
        print(f" ERROR: CSV file not found at {csv_path}")
        return False

    try:
        paddy_diseases = pd.read_csv(csv_path)
        print(f"Loaded {len(paddy_diseases)} diseases from {csv_path}")
        return True
    except Exception as e:
        print(f" Error loading CSV: {e}")
        return False

def translate_to_english(text):
    """Translate any language to English using deep-translator"""
    try:
        # Check if text is already in English (simple heuristic)
        ascii_ratio = sum(1 for c in text if ord(c) < 128) / len(text) if len(text) > 0 else 0
        
        if ascii_ratio > 0.9:
            return text
        
        translator = GoogleTranslator(source='auto', target='en')
        translated_text = translator.translate(text)
        return translated_text
    except Exception as e:
        print(f"Translation error: {e}")
        return text

def fallback_match(user_text):
    """Fallback matching if Cohere fails"""
    if paddy_diseases is None:
        return []
    
    results = []
    user_text_lower = user_text.lower()
    
    for idx, row in paddy_diseases.iterrows():
        symptoms_lower = str(row.get('symptoms', '')).lower()
        
        user_words = set(user_text_lower.split())
        symptom_words = set(symptoms_lower.split())
        common_words = user_words.intersection(symptom_words)
        
        if len(common_words) > 0:
            confidence = min(100, len(common_words) * 10)
            results.append({
                'disease': str(row.get('disease', '')),
                'label': str(row.get('label', '')),
                'confidence': confidence,
                'symptoms': str(row.get('symptoms', '')),
                'actions': str(row.get('actions', '')),
                'prevention': str(row.get('prevention', '')),
                'when_to_escalate': str(row.get('when_to_escalate', ''))
            })
    
    results.sort(key=lambda x: x['confidence'], reverse=True)
    return results[:5]

def classify_with_cohere(user_symptoms):
    """Use Cohere to classify symptoms into top 5 disease labels"""
    if paddy_diseases is None:
        return []
    
    if not co:
        print(" Cohere client unavailable, using fallback")
        return fallback_match(user_symptoms)
        
    try:
        training_examples = []
        for idx, row in paddy_diseases.iterrows():
            training_examples.append({
                'label': row['label'],
                'symptoms': row['symptoms']
            })
        
        prompt = "You are an expert agricultural disease classifier. Classify these symptoms into the TOP 5 most likely disease labels based on the training data provided below.\n\n"
        
        for example in training_examples:
            prompt += f"Label: {example['label']}\nSymptoms: {example['symptoms']}\n"
        
        prompt += f"\n\nFarmer's Description: \"{user_symptoms}\"\n\n"
        prompt += "Return ONLY a JSON array with exactly 5 predictions. Format: [{\"label\": \"...\", \"confidence\": 90}, ...]. Sort by confidence descending."

        response = co.chat(
            model='command-r-08-2024',
            message=prompt,
            temperature=0.3
        )
        
        cohere_response = response.text.strip()
        
        # Parse JSON
        try:
            start_idx = cohere_response.find('[')
            end_idx = cohere_response.rfind(']') + 1
            if start_idx != -1 and end_idx > start_idx:
                json_str = cohere_response[start_idx:end_idx]
                predictions = json.loads(json_str)
            else:
                raise ValueError("No JSON array found")
        except Exception:
             print("⚠️ JSON parsing failed, using fallback")
             return fallback_match(user_symptoms)

        results = []
        for pred in predictions[:5]:
            label = pred['label']
            confidence = pred['confidence']
            matching_rows = paddy_diseases[paddy_diseases['label'] == label]
            
            if not matching_rows.empty:
                row = matching_rows.iloc[0]
                results.append({
                    'disease': str(row['disease']),
                    'label': str(row['label']),
                    'confidence': confidence,
                    'symptoms': str(row['symptoms']),
                    'actions': str(row['actions']),
                    'prevention': str(row['prevention']),
                    'when_to_escalate': str(row['when_to_escalate'])
                })
        
        return results

    except Exception as e:
        print(f" Cohere error: {e}")
        return fallback_match(user_symptoms)

# ------------------ LOAD MODELS ------------------
# ------------------ LOAD MODELS ------------------

def load_tomato_models():
    """Load updated Tomato YOLO detector and ResNet50 classifier"""
    global tomato_detector, tomato_classifier

    try:
        # 1. YOLO Detector
        detector_path = os.path.join(MODELS_PATH, "tomato_yolo_new.pt") 
        if os.path.exists(detector_path):
            print(f" Loading Tomato YOLO from {detector_path}...")
            tomato_detector = YOLO(detector_path) 
        else:
            print(f" Tomato Detector not found at {detector_path}")

        # 2. ResNet50 Classifier
        classifier_path = os.path.join(MODELS_PATH, "tomato_resnet_new.pt")
        if os.path.exists(classifier_path):
            print(f" Loading Tomato Classifier (ResNet50) from {classifier_path}...")
            # Initialize ResNet50
            tomato_classifier = models.resnet50(weights=None)
            tomato_classifier.fc = nn.Linear(tomato_classifier.fc.in_features, len(TOMATO_CLASSES))
            
            # Load weights
            state_dict = torch.load(classifier_path, map_location=DEVICE)
            tomato_classifier.load_state_dict(state_dict)
            tomato_classifier.to(DEVICE)
            tomato_classifier.eval()
        else:
             print(f" Tomato Classifier not found at {classifier_path}")

    except Exception as e:
        print(f" Error loading Tomato models: {e}")

def load_potato_models():
    """Load updated Potato ResNet50 classifier"""
    global potato_model
    try:
        model_path = os.path.join(MODELS_PATH, "potato_resnet50_new.pt")
        if os.path.exists(model_path):
             print(f" Loading Potato Model from {model_path}...")
             # Initialize ResNet50
             potato_model = models.resnet50(weights=None)
             potato_model.fc = nn.Linear(potato_model.fc.in_features, len(potato_classes))
             
             # Load from checkpoint dict
             ckpt = torch.load(model_path, map_location=DEVICE)
             # Handle 'model_state_dict' key if present (as seen in app.py)
             if isinstance(ckpt, dict) and "model_state_dict" in ckpt:
                 potato_model.load_state_dict(ckpt["model_state_dict"])
             else:
                 potato_model.load_state_dict(ckpt)
                 
             potato_model.to(DEVICE)
             potato_model.eval()
        else:
             print(f" Potato model not found at {model_path}")

    except Exception as e:
        print(f" Error loading Potato model: {e}")

def load_rice_models():
    """Load updated Rice ResNet50 classifier"""
    global rice_model
    try:
        model_path = os.path.join(MODELS_PATH, "rice_new.pth")
        if os.path.exists(model_path):
             print(f" Loading Rice Model from {model_path}...")
             # Initialize ResNet50
             rice_model = models.resnet50(weights=None)
             rice_model.fc = nn.Linear(rice_model.fc.in_features, len(RICE_CLASSES))
             
             ckpt = torch.load(model_path, map_location=DEVICE)
             # Unwrap if it's a dict containing 'model_state_dict' (like Potato/Tomato often have)
             if isinstance(ckpt, dict) and 'model_state_dict' in ckpt:
                 state_dict = ckpt['model_state_dict']
             else:
                 state_dict = ckpt
                 
             rice_model.load_state_dict(state_dict)
             
             rice_model.to(DEVICE)
             rice_model.eval()
        else:
             print(f" Rice model not found at {model_path}")
             
    except Exception as e:
        print(f" Error loading Rice model: {e}")

# ------------------ PREPROCESSING ------------------
# Potato & Rice: Standard ResNet (Resize 256 -> Crop 224)
standard_val_tfms = transforms.Compose([
    transforms.Resize((256, 256)),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]) 
])

# Tomato: Resize 224 (No Crop) as per app.py
tomato_val_tfms = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

potato_preprocess = standard_val_tfms
rice_preprocess = standard_val_tfms




# ------------------ CONFIG START ------------------
# Optimization for larger RAM servers (EC2)
# If True, models stay in memory. If False, they unload to save RAM.
KEEP_MODELS_LOADED = os.getenv("KEEP_MODELS_LOADED", "False").lower() == "true"
if KEEP_MODELS_LOADED:
    print("🚀 PERFORMANCE MODE: Models will stay loaded in memory.")
else:
    print("🍃 MEMORY SAVER MODE: Models will unload after use.")

# Initialize CSV only on startup (low memory)
load_csv()

# ------------------ MEMORY MANAGEMENT ------------------
import gc

def unload_models():
    """Release all models from memory to prevent OOM"""
    # If performance mode is on, DO NOT unload.
    if KEEP_MODELS_LOADED:
        return

    global tomato_detector, tomato_classifier
    global potato_model
    global rice_model
    
    # Tomato
    tomato_detector = None
    tomato_classifier = None
    
    # Potato
    potato_model = None
    
    # Rice
    rice_model = None
    
    gc.collect()
    print("🧹 Models unloaded from memory")

def ensure_model(model_type: str):
    """
    Ensure only the requested model is loaded. 
    Unloads others to save RAM (Render Free Tier limit 512MB).
    """
    global tomato_classifier, potato_model, rice_model
    
    if model_type == 'tomato':
        if tomato_classifier is not None: return # Already loaded
        print("🔄 Switching to TOMATO model...")
        # Only unload others if we are NOT in keep-loaded mode
        # actually, standard logic: usually we want only 1 active if low ram.
        # if keep loaded, we just load this one if missing.
        if not KEEP_MODELS_LOADED:
            unload_models()
        load_tomato_models()
        
    elif model_type == 'potato':
        if potato_model is not None: return
        print("🔄 Switching to POTATO model...")
        if not KEEP_MODELS_LOADED:
            unload_models()
        load_potato_models()
        
    elif model_type == 'rice':
        if rice_model is not None: return
        print("🔄 Switching to RICE model...")
        if not KEEP_MODELS_LOADED:
            unload_models()
        load_rice_models()


# ------------------ TOMATO UTILS ------------------
TOMATO_CONF_THRES = 0.4
TOMATO_PAD_RATIO = 0.2
TOMATO_IMG_SIZE = 224

# tomato_val_tfms is already defined above, removing duplicate and fixing constants
# The existing tomato_val_tfms above line 330 is correct.


def crop_largest_leaf(img_bgr):
    if tomato_detector is None:
        return None
        
    h, w = img_bgr.shape[:2]
    results = tomato_detector.predict(source=img_bgr, conf=TOMATO_CONF_THRES, iou=0.5, verbose=False)
    
    if not results or results[0].boxes is None or len(results[0].boxes) == 0:
        return None
        
    r = results[0]
    boxes = r.boxes.xyxy.cpu().numpy()
    areas = (boxes[:,2]-boxes[:,0]) * (boxes[:,3]-boxes[:,1])
    x1, y1, x2, y2 = boxes[int(np.argmax(areas))]

    bw, bh = (x2-x1), (y2-y1)
    pad = int(max(bw, bh) * TOMATO_PAD_RATIO)

    x1 = max(0, int(x1 - pad))
    y1 = max(0, int(y1 - pad))
    x2 = min(w, int(x2 + pad))
    y2 = min(h, int(y2 + pad))

    crop = img_bgr[y1:y2, x1:x2]
    if crop.size == 0:
        return None

    return crop

# ------------------ ENDPOINTS ------------------

@app.get("/")
def home():
    return {
        "status": "ok", 
        "models": {
            "tomato": "active" if tomato_classifier else "inactive",
            "potato": "active" if potato_model else "inactive",
            "rice": "active" if rice_model else "inactive"
        }
    }

@app.post("/predict/tomato")
async def predict_tomato(file: UploadFile = File(...)):
    ensure_model('tomato')
    if not tomato_classifier:
        return JSONResponse(status_code=503, content={"error": "Tomato model load failed"})

    data = await file.read()
    img_arr = np.frombuffer(data, np.uint8)
    img = cv2.imdecode(img_arr, cv2.IMREAD_COLOR)

    if img is None:
        return JSONResponse(status_code=400, content={"error": "Invalid image"})

    crop = crop_largest_leaf(img)
    if crop is None:
        return JSONResponse(status_code=400, content={"error": "No leaf detected"})

    crop_rgb = cv2.cvtColor(crop, cv2.COLOR_BGR2RGB)
    x = tomato_val_tfms(crop_rgb).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        logits = tomato_classifier(x)
        probs = torch.softmax(logits, dim=1)[0]
        pred = int(torch.argmax(probs).item())

    return {
        "class": TOMATO_CLASSES[pred] if pred < len(TOMATO_CLASSES) else str(pred),
        "confidence": float(probs[pred].item())
    }

@app.post("/predict/potato")
async def predict_potato(file: UploadFile = File(...)):
    ensure_model('potato')
    if not potato_model:
         return JSONResponse(status_code=503, content={"error": "Potato model load failed"})

    # Validate file type quickly - Relaxed for tolerance
    # if not file.content_type or not file.content_type.startswith("image/"):
    #     return JSONResponse(status_code=400, content={"error": "Please upload an image file."})

    # Read image bytes
    image_bytes = await file.read()
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    except Exception:
        return JSONResponse(status_code=400, content={"error": "Invalid image format"})

    # Preprocess
    x = potato_preprocess(img).unsqueeze(0).to(DEVICE)

    # Inference
    with torch.no_grad():
        logits = potato_model(x)
        probs = torch.softmax(logits, dim=1).squeeze(0)

    conf, idx = torch.max(probs, dim=0)

    return {
        "class": potato_classes[int(idx)],
        "confidence": float(conf.item()),
        "probabilities": {potato_classes[i]: float(probs[i].item()) for i in range(len(potato_classes))}
    }

@app.post("/predict/rice")
async def predict_rice(file: UploadFile = File(...)):
    ensure_model('rice')
    if not rice_model:
         return JSONResponse(status_code=503, content={"error": "Rice model load failed"})

    # Read image bytes
    image_bytes = await file.read()
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    except Exception:
        return JSONResponse(status_code=400, content={"error": "Invalid image format"})

    # Preprocess
    x = rice_preprocess(img).unsqueeze(0).to(DEVICE)

    # Inference
    with torch.no_grad():
        logits = rice_model(x)
        probs = torch.softmax(logits, dim=1).squeeze(0)

    conf, idx = torch.max(probs, dim=0)

    return {
        "class": RICE_CLASSES[int(idx)],
        "confidence": float(conf.item()),
        "probabilities": {RICE_CLASSES[i]: float(probs[i].item()) for i in range(len(RICE_CLASSES))}
    }

@app.post("/upload")
async def upload_image(file: UploadFile = File(...)):
    """
    Uploads an image to the local server (AWS EC2) and returns the public URL.
    Replaces Firebase Storage for community posts.
    """
    try:
        # Validate image
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="File must be an image")

        # Generate unique filename
        filename = f"{uuid.uuid4()}{os.path.splitext(file.filename)[1]}"
        file_path = os.path.join(UPLOAD_DIR, filename)

        # Save to disk
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Return relative URL
        return {"url": f"/uploads/{filename}", "filename": filename}

    except Exception as e:
        print(f"Upload Error: {e}")
        return JSONResponse(status_code=500, content={"error": str(e)})

@app.post("/diagnose-audio")
async def diagnose_audio_endpoint(file: UploadFile = File(...), language: str = Form("en")):
    temp_filename = None
    wav_filename = None
    try:
        # Save uploaded file to temp
        with tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(file.filename)[1] if file.filename else ".tmp") as tmp:
            shutil.copyfileobj(file.file, tmp)
            temp_filename = tmp.name

        # Transcribe using separated module
        try:
            text = transcribe_audio(temp_filename)
        except sr.UnknownValueError:
             return JSONResponse(status_code=400, content={"success": False, "error": "Could not understand audio"})
        except sr.RequestError as e:
             return JSONResponse(status_code=500, content={"success": False, "error": f"Speech API error: {e}"})
        except Exception as e:
             print(f"❌ Audio Processing Error: {e}")
             return JSONResponse(status_code=500, content={"success": False, "error": f"Audio Error: {e}"})

        # Reuse existing logic
        print(f"▶️ Translating text: {text}")
        english_text = translate_to_english(text)
        print(f"▶️ Translated: {english_text}")
        
        print("▶️ Classifying with Cohere...")
        predictions = classify_with_cohere(english_text)
        print(f"✅ Classifications: {len(predictions)}")
        
        # Translate response back to Nepali if requested
        if language == 'ne':
            print("▶️ Translating response to Nepali...")
            predictions = translate_predictions_to_nepali(predictions)

        return {
            "success": True,
            "transcribed_text": text,
            "translated_text": english_text,
            "predictions": predictions,
            "total_predictions": len(predictions)
        }

    except Exception as e:
        print("❌ CRITICAL ERROR IN ENDPOINT ❌")
        import traceback
        traceback.print_exc()
        return JSONResponse(status_code=500, content={"success": False, "error": str(e)})
    finally:
        # Cleanup
        for f in [temp_filename, wav_filename]:
            if f and os.path.exists(f):
                try:
                    os.remove(f)
                except:
                    pass

def translate_predictions_to_nepali(predictions):
    """Translate prediction fields to Nepali"""
    translator = GoogleTranslator(source='en', target='ne')
    
    translated_preds = []
    for p in predictions:
        new_p = p.copy()
        try:
            # Translate key fields
            # We combine them to reduce API calls if possible, but line by line is safer for formatting
            if 'disease' in p: new_p['disease'] = translator.translate(p['disease'])
            if 'symptoms' in p: new_p['symptoms'] = translator.translate(p['symptoms'])
            if 'actions' in p: new_p['actions'] = translator.translate(p['actions'])
            if 'prevention' in p: new_p['prevention'] = translator.translate(p['prevention'])
        except Exception as e:
            print(f"⚠️ Response translation failed: {e}")
        translated_preds.append(new_p)
        
    return translated_preds

# --- TTS Integration ---
sys.path.append(os.path.join(os.path.dirname(__file__), 'models'))
import piper_tts
import asyncio

@app.post("/api/speak")
async def speak(request: Request):
    """Generate audio from text using Piper TTS"""
    try:
        data = await request.json()
        print(f"🔊 Received TTS Request: {data}")  # Debug print
        
        text = data.get('text', '')
        language = data.get('language', 'en')
        
        if not text:
            return JSONResponse(content={'success': False, 'error': 'No text provided'}, status_code=400)
            
        print(f"🔊 Generating audio for ({language}): {text[:50]}...")
        
        # Generate audio bytes
        # Using executor to run blocking TTS generation in thread pool
        loop = asyncio.get_event_loop()
        audio_bytes = await loop.run_in_executor(None, piper_tts.text_to_speech_bytes, text, language)
        
        return Response(content=audio_bytes, media_type="audio/wav")
        
    except Exception as e:
        print(f"❌ TTS Error: {e}")
        import traceback
        traceback.print_exc()
        return JSONResponse(content={'success': False, 'error': str(e)}, status_code=500)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
