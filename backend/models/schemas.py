from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class UserBase(BaseModel):
    uid: str
    email: str
    name: str
    role: str = "farmer" # farmer or admin

class FarmBase(BaseModel):
    name: str
    location: str
    size: float
    
class FarmCreate(FarmBase):
    pass

class FarmResponse(FarmBase):
    farmId: str
    ownerId: str

class ZoneBase(BaseModel):
    name: str
    cropType: str
    moistureThreshold: float
    irrigationMode: str = "manual" # manual, auto, ai

class ZoneCreate(ZoneBase):
    pass

class ZoneResponse(ZoneBase):
    zoneId: str
    farmId: str

class DeviceBase(BaseModel):
    deviceId: str
    status: str = "online"
    battery: float = 100.0
    sensorTypes: List[str] = ["moisture", "temperature", "humidity", "rain", "relay"]

class DeviceCreate(DeviceBase):
    zoneId: str

class DeviceResponse(DeviceBase):
    zoneId: str
    lastSeen: str

class SensorData(BaseModel):
    deviceId: str
    moisture: float
    temperature: float
    humidity: float
    rain: float
    waterLevel: float
    pH: float = 7.0
    npk: dict = {"N": 0, "P": 0, "K": 0}
    timestamp: Optional[str] = None
