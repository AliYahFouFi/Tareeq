import 'package:flutter/material.dart';
import 'package:flutter_frontend/util/diractions_service.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusRouteProvider extends ChangeNotifier {
  Set<Polyline> polylines = {};

  BusRouteProvider() {}

  void setPolyline(Set<Polyline> newPolylines) async {
    this.polylines = newPolylines;

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
