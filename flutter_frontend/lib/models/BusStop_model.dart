class BusStop {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String routeName;

  BusStop({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.routeName,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'] ?? 0, // Default to 0 if null
      name: json['name'] ?? 'Unknown', // Default to 'Unknown' if null
      address: json['address'] ?? 'Unknown',
      latitude:
          json['latitude'] != null
              ? double.tryParse(json['latitude'].toString()) ?? 0.0
              : 0.0,
      longitude:
          json['longitude'] != null
              ? double.tryParse(json['longitude'].toString()) ?? 0.0
              : 0.0,
      routeName: json['route'] ?? 'Unknown',
    );
  }
}
