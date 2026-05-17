import firebase_admin
from firebase_admin import credentials, firestore, auth
from config.settings import settings
import os
import logging

db = None

def initialize_firebase():
    global db
    try:
        if not firebase_admin._apps:
            if os.path.exists(settings.FIREBASE_CREDENTIALS_PATH):
                cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
                firebase_admin.initialize_app(cred)
                logging.info("Firebase Admin initialized successfully.")
            else:
                logging.warning(f"Firebase credentials not found at {settings.FIREBASE_CREDENTIALS_PATH}. Using default app (might fail if not deployed on GCP).")
                firebase_admin.initialize_app()
        db = firestore.client()
    except Exception as e:
        # Do not raise error to allow server to start without credentials for demonstration
        pass

def get_db():
    if db is None:
        initialize_firebase()
    return db
