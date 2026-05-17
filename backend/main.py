# pyrefly: ignore [missing-import]
from fastapi import FastAPI
# pyrefly: ignore [missing-import]
from fastapi.middleware.cors import CORSMiddleware
import logging
import uvicorn
from config.settings import settings
from config.database import initialize_firebase
from routes import auth, farms, zones, devices, analytics
from services.mqtt_client import start_mqtt_client

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="SmartAgro AI API",
    description="Backend API for Smart Irrigation and Precision Agriculture Management System",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(farms.router, prefix="/api/v1/farms", tags=["Farms"])
app.include_router(zones.router, prefix="/api/v1/farms", tags=["Zones"])
app.include_router(devices.router, prefix="/api/v1/devices", tags=["Devices"])
app.include_router(analytics.router, prefix="/api/v1/analytics", tags=["Analytics"])

@app.on_event("startup")
async def startup_event():
    logger.info("Starting up SmartAgro AI Backend...")
    initialize_firebase()
    start_mqtt_client()

@app.get("/", tags=["Health"])
def health_check():
    return {"status": "healthy", "service": "SmartAgro AI API"}

if __name__ == "__main__":
    uvicorn.run("main:app", host=settings.HOST, port=settings.PORT, reload=settings.DEBUG)
