class SavedPlace {
  final String id;
  final String name;
  final double lat;
  final double lng;

  SavedPlace({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['id'],
      name: json['name'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'lat': lat, 'lng': lng};
  }
}
