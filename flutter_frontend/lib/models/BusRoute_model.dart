class BusRoute {
  int route_id;
  String route_name;
  List<Stop> stops;

  BusRoute({
    required this.route_id,
    required this.route_name,
    required this.stops,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      route_id: json['route_id'],
      route_name: json['route_name'],
      stops: json['stops'].map<Stop>((stop) => Stop.fromJson(stop)).toList(),
    );
  }
}

class Stop {
  int id;
  String name;
  String latitude;
  String longitude;
  int order;

  Stop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      order: json['order'],
    );
  }
}
