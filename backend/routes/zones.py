from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from models.schemas import ZoneCreate, ZoneResponse
from routes.auth import get_current_user
from config.database import get_db
import uuid

router = APIRouter()

@router.post("/{farm_id}/zones", response_model=ZoneResponse, status_code=status.HTTP_201_CREATED)
async def create_zone(farm_id: str, zone: ZoneCreate, user: dict = Depends(get_current_user)):
    db = get_db()
    # Check if farm exists and belongs to user
    farm_doc = db.collection("Farms").document(farm_id).get()
    if not farm_doc.exists or farm_doc.to_dict().get("ownerId") != user["uid"]:
        raise HTTPException(status_code=403, detail="Not authorized or farm not found")
        
    zone_id = str(uuid.uuid4())
    zone_data = zone.model_dump()
    zone_data["zoneId"] = zone_id
    zone_data["farmId"] = farm_id
    
    db.collection("Zones").document(zone_id).set(zone_data)
    return zone_data

@router.get("/{farm_id}/zones", response_model=List[ZoneResponse])
async def get_zones(farm_id: str, user: dict = Depends(get_current_user)):
    db = get_db()
    # Check authorization
    farm_doc = db.collection("Farms").document(farm_id).get()
    if not farm_doc.exists or farm_doc.to_dict().get("ownerId") != user["uid"]:
        raise HTTPException(status_code=403, detail="Not authorized or farm not found")
        
    zones_ref = db.collection("Zones").where("farmId", "==", farm_id).stream()
    zones = [doc.to_dict() for doc in zones_ref]
    return zones
