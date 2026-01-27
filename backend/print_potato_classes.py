import torch
import sys
import os

MODELS_PATH = "models/best_potato_realworld.pth"
DEVICE = "cpu"

if not os.path.exists(MODELS_PATH):
    print("Model not found")
    exit(1)

try:
    ckpt = torch.load(MODELS_PATH, map_location=DEVICE)
    print("Potato Classes:", ckpt.get("classes", "Unknown"))
except Exception as e:
    print(e)
