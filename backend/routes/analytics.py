from fastapi import APIRouter, Depends, HTTPException
from routes.auth import get_current_user
from config.database import get_db
from services.ai_recommendation import generate_irrigation_recommendation
from google.cloud.firestore_v1.base_query import FieldFilter

router = APIRouter()

@router.get("/recommendations/{zone_id}")
async def get_zone_recommendation(zone_id: str, user: dict = Depends(get_current_user)):
    db = get_db()
    
    zone_doc = db.collection("Zones").document(zone_id).get()
    if not zone_doc.exists:
        raise HTTPException(status_code=404, detail="Zone not found")
    zone_data = zone_doc.to_dict()
    
    farm_doc = db.collection("Farms").document(zone_data["farmId"]).get()
    farm_data = farm_doc.to_dict()
    
    # Get latest telemetry for this zone's devices
    devices = db.collection("Devices").where(filter=FieldFilter("zoneId", "==", zone_id)).stream()
    device_ids = [doc.to_dict()["deviceId"] for doc in devices]
    
    latest_telemetry = {}
    if device_ids:
        # Simplification: getting the latest reading from the first device in the zone
        readings = db.collection("SensorData").where(filter=FieldFilter("deviceId", "==", device_ids[0])).order_by("timestamp", direction="DESCENDING").limit(1).stream()
        for doc in readings:
            latest_telemetry = doc.to_dict()
            
    lat, lon = 0.0, 0.0
    if "location" in farm_data:
        try:
            parts = farm_data["location"].split(",")
            lat, lon = float(parts[0]), float(parts[1])
        except:
            pass

    recommendation = generate_irrigation_recommendation(
        farm_lat=lat,
        farm_lon=lon,
        zone_data=zone_data,
        current_telemetry=latest_telemetry
    )
    
    return recommendation
