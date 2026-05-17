class SensorData {
  final String deviceId;
  final double? soilMoisture;
  final double? temperature;
  final double? humidity;
  final double? lightLevel;
  final double? batteryLevel;
  final String timestamp;

  SensorData({
    required this.deviceId,
    this.soilMoisture,
    this.temperature,
    this.humidity,
    this.lightLevel,
    this.batteryLevel,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      deviceId: json['deviceId'] ?? '',
      soilMoisture: json['soilMoisture'] != null ? (json['soilMoisture'] as num).toDouble() : null,
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
      humidity: json['humidity'] != null ? (json['humidity'] as num).toDouble() : null,
      lightLevel: json['lightLevel'] != null ? (json['lightLevel'] as num).toDouble() : null,
      batteryLevel: json['batteryLevel'] != null ? (json['batteryLevel'] as num).toDouble() : null,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      if (soilMoisture != null) 'soilMoisture': soilMoisture,
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (lightLevel != null) 'lightLevel': lightLevel,
      if (batteryLevel != null) 'batteryLevel': batteryLevel,
      'timestamp': timestamp,
    };
  }
}
