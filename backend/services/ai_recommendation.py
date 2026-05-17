from services.weather import get_weather_forecast
# In a real scenario, we'd load a trained model:
# import joblib
# model = joblib.load('models/water_prediction_model.pkl')

def predict_water_requirement(crop_type: str, current_moisture: float, ideal_moisture: float, temp: float, humidity: float):
    """
    Simulates an ML model prediction for required water in liters.
    """
    if current_moisture >= ideal_moisture:
        return 0.0
    
    # Simple rule-based calculation to simulate model
    moisture_deficit = ideal_moisture - current_moisture
    base_water = moisture_deficit * 2.5 # multiplier based on area/soil type
    
    # Adjust for temperature and humidity
    temp_factor = max(1.0, temp / 25.0)
    humidity_factor = max(0.5, (100.0 - humidity) / 50.0)
    
    predicted_water = base_water * temp_factor * humidity_factor
    return round(predicted_water, 2)

def generate_irrigation_recommendation(farm_lat: float, farm_lon: float, zone_data: dict, current_telemetry: dict):
    weather = get_weather_forecast(farm_lat, farm_lon)
    
    if weather["will_rain"]:
        return {
            "action": "SKIP",
            "reason": f"High probability of rain ({int(weather['pop']*100)}%) in the next 12 hours.",
            "water_required_liters": 0.0
        }
        
    water_req = predict_water_requirement(
        crop_type=zone_data.get("cropType", "Generic"),
        current_moisture=current_telemetry.get("moisture", 50.0),
        ideal_moisture=zone_data.get("moistureThreshold", 60.0),
        temp=current_telemetry.get("temperature", weather["temp"]),
        humidity=current_telemetry.get("humidity", 50.0)
    )
    
    if water_req > 0:
        return {
            "action": "IRRIGATE",
            "reason": "Soil moisture is below threshold and no rain is forecasted.",
            "water_required_liters": water_req
        }
    else:
        return {
            "action": "STANDBY",
            "reason": "Soil moisture is optimal.",
            "water_required_liters": 0.0
        }
