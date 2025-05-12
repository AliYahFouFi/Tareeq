import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/util/BusStop_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusStopsProvider extends ChangeNotifier {
  List<BusStop> busStops = [];
  BitmapDescriptor busStopIcon = BitmapDescriptor.defaultMarker;

  BusStopsProvider() {
    _initBusStopIcon(); // Load the icon when provider is initialized
  }

  // Load the bus stop icon from assets
  Future<void> _initBusStopIcon() async {
    busStopIcon = await getBusStopIcon();
    notifyListeners(); // Notify UI to refresh markers
  }

  void setBusStops(List<BusStop> busStops) {
    this.busStops = busStops;
    notifyListeners();
  }

  void loadAllBusStops() async {
    busStops = await BusStopService.fetchBusStops();
    notifyListeners();
  }

  List<BusStop> get busStopsProvider => busStops;
  Future<BitmapDescriptor> getBusStopIcon() async {
    // ignore: deprecated_member_use
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(1, 1)),
      'assets/bus_stop.png',
    );
  }
}
