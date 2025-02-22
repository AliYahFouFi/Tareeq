class BusStop {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  BusStop({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: double.parse(
        json['latitude'].toString(),
      ), // Convert string to double
      longitude: double.parse(json['longitude'].toString()),
    );
  }
}
