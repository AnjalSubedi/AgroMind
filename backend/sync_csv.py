
import pandas as pd
import json
import os

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE_DIR, "disease_guide.csv")
JSON_PATH = os.path.join(BASE_DIR, "../assets/models/disease_data.json")

def sync_data():
    if not os.path.exists(CSV_PATH):
        print(f"Error: CSV not found at {CSV_PATH}")
        return

    if not os.path.exists(JSON_PATH):
        print(f"Error: JSON not found at {JSON_PATH}")
        return

    # Load Data
    try:
        df = pd.read_csv(CSV_PATH)
        print(f"Loaded CSV with {len(df)} rows.")
        
        with open(JSON_PATH, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
        rice_data = data.get('rice', {})
        print(f"Loaded JSON with {len(rice_data)} rice diseases.")
        
        updated_count = 0
        
        for index, row in df.iterrows():
            label = str(row['label']).strip()
            
            # Find matching key in JSON (exact match first)
            if label in rice_data:
                info = rice_data[label]
                
                # Update fields
                df.at[index, 'disease'] = info.get('name', row['disease'])
                df.at[index, 'symptoms'] = info.get('description', row['symptoms'])
                
                treatments = info.get('treatment', [])
                if treatments:
                    # Join treatments with semicolon
                    df.at[index, 'actions'] = "; ".join(treatments)
                    
                updated_count += 1
                print(f"Updated: {label}")
            else:
                print(f"Skipped: {label} (Not found in JSON)")
                
        # Save back to CSV
        df.to_csv(CSV_PATH, index=False)
        print(f"✅ Successfully updated {updated_count} rows in {CSV_PATH}")
        
    except Exception as e:
        print(f"❌ Error during sync: {e}")

if __name__ == "__main__":
    sync_data()
