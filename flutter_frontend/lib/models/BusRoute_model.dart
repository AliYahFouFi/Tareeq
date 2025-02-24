import 'package:flutter_frontend/models/BusStop_model.dart';

class BusRoute {
  final int routeId;
  final String routeName;
  final List<BusStop> stops;

  BusRoute({
    required this.routeId,
    required this.routeName,
    required this.stops,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      routeId: json['route_id'] as int,
      routeName: json['route_name'] as String,
      stops:
          (json['stops'] as List)
              .map((stopJson) => BusStop.fromJson(stopJson))
              .toList(),
    );
  }
}
