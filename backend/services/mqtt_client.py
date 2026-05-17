import paho.mqtt.client as mqtt
import json
import logging
from datetime import datetime
from config.settings import settings
from config.database import get_db

logger = logging.getLogger(__name__)

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        logger.info(f"Connected to MQTT Broker: {settings.MQTT_BROKER}")
        # Subscribe to all farm telemetry topics
        client.subscribe("smartagro/telemetry/#")
    else:
        logger.error(f"Failed to connect to MQTT broker, return code {rc}")

def on_message(client, userdata, msg):
    try:
        topic = msg.topic
        payload = msg.payload.decode()
        logger.info(f"Received MQTT message on {topic}: {payload}")
        
        # Topic format: smartagro/telemetry/{deviceId}
        parts = topic.split("/")
        if len(parts) >= 3 and parts[1] == "telemetry":
            device_id = parts[2]
            data = json.loads(payload)
            
            db = get_db()
            timestamp = datetime.utcnow().isoformat()
            data["deviceId"] = device_id
            data["timestamp"] = timestamp
            
            # Save telemetry
            db.collection("SensorData").add(data)
            
            # Update device last seen
            db.collection("Devices").document(device_id).set({
                "lastSeen": timestamp,
                "battery": data.get("battery", 100),
                "status": "online"
            }, merge=True)
            
    except Exception as e:
        logger.error(f"Error processing MQTT message: {e}")

def start_mqtt_client():
    client = mqtt.Client()
    
    if settings.MQTT_USERNAME:
        client.username_pw_set(settings.MQTT_USERNAME, settings.MQTT_PASSWORD)
        
    client.on_connect = on_connect
    client.on_message = on_message
    
    try:
        client.connect(settings.MQTT_BROKER, settings.MQTT_PORT, 60)
        client.loop_start() # Run in background thread
    except Exception as e:
        logger.error(f"Could not connect to MQTT broker: {e}")
