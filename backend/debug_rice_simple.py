import torch
import sys

try:
    torch.load('models/kisanai_rice_complete.pth', map_location='cpu', weights_only=False)
except Exception as e:
    with open('error_msg.txt', 'w') as f:
        f.write(str(e))
    print("Error written to file")
