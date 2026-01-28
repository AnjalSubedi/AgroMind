
import firebase_admin
from firebase_admin import credentials, firestore
import sys

# Check for arguments
if len(sys.argv) < 2:
    print("Usage: python verify_user.py <USER_UID> [true/false]")
    sys.exit(1)

user_uid = sys.argv[1]
verify_status = True  # Default to True

if len(sys.argv) > 2:
    status_arg = sys.argv[2].lower()
    if status_arg == "false":
        verify_status = False

# Initialize Firebase Admin
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

try:
    user_ref = db.collection(u'users').document(user_uid)
    doc = user_ref.get()

    if doc.exists:
        user_ref.update({u'isVerified': verify_status})
        print(f"Successfully updated user {user_uid}: isVerified = {verify_status}")
    else:
        print(f"User {user_uid} not found.")

except Exception as e:
    print(f"An error occurred: {e}")
