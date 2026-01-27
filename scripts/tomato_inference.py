import numpy as np
import cv2
import torch
import torch.nn as nn
from torchvision import models, transforms
from ultralytics import YOLO
import yaml
import os

# ------------------ CONFIG ------------------
# NOTE: These paths are placeholders. You need to place the model files 
# (best.pt, resnet18_tomato_best.pth, data.yaml) in the same directory 
# or update these paths.
MODEL_DIR = os.path.dirname(os.path.abspath(__file__))
LEAF_MODEL = os.path.join(MODEL_DIR, "best.pt") 
CLS_MODEL  = os.path.join(MODEL_DIR, "resnet18_tomato_best .pth")
DATA_YAML  = os.path.join(MODEL_DIR, "data.yaml")

IMG_SIZE   = 224
CONF_THRES = 0.4
PAD_RATIO  = 0.2
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
# --------------------------------------------

def load_models():
    """
    Loads the YOLO leaf detector and ResNet classifier.
    Returns: (detector, classifier, class_names)
    """
    # Load class names
    if os.path.exists(DATA_YAML):
        with open(DATA_YAML, "r", encoding="utf-8") as f:
            class_names = yaml.safe_load(f)["names"]
    else:
        print(f"Warning: {DATA_YAML} not found. Using dummy classes.")
        class_names = []

    num_classes = len(class_names)

    # Load classifier
    print(f"Loading Classifier from {CLS_MODEL}...")
    model = models.resnet18(weights=None)
    # Adjust the final layer to match the number of classes
    # Note: We assume the model structure matches ResNet18
    # If the loaded weights rely on strict architecture, ensure num_classes is correct
    try:
        model.fc = nn.Linear(model.fc.in_features, num_classes)
        if os.path.exists(CLS_MODEL):
            model.load_state_dict(torch.load(CLS_MODEL, map_location=DEVICE))
        else:
             print(f"Warning: {CLS_MODEL} not found.")
        model = model.to(DEVICE).eval()
    except Exception as e:
        print(f"Error loading classifier: {e}")
        model = None

    # Load YOLO leaf detector
    print(f"Loading YOLO Detector from {LEAF_MODEL}...")
    if os.path.exists(LEAF_MODEL):
        detector = YOLO(LEAF_MODEL)
    else:
        print(f"Warning: {LEAF_MODEL} not found.")
        detector = None

    return detector, model, class_names

# Image transform (same as training)
val_tfms = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])

def crop_largest_leaf(detector, img_bgr):
    """
    Uses YOLO to detect leaves and crops the largest one.
    """
    if detector is None:
        return img_bgr # Fallback if no detector

    h, w = img_bgr.shape[:2]
    results = detector.predict(source=img_bgr, conf=CONF_THRES, iou=0.5, verbose=False)
    
    if not results:
        return None
        
    r = results[0]

    if r.boxes is None or len(r.boxes) == 0:
        return None

    boxes = r.boxes.xyxy.cpu().numpy()
    # Calculate area for each box
    areas = (boxes[:,2]-boxes[:,0]) * (boxes[:,3]-boxes[:,1])
    # Take the largest box
    x1, y1, x2, y2 = boxes[int(np.argmax(areas))]

    bw, bh = (x2-x1), (y2-y1)
    pad = int(max(bw, bh) * PAD_RATIO)

    x1 = max(0, int(x1 - pad))
    y1 = max(0, int(y1 - pad))
    x2 = min(w, int(x2 + pad))
    y2 = min(h, int(y2 + pad))

    crop = img_bgr[y1:y2, x1:x2]
    if crop.size == 0:
        return None

    return crop

def predict_disease(image_path):
    """
    Main inference function.
    """
    detector, model, class_names = load_models()
    
    img = cv2.imread(image_path)
    if img is None:
        return {"error": "Invalid image path"}

    # 1. Detect and Crop
    crop = crop_largest_leaf(detector, img)
    if crop is None:
        return {"error": "No leaf detected"}

    # 2. Preprocess
    crop_rgb = cv2.cvtColor(crop, cv2.COLOR_BGR2RGB)
    x = val_tfms(crop_rgb).unsqueeze(0).to(DEVICE)

    # 3. Classify
    if model:
        with torch.no_grad():
            logits = model(x)
            probs = torch.softmax(logits, dim=1)[0]
            pred = int(torch.argmax(probs).item())

        return {
            "class_name": class_names[pred] if pred < len(class_names) else str(pred),
            "confidence": float(probs[pred].item()),
            "class_id": pred
        }
    else:
        return {"error": "Classifier model not loaded"}

if __name__ == "__main__":
    # Example usage
    import sys
    if len(sys.argv) > 1:
        print(predict_disease(sys.argv[1]))
    else:
        print("Usage: python tomato_inference.py <image_path>")
