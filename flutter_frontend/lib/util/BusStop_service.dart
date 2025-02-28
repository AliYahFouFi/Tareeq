import 'dart:convert';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:http/http.dart' as http;

class BusStopService {
  static Future<List<BusStop>> fetchBusStops() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/bus-stop"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((stop) => BusStop.fromJson(stop)).toList();
      } else {
        throw Exception('Failed to load bus stops');
      }
    } catch (e) {
      throw Exception('Error fetching bus stops: $e');
    }
  }

  //a function that takes a route and returns a list of bus stops
  static Future<List<BusStop>> getBusStopsForOneRoute(String routeId) async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/routes/$routeId/stops"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((stop) => BusStop.fromJson(stop)).toList();
      } else {
        throw Exception('Failed to load bus stops');
      }
    } catch (e) {
      throw Exception('Error fetching bus stops: $e');
    }
  }
}
