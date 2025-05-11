import 'package:flutter/material.dart';
import 'package:flutter_frontend/util/diractions_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class BusRouteProvider extends ChangeNotifier {
  Set<Polyline> polylines = {};
  String distance = '';
  String duration = '';
  LatLng? _lastUpdatedPosition;
  // Define a field to store listener
  VoidCallback? updateRouteListener;

  BusRouteProvider();

  void setPolyline(Set<Polyline> newPolylines) {
    polylines = newPolylines;
    notifyListeners();
  }

  Future<Map<String, String>> GetDistanceAndDuration(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
    String mode,
  ) async {
    var data = await getDirections(startLat, startLon, endLat, endLon, mode);
    this.distance = data['routes'][0]['legs'][0]['distance']['text'];
    this.duration = data['routes'][0]['legs'][0]['duration']['text'];
    String distance = data['routes'][0]['legs'][0]['distance']['text'];
    String duration = data['routes'][0]['legs'][0]['duration']['text'];

    notifyListeners();
    return {'distance': distance, 'duration': duration};
  }

  Future<void> updateRoute(LatLng currentPosition, LatLng destination) async {
    // Update only if moved more than 20 meters
    if (_lastUpdatedPosition == null ||
        calculateDistance(_lastUpdatedPosition!, currentPosition) > 20) {
      _lastUpdatedPosition = currentPosition;

      // Update the polyline
      Set<Polyline> newRoute = await drawRoute(
        endLat: destination.latitude,
        endLon: destination.longitude,
        currentPosition: currentPosition,
      );
      setPolyline(newRoute);

      // Update distance & duration
      await GetDistanceAndDuration(
        currentPosition.latitude,
        currentPosition.longitude,
        destination.latitude,
        destination.longitude,
        "walking",
      );
    }
  }

  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // in meters
    double dLat = (end.latitude - start.latitude) * (pi / 180);
    double dLon = (end.longitude - start.longitude) * (pi / 180);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(start.latitude * (pi / 180)) *
            cos(end.latitude * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}
