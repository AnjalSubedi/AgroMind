import torch
import sys

MODEL_PATH = "models/kisanai_rice_complete.pth"
DEVICE = "cpu"

class Config:
    pass
import __main__
setattr(__main__, "Config", Config)

try:
    checkpoint = torch.load(MODEL_PATH, map_location=DEVICE, weights_only=False)
    state_dict = checkpoint["model_state_dict"] if "model_state_dict" in checkpoint else checkpoint
    
    print("Inspecting fc keys:")
    for key in state_dict.keys():
        if key.startswith("fc."):
            print(f"{key}: {state_dict[key].shape}")
            
except Exception as e:
    print(f"Error: {e}")
