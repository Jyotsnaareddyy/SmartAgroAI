from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from models.schemas import FarmCreate, FarmResponse
from routes.auth import get_current_user
from config.database import get_db
import uuid

router = APIRouter()

@router.post("/", response_model=FarmResponse, status_code=status.HTTP_201_CREATED)
async def create_farm(farm: FarmCreate, user: dict = Depends(get_current_user)):
    db = get_db()
    farm_id = str(uuid.uuid4())
    farm_data = farm.model_dump()
    farm_data["farmId"] = farm_id
    farm_data["ownerId"] = user["uid"]
    
    db.collection("Farms").document(farm_id).set(farm_data)
    return farm_data

@router.get("/", response_model=List[FarmResponse])
async def get_farms(user: dict = Depends(get_current_user)):
    db = get_db()
    farms_ref = db.collection("Farms").where("ownerId", "==", user["uid"]).stream()
    farms = [doc.to_dict() for doc in farms_ref]
    return farms

@router.get("/{farm_id}", response_model=FarmResponse)
async def get_farm(farm_id: str, user: dict = Depends(get_current_user)):
    db = get_db()
    doc = db.collection("Farms").document(farm_id).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Farm not found")
    data = doc.to_dict()
    if data["ownerId"] != user["uid"]:
        raise HTTPException(status_code=403, detail="Not authorized to view this farm")
    return data
