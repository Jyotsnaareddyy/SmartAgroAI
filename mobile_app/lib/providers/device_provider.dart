import 'dart:async';
import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';

class DeviceProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Device> _devices = [];
  SensorData? _latestData;
  bool _isLoading = false;
  Timer? _pollingTimer;
  String? _currentZoneId;

  DeviceProvider(this._apiService);

  List<Device> get devices => _devices;
  SensorData? get latestData => _latestData;
  bool get isLoading => _isLoading;

  bool isPumpOn(String pumpId) {
    // In a real app we'd check device status or local state
    // For this prototype, let's derive it from a local map or the device list
    try {
      final device = _devices.firstWhere((d) => d.id == pumpId);
      return device.status == 'on';
    } catch (e) {
      return false;
    }
  }

  Future<void> loadDevices(String zoneId) async {
    _currentZoneId = zoneId;
    _isLoading = true;
    notifyListeners();

    try {
      _devices = await _apiService.getDevices(zoneId);
      await fetchLatestData();
      _startPolling();
    } catch (e) {
      debugPrint('Error loading devices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatestData() async {
    try {
      // Find a sensor device to poll
      final sensor = _devices.firstWhere(
        (d) => d.type == 'sensor',
        orElse: () => Device(id: '', zoneId: '', type: '', name: '', status: '', lastSeen: ''),
      );

      if (sensor.id.isNotEmpty) {
        _latestData = await _apiService.getLatestSensorData(sensor.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching sensor data: $e');
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchLatestData();
    });
  }

  Future<void> togglePump(String pumpId, bool isOn) async {
    try {
      await _apiService.toggleDevice(pumpId, isOn);
      
      // Optimistic update
      final index = _devices.indexWhere((d) => d.id == pumpId);
      if (index != -1) {
        final device = _devices[index];
        _devices[index] = Device(
          id: device.id,
          zoneId: device.zoneId,
          type: device.type,
          name: device.name,
          status: isOn ? 'on' : 'off',
          lastSeen: device.lastSeen
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling pump: $e');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
