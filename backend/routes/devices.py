from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from models.schemas import DeviceCreate, DeviceResponse, SensorData
from routes.auth import get_current_user
from config.database import get_db
import uuid
from datetime import datetime

router = APIRouter()

@router.post("/", response_model=DeviceResponse, status_code=status.HTTP_201_CREATED)
async def register_device(device: DeviceCreate, user: dict = Depends(get_current_user)):
    db = get_db()
    
    # We should normally check if the user owns the zone's farm
    zone_doc = db.collection("Zones").document(device.zoneId).get()
    if not zone_doc.exists:
        raise HTTPException(status_code=404, detail="Zone not found")
        
    device_data = device.model_dump()
    device_data["lastSeen"] = datetime.utcnow().isoformat()
    
    db.collection("Devices").document(device.deviceId).set(device_data)
    return device_data

@router.get("/zone/{zone_id}", response_model=List[DeviceResponse])
async def get_devices_by_zone(zone_id: str, user: dict = Depends(get_current_user)):
    db = get_db()
    devices_ref = db.collection("Devices").where("zoneId", "==", zone_id).stream()
    return [doc.to_dict() for doc in devices_ref]

@router.post("/telemetry")
async def receive_telemetry(data: SensorData):
    # This endpoint is an alternative to MQTT for devices that only support HTTP POST
    db = get_db()
    doc_data = data.model_dump()
    if not doc_data.get("timestamp"):
        doc_data["timestamp"] = datetime.utcnow().isoformat()
        
    db.collection("SensorData").add(doc_data)
    
    # Update device lastSeen
    db.collection("Devices").document(data.deviceId).update({
        "lastSeen": doc_data["timestamp"]
    })
    
    return {"status": "success"}
