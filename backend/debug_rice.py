import torch
import torch.nn as nn
from torchvision import models
import os

MODEL_PATH = "models/kisanai_rice_complete.pth"
DEVICE = "cpu"

print(f"Checking {MODEL_PATH}...")
if not os.path.exists(MODEL_PATH):
    print("File not found!")
    exit(1)

print("File found. Attempting to load state dict...")
try:
    # Try loading with weights_only=False just in case
    obj = torch.load(MODEL_PATH, map_location=DEVICE, weights_only=False)
    print(f"Object loaded. Type: {type(obj)}")
    
    if isinstance(obj, dict):
         print("It is a state dict.")
         # ... existing logic
         if "state_dict" in obj:
             print("Found 'state_dict' key.")
             state_dict = obj["state_dict"]
         else:
             state_dict = obj
             
         print("Building ResNet50...")
         model = models.resnet50(weights=None)
         model.fc = nn.Linear(model.fc.in_features, 10)
         model.load_state_dict(state_dict)
         print("Success loading state dict!")
         
    elif isinstance(obj, nn.Module):
        print("It is a full model.")
        print("Success loading full model!")
    else:
        print("Unknown object type.")

except Exception as e:
    print(f"Global Load Failed: {e}")
    import traceback
    traceback.print_exc()
