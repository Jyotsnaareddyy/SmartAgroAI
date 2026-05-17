class Zone {
  final String id;
  final String farmId;
  final String name;
  final String cropType;
  final double areaSqMeters;

  Zone({
    required this.id,
    required this.farmId,
    required this.name,
    required this.cropType,
    required this.areaSqMeters,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['zoneId'] ?? '',
      farmId: json['farmId'] ?? '',
      name: json['name'] ?? '',
      cropType: json['cropType'] ?? '',
      areaSqMeters: (json['areaSqMeters'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zoneId': id,
      'farmId': farmId,
      'name': name,
      'cropType': cropType,
      'areaSqMeters': areaSqMeters,
    };
  }
}
