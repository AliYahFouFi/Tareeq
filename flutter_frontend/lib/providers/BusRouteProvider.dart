import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusRouteProvider extends ChangeNotifier {
  Set<Polyline> polylines = {};

  BusRouteProvider() {}

  void setPolyline(Set<Polyline> newPolylines) async {
    this.polylines = newPolylines;

    notifyListeners();
  }
}
