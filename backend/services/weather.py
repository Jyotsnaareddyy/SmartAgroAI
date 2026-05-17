import requests
import logging
from config.settings import settings

logger = logging.getLogger(__name__)

def get_weather_forecast(lat: float, lon: float):
    """
    Fetches the weather forecast for a given location to determine
    if it will rain soon. Returns the probability of precipitation (pop).
    """
    if not settings.OPENWEATHER_API_KEY:
        logger.warning("OPENWEATHER_API_KEY is not set. Returning default forecast.")
        return {"will_rain": False, "pop": 0.0, "temp": 25.0}

    url = f"https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={settings.OPENWEATHER_API_KEY}&units=metric"
    
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            # Check the next 12 hours (4 segments of 3h)
            upcoming_forecast = data.get("list", [])[:4]
            
            max_pop = max([item.get("pop", 0) for item in upcoming_forecast])
            avg_temp = sum([item["main"]["temp"] for item in upcoming_forecast]) / len(upcoming_forecast)
            
            return {
                "will_rain": max_pop > 0.5, # > 50% chance of rain
                "pop": max_pop,
                "temp": avg_temp
            }
        else:
            logger.error(f"Weather API error: {response.status_code}")
            return {"will_rain": False, "pop": 0.0, "temp": 25.0}
    except Exception as e:
        logger.error(f"Failed to fetch weather: {e}")
        return {"will_rain": False, "pop": 0.0, "temp": 25.0}
