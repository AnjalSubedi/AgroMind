from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from fastapi.responses import JSONResponse
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
from PIL import Image
import speech_recognition as sr # Removed - moved to voice_processor
import tempfile
import shutil
# pydub removed - moved to voice_processor
from models.voice_processor import transcribe_audio


# Load .env from parent directory
load_dotenv(os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env"))

app = FastAPI(title="Crop Disease Detection API")

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
TOMATO_LEAF_MODEL = os.path.join(MODELS_PATH, "best.pt")
TOMATO_CLS_MODEL  = os.path.join(MODELS_PATH, "resnet18_tomato_best.pth")
TOMATO_DATA_YAML  = os.path.join(MODELS_PATH, "data.yaml")
TOMATO_IMG_SIZE   = 224
TOMATO_CONF_THRES = 0.4
TOMATO_PAD_RATIO  = 0.2

# ------------------ POTATO CONFIG ------------------
POTATO_CKPT_PATH = os.path.join(MODELS_PATH, "best_potato_realworld.pth")

# ------------------ RICE CONFIG ------------------
RICE_MODEL_PATH = os.path.join(MODELS_PATH, "kisanai_rice_complete.pth")
RICE_IMG_SIZE = 224
RICE_CLASSES = [
    "bacterial_leaf_blight",
    "bacterial_leaf_streak",
    "bacterial_panicle_blight",
    "blast",
    "brown_spot",
    "dead_heart",
    "downy_mildew",
    "hispa",
    "normal",
    "tungro"
]

# Global variables for models
tomato_detector = None
tomato_classifier = None
tomato_class_names = []

potato_model = None
potato_classes = []
potato_img_size = 224
potato_mean = [0.485, 0.456, 0.406]
potato_std = [0.229, 0.224, 0.225]
potato_preprocess = None

rice_model = None
rice_preprocess = None

# ------------------ HEALTH LOGIC ------------------

def load_csv():
    global paddy_diseases
    csv_path = os.path.join(MODEL_DIR, "disease_guide.csv")
    
    if not os.path.exists(csv_path):
        print(f"❌ ERROR: CSV file not found at {csv_path}")
        return False

    try:
        paddy_diseases = pd.read_csv(csv_path)
        print(f"✅ Loaded {len(paddy_diseases)} diseases from {csv_path}")
        return True
    except Exception as e:
        print(f"❌ Error loading CSV: {e}")
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
        print(f"❌ Translation error: {e}")
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
        print("⚠️ Cohere client unavailable, using fallback")
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
        print(f"❌ Cohere error: {e}")
        return fallback_match(user_symptoms)

# ------------------ LOAD MODELS ------------------
def load_tomato_models():
    global tomato_detector, tomato_classifier, tomato_class_names
    
    # Load class names
    if os.path.exists(TOMATO_DATA_YAML):
        with open(TOMATO_DATA_YAML, "r", encoding="utf-8") as f:
            tomato_class_names = yaml.safe_load(f)["names"]
    
    num_classes = len(tomato_class_names)

    # Load classifier
    print(f"Loading Tomato Classifier from {TOMATO_CLS_MODEL}...")
    model = models.resnet18(weights=None)
    model.fc = nn.Linear(model.fc.in_features, num_classes)
    if os.path.exists(TOMATO_CLS_MODEL):
        model.load_state_dict(torch.load(TOMATO_CLS_MODEL, map_location=DEVICE, weights_only=False))
        print("Tomato Classifier loaded successfully.")
    else:
        print(f"Warning: {TOMATO_CLS_MODEL} not found.")

    tomato_classifier = model.to(DEVICE).eval()

    # Load YOLO leaf detector
    print(f"Loading Tomato YOLO Detector from {TOMATO_LEAF_MODEL}...")
    if os.path.exists(TOMATO_LEAF_MODEL):
        tomato_detector = YOLO(TOMATO_LEAF_MODEL)
        print("Tomato Detector loaded successfully.")
    else:
        print(f"Warning: {TOMATO_LEAF_MODEL} not found.")

def load_potato_models():
    global potato_model, potato_classes, potato_img_size, potato_mean, potato_std, potato_preprocess

    print(f"Loading Potato Model from {POTATO_CKPT_PATH}...")
    if not os.path.exists(POTATO_CKPT_PATH):
        print(f"Warning: {POTATO_CKPT_PATH} not found.")
        return

    ckpt = torch.load(POTATO_CKPT_PATH, map_location=DEVICE, weights_only=False)
    potato_classes = ckpt["classes"]
    potato_img_size = ckpt["img_size"]
    potato_mean = ckpt["mean"]
    potato_std = ckpt["std"]
    """Load updated Potato ResNet50 classifier"""
    global potato_model
    try:
        model_path = os.path.join("models", "potato_resnet50_new.pt")
        if os.path.exists(model_path):
             print(f"✅ Loading Potato Model from {model_path}...")
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
             print(f"❌ Potato model not found at {model_path}")

    except Exception as e:
        print(f"❌ Error loading Potato model: {e}")

def load_rice_models():
    """Load updated Rice ResNet50 classifier"""
    global rice_model
    try:
        model_path = os.path.join("models", "rice_new.pth")
        if os.path.exists(model_path):
             print(f"✅ Loading Rice Model from {model_path}...")
             # Initialize ResNet50 (Changed from EfficientNet)
             rice_model = models.resnet50(weights=None)
             rice_model.fc = nn.Linear(rice_model.fc.in_features, len(RICE_CLASSES))
             
             state_dict = torch.load(model_path, map_location=DEVICE)
             rice_model.load_state_dict(state_dict)
             
             rice_model.to(DEVICE)
             rice_model.eval()
        else:
             print(f"❌ Rice model not found at {model_path}")
             
    except Exception as e:
        print(f"❌ Error loading Rice model: {e}")

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
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

potato_preprocess = standard_val_tfms
rice_preprocess = standard_val_tfms



# ------------------ MEMORY MANAGEMENT ------------------
import gc

def unload_models():
    """Release all models from memory to prevent OOM"""
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
        unload_models()
        load_tomato_models()
        
    elif model_type == 'potato':
        if potato_model is not None: return
        print("🔄 Switching to POTATO model...")
        unload_models()
        load_potato_models()
        
    elif model_type == 'rice':
        if rice_model is not None: return
        print("🔄 Switching to RICE model...")
        unload_models()
        load_rice_models()

# Initialize CSV only on startup (low memory)
load_csv()
# Do NOT load heavy models here. They will load on first request.


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

class TextDiagnosisRequest(BaseModel):
    text: str
    language: str = "en"

@app.post("/diagnose-text")
async def diagnose_text_endpoint(request: TextDiagnosisRequest):
    try:
        original_text = request.text
        if not original_text:
             return JSONResponse(status_code=400, content={"error": "No text provided"})

        # Translate
        english_text = translate_to_english(original_text)
        
        # Classify
        predictions = classify_with_cohere(english_text)
        
        # Translate response back to Nepali if requested
        if request.language == 'ne':
            predictions = translate_predictions_to_nepali(predictions)
            
        return {
            "success": True,
            "original_text": original_text,
            "translated_text": english_text,
            "predictions": predictions,
            "total_predictions": len(predictions)
        }
    except Exception as e:
        return JSONResponse(status_code=500, content={"success": False, "error": str(e)})

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

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
