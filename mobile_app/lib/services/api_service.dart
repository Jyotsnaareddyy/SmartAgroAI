import '../models/farm.dart';
import '../models/zone.dart';
import '../models/device.dart';
import '../models/sensor_data.dart';

abstract class ApiService {
  Future<List<Farm>> getFarms();
  Future<List<Zone>> getZones(String farmId);
  Future<List<Device>> getDevices(String zoneId);
  Future<SensorData> getLatestSensorData(String deviceId);
  Future<void> toggleDevice(String deviceId, bool isOn);
}
