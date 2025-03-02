import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/util/BusStop_service.dart';

class BusStopsProvider extends ChangeNotifier {
  List<BusStop> busStops = [];

  BusStopsProvider() {
    busStops = [];
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
}
