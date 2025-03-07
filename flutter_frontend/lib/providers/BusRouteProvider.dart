import 'package:flutter/material.dart';
import 'package:flutter_frontend/util/diractions_service.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusRouteProvider extends ChangeNotifier {
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  String distance = '';
  String duration = '';
  BusRouteProvider() {}

  void setPolyline(Set<Polyline> newPolylines) async {
    this.polylines = newPolylines;

    notifyListeners();
  }

  Future<void> GetDistanceAndDuration(
    double StartLat,
    double StartLon,
    double EndLat,
    double EndLon,
    String mode,
  ) async {
    var data = await getDirections(StartLat, StartLon, EndLat, EndLon, mode);

    this.distance = data['routes'][0]['legs'][0]['distance']['text'];
    this.duration = data['routes'][0]['legs'][0]['duration']['text'];
    notifyListeners();
  }

  Future<void> updateRoute(LatLng currentPosition, LatLng destination) async {
    Set<Polyline> newRoute = await drawRoute(
      endLat: destination.latitude,
      endLon: destination.longitude,
      currentPosition: currentPosition,
    );
    setPolyline(newRoute);
  }
}
