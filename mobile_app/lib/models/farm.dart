class Farm {
  final String id;
  final String name;
  final String location;
  final double sizeAcres;
  final String ownerId;

  Farm({
    required this.id,
    required this.name,
    required this.location,
    required this.sizeAcres,
    required this.ownerId,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['farmId'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      sizeAcres: (json['sizeAcres'] ?? 0).toDouble(),
      ownerId: json['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmId': id,
      'name': name,
      'location': location,
      'sizeAcres': sizeAcres,
      'ownerId': ownerId,
    };
  }
}
