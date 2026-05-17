import 'package:flutter/material.dart';
import '../models/farm.dart';
import '../models/zone.dart';
import '../services/api_service.dart';

class FarmProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Farm> _farms = [];
  Map<String, List<Zone>> _zonesByFarm = {};
  bool _isLoading = false;

  FarmProvider(this._apiService);

  List<Farm> get farms => _farms;
  bool get isLoading => _isLoading;

  List<Zone> getZonesForFarm(String farmId) {
    return _zonesByFarm[farmId] ?? [];
  }

  Future<void> loadFarms() async {
    _isLoading = true;
    notifyListeners();

    try {
      _farms = await _apiService.getFarms();
      for (var farm in _farms) {
        _zonesByFarm[farm.id] = await _apiService.getZones(farm.id);
      }
    } catch (e) {
      debugPrint('Error loading farms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addFarm(String name, String location, double size) {
    final newFarm = Farm(
      id: 'f_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      location: location,
      sizeAcres: size,
      ownerId: 'current_user',
    );
    _farms.add(newFarm);
    _zonesByFarm[newFarm.id] = []; // Start with empty zones
    notifyListeners();
  }
}
