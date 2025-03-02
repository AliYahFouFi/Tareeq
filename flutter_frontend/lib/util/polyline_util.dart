// polyline_utils.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/const.dart';
import 'package:flutter_frontend/models/BusRoute_model.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as context;
import 'package:uuid/uuid.dart';

/// Fetches polyline points for a route between two locations using the provided waypoints.
///
/// This function uses the Google Maps API to fetch a list of [LatLng] points representing
/// the polyline for a route from [origin] to [destination] with optional [polylineWaypoints].
///
/// The function constructs a [PolylineRequest] and makes an API call to retrieve the route
/// coordinates. If successful, it returns a list of [LatLng] points representing the polyline.
/// If the API call fails or returns no points, the function returns an empty list.
///
/// Parameters:
/// - [polylineWaypoints]: A list of waypoints to include in the route.
/// - [origin]: The starting point of the route.
/// - [destination]: The ending point of the route.
///
/// Returns:
/// A [Future] that resolves to a list of [LatLng] points representing the polyline
/// for the route.

Future<List<LatLng>> fetchPolylinePoints(
  List<PolylineWayPoint> polylineWaypoints,
  PointLatLng origin,
  PointLatLng destination,
) async {
  final PolylinePoints polylinePoints = PolylinePoints();
  final PolylineRequest polylineRequest = PolylineRequest(
    origin: origin,
    destination: destination,
    mode: TravelMode.driving,
    wayPoints: polylineWaypoints,
  );

  final result = await polylinePoints.getRouteBetweenCoordinates(
    googleApiKey: Api_Key,
    request: polylineRequest,
  );

  if (result.points.isNotEmpty) {
    return result.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  } else {
    return [];
  }
}

//get the stops from the db as a list and convert them to polyline points <polyLineWayPoint>that will be used in_fetchBusRoutePolyline

Future<List<PolylineWayPoint>> getBusRoutePolyline(String routeId) async {
  List<PolylineWayPoint> polylineWaypoints = [];
  try {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/routes/$routeId/stops"),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('stops')) {
        List<dynamic> stops = data['stops'];

        polylineWaypoints =
            stops.map<PolylineWayPoint>((stop) {
              return PolylineWayPoint(
                location: "${stop['latitude']},${stop['longitude']}",
                stopOver: true,
              );
            }).toList();
      }
      return polylineWaypoints;
    } else {
      throw Exception('Failed to fetch bus route data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching route data: $e');
    return polylineWaypoints; // Return empty list on error
  }
}

List<PointLatLng> removeFirstAndLastWaypoints(
  List<PolylineWayPoint> polylineWaypoints,
) {
  List<PointLatLng> originDestination = [];

  if (polylineWaypoints.length >= 2) {
    // Extract first and last waypoints
    PolylineWayPoint originWaypoint = polylineWaypoints.first;
    PolylineWayPoint destinationWaypoint = polylineWaypoints.last;

    // Convert first waypoint to PointLatLng (origin)
    List<String> originParts = originWaypoint.location.split(',');
    double originLat = double.tryParse(originParts[0]) ?? 0.0;
    double originLng = double.tryParse(originParts[1]) ?? 0.0;
    PointLatLng origin = PointLatLng(originLat, originLng);

    // Convert last waypoint to PointLatLng (destination)
    List<String> destParts = destinationWaypoint.location.split(',');
    double destLat = double.tryParse(destParts[0]) ?? 0.0;
    double destLng = double.tryParse(destParts[1]) ?? 0.0;
    PointLatLng destination = PointLatLng(destLat, destLng);

    // Remove first and last from the original list
    polylineWaypoints.removeAt(0);
    polylineWaypoints.removeLast();

    originDestination.add(origin);
    originDestination.add(destination);

    print('Origin: $origin, Destination: $destination');
    print('Updated Waypoints: $polylineWaypoints');
  } else {
    print('Need at least 2 waypoints');
  }

  return originDestination;
}

/// Fetches all bus routes from the API and returns a list of [BusRoute] objects.
///
/// This function makes a GET request to the API and returns the list of bus
/// routes in the response body. If the response status code is not 200 (OK),
/// it throws an exception.

Future<List<BusRoute>> fetchAllBusRoutes() async {
  final url = Uri.parse('http://10.0.2.2:8000/api/bus-route');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    try {
      final List<dynamic> jsonData = jsonDecode(response.body);
      print('fetchAllBusRoutes is working');
      return jsonData.map((route) => BusRoute.fromJson(route)).toList();
    } catch (e) {
      throw Exception('Error parsing JSON: $e');
    }
  } else {
    throw Exception('Failed to load bus routes from API');
  }
}

Map<BusRoute, List<PolylineWayPoint>> routeWaypoints = {};

/// Converts all bus routes into a map of [BusRoute] to a list of [PolylineWayPoint].
///
/// This asynchronous function fetches all bus routes using [fetchAllBusRoutes].
/// It iterates over each route and its stops to construct a list of [PolylineWayPoint]
/// for that route. Each stop's latitude and longitude are used to create a [PolylineWayPoint].
/// The resulting map associates each [BusRoute] with its corresponding list of waypoints.
///
/// Returns:
/// A [Future] that resolves to a [Map] where each key is a [BusRoute] and the value
/// is a list of [PolylineWayPoint] representing the stops along that route.

Future<Map<BusRoute, List<PolylineWayPoint>>>
busRouteToPolylineWaypoints() async {
  List<BusRoute> routes = await fetchAllBusRoutes();

  for (var route in routes) {
    List<PolylineWayPoint> waypoints = [];
    for (var stop in route.stops) {
      String latitude = stop.latitude;
      String longitude = stop.longitude;
      waypoints.add(
        PolylineWayPoint(location: "$latitude,$longitude", stopOver: true),
      );
    }
    routeWaypoints[route] = waypoints;
  }
  return routeWaypoints;
  // BusRoute('Route 1'): [
  //PolylineWayPoint(location: '37.7749,-122.4194', stopOver: true),
  //PolylineWayPoint(location: '37.7859,-122.4364', stopOver: true),
  //PolylineWayPoint(location: '37.7963,-122.4574', stopOver: true)
  //],
}

Future<void> generatePolyLineFromPoints(
  List<LatLng> pointCoordinates,
  Map<PolylineId, Polyline> polylines,
  Function(Map<PolylineId, Polyline>) updatePolylines,
) async {
  final PolylineId id = PolylineId(Uuid().v4()); // Generate a unique ID

  final Random random = Random();
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.deepOrange,
    // Add more colors as needed
  ];
  final Color randomColor = colors[random.nextInt(colors.length)];

  final Polyline polyline = Polyline(
    polylineId: id,
    points: pointCoordinates,
    width: 5,
    color: randomColor,
  );
  polylines[id] = polyline; // Update the polylines map

  updatePolylines(polylines); // Call function to update state in the main file
}

///polyline direction api for marker

List<LatLng> decodePolyline(String encoded) {
  List<LatLng> polylineCoordinates = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int shift = 0, result = 0;
    int b;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return polylineCoordinates;
}
