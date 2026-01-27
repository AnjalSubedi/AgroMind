import zipfile
import re
import sys

MODEL_PATH = "models/kisanai_rice_complete.pth"

try:
    with zipfile.ZipFile(MODEL_PATH, 'r') as z:
        # List all files
        files = z.namelist()
        print("Files in zip:", files)
        
        # Look for pickle file
        pkl_file = next((f for f in files if f.endswith('data.pkl')), None)
        if not pkl_file:
             # Maybe it's not named data.pkl, usually it is.
             # Try any file that is not 'version' or empty
             pkl_file = next((f for f in files if 'data' in f), None)
             
        if pkl_file:
            print(f"Inspecting {pkl_file}...")
            with z.open(pkl_file) as f:
                content = f.read()
                # Simple string extraction for ASCII characters
                # Look for module names like 'foo.bar'
                strings = re.findall(b'[a-zA-Z0-9_.]+', content)
                for s in strings:
                    if len(s) > 4:
                         try:
                             decoded = s.decode('utf-8')
                             if 'ResNet' in decoded or 'model' in decoded or 'Rice' in decoded:
                                 print("Found candidate:", decoded)
                         except:
                             pass
        else:
            print("No pickle file found.")
            
except Exception as e:
    print(f"Error: {e}")
