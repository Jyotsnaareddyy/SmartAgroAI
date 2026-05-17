import 'dart:math';
import '../models/farm.dart';
import '../models/zone.dart';
import '../models/device.dart';
import '../models/sensor_data.dart';
import 'api_service.dart';

class MockApiService implements ApiService {
  final Random _random = Random();
  final Map<String, bool> _deviceStates = {};

  @override
  Future<List<Farm>> getFarms() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Farm(id: 'f1', name: 'Green Valley Farm', location: 'North District', sizeAcres: 15.5, ownerId: 'user1'),
      Farm(id: 'f2', name: 'Sunny Pastures', location: 'East District', sizeAcres: 8.2, ownerId: 'user1'),
    ];
  }

  @override
  Future<List<Zone>> getZones(String farmId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (farmId == 'f1') {
      return [
        Zone(id: 'z1', farmId: 'f1', name: 'Alpha Sector', cropType: 'Wheat', areaSqMeters: 5000),
        Zone(id: 'z2', farmId: 'f1', name: 'Beta Sector', cropType: 'Corn', areaSqMeters: 3000),
      ];
    }
    return [
      Zone(id: 'z3', farmId: 'f2', name: 'Main Field', cropType: 'Soybeans', areaSqMeters: 4000),
    ];
  }

  @override
  Future<List<Device>> getDevices(String zoneId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Device(id: 'd_${zoneId}_s1', zoneId: zoneId, type: 'sensor', name: 'Main Soil Sensor', status: 'online', lastSeen: DateTime.now().toIso8601String()),
      Device(id: 'd_${zoneId}_r1', zoneId: zoneId, type: 'relay', name: 'Water Pump', status: 'online', lastSeen: DateTime.now().toIso8601String()),
    ];
  }

  @override
  Future<SensorData> getLatestSensorData(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return SensorData(
      deviceId: deviceId,
      soilMoisture: 30.0 + _random.nextDouble() * 40.0, // 30-70%
      temperature: 20.0 + _random.nextDouble() * 15.0, // 20-35 C
      humidity: 40.0 + _random.nextDouble() * 40.0, // 40-80%
      batteryLevel: 50.0 + _random.nextDouble() * 50.0, // 50-100%
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> toggleDevice(String deviceId, bool isOn) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _deviceStates[deviceId] = isOn;
  }
}
