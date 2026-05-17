import 'dart:async';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class AiService {
  final List<String> _cannedResponses = [
    "Based on the recent telemetry, the soil moisture in Alpha Sector is at 45%. You should be good for another 2 days.",
    "I recommend delaying the irrigation scheduled for tomorrow morning. There's a 60% chance of rain in your area.",
    "Your wheat crop is showing optimal growth. Nitrogen levels are perfect. Keep up the current watering schedule.",
    "I noticed the temperature has been above 30°C for the past 3 days. Consider increasing the evening irrigation duration by 10% to compensate for evaporation.",
    "According to my analysis, you can save approximately 200L of water this week by utilizing the upcoming rainfall."
  ];

  Future<String> sendMessage(String message) async {
    // Simulate network delay and "thinking"
    await Future.delayed(const Duration(seconds: 2));
    
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains("water") || lowerMessage.contains("irrigation")) {
      return "Based on your current soil moisture sensors, your fields are sufficiently watered. I'd recommend holding off on irrigation until the moisture level drops below 30%.";
    } else if (lowerMessage.contains("rain") || lowerMessage.contains("weather")) {
      return "The forecast shows a 60% chance of moderate rain tomorrow afternoon. I suggest disabling the automated sprinklers to save water.";
    } else if (lowerMessage.contains("pump")) {
      return "The main water pump is currently functioning normally. Would you like me to turn it on for you?";
    } else if (lowerMessage.contains("health") || lowerMessage.contains("disease")) {
      return "Crop health is looking good! However, monitor the humidity in Beta Sector; sustained high humidity can increase fungal disease risk.";
    }
    
    // Fallback response
    return _cannedResponses[DateTime.now().millisecond % _cannedResponses.length];
  }
}
