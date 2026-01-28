
import firebase_admin
from firebase_admin import credentials, firestore
import sys

# Check for arguments
if len(sys.argv) < 2:
    print("Usage: python make_admin.py <USER_UID> [true/false]")
    sys.exit(1)

user_uid = sys.argv[1]
admin_status = True  # Default to True

if len(sys.argv) > 2:
    status_arg = sys.argv[2].lower()
    if status_arg == "false":
        admin_status = False

# Initialize Firebase Admin (Ensure credentials exist)
try:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
except ValueError:
    # App already initialized
    pass

db = firestore.client()

try:
    user_ref = db.collection(u'users').document(user_uid)
    doc = user_ref.get()

    if doc.exists:
        # We also auto-verify admins because... well, they are admins.
        user_ref.update({
            u'isAdmin': admin_status,
            u'isVerified': admin_status if admin_status else doc.get('isVerified')
        })
        print(f"Successfully updated user {user_uid}: isAdmin = {admin_status}")
    else:
        print(f"User {user_uid} not found. Please register in the app first.")

except Exception as e:
    print(f"An error occurred: {e}")
