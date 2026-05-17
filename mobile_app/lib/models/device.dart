class Device {
  final String id;
  final String zoneId;
  final String type;
  final String name;
  final String status;
  final String lastSeen;

  Device({
    required this.id,
    required this.zoneId,
    required this.type,
    required this.name,
    required this.status,
    required this.lastSeen,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['deviceId'] ?? '',
      zoneId: json['zoneId'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'offline',
      lastSeen: json['lastSeen'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': id,
      'zoneId': zoneId,
      'type': type,
      'name': name,
      'status': status,
      'lastSeen': lastSeen,
    };
  }
}
