import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'polyline_util.dart';
import '../const.dart';

// makes a GET request to the Google Maps Directions API to retrieve directions between two geographical points. It takes the start and end coordinates,
// as well as the mode of transportation (e.g., driving, walking, etc.), and returns a JSON response as a Map<String, dynamic>. If the request fails, it throws an exception
Future<Map<String, dynamic>> getDirections(
  double StartLat,
  double StartLon,
  double EndLat,
  double EndLon,
  String mode,
) async {
  String url =
      "https://maps.googleapis.com/maps/api/directions/json?origin=$StartLat,$StartLon&destination=$EndLat,$EndLon&mode=$mode&key=$Api_Key";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to get directions");
  }
}

/// Fetches the distance and duration between two geographical points.
///
/// This function uses the Google Maps Directions API to calculate the
/// driving distance and estimated travel duration between the starting
/// point ([StartLat], [StartLon]) and the ending point ([EndLat], [EndLon]).
///
/// Parameters:
/// - [StartLat]: The latitude of the starting location.
/// - [StartLon]: The longitude of the starting location.
/// - [EndLat]: The latitude of the destination location.
/// - [EndLon]: The longitude of the destination location.
///
/// Returns:
/// A [Future] that resolves to a [Map] containing the 'distance' and 'duration'
/// as strings. The 'distance' is the total driving distance between the two
/// points, and the 'duration' is the estimated travel time.

Future<Map<String, String>> GetDistanceAndDuration(
  double StartLat,
  double StartLon,
  double EndLat,
  double EndLon,
  String mode,
) async {
  var data = await getDirections(StartLat, StartLon, EndLat, EndLon, mode);

  var distance = data['routes'][0]['legs'][0]['distance']['text'];
  var duration = data['routes'][0]['legs'][0]['duration']['text'];

  return {'distance': distance, 'duration': duration};
}

Future<List<LatLng>> getRouteCoordinates(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
) async {
  final String apiKey = Api_Key;
  final String url =
      "https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$endLat,$endLng&mode=walking&alternatives=true&key=$apiKey";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if ((data['routes'] as List).isNotEmpty) {
      final polylinePoints = data['routes'][0]['overview_polyline']['points'];
      print(
        'GET ROUTES CORRDINATES IS WORKING _________________________________',
      );
      return decodePolyline(polylinePoints);
    }
  }
  throw Exception('Failed to load directions');
}

Future<Set<Polyline>> drawRoute({
  required double endLat,
  required double endLon,
  required LatLng currentPosition,
}) async {
  List<LatLng> routePoints = await getRouteCoordinates(
    currentPosition.latitude,
    currentPosition.longitude,
    endLat,
    endLon,
  );

  return {
    Polyline(
      polylineId: const PolylineId('route'),
      points: routePoints,
      width: 5,
      // ignore: deprecated_member_use
      color: Colors.blue.withOpacity(0.7), // Add transparency
      patterns: [PatternItem.dash(15), PatternItem.gap(10)],
      onTap: () => print('Route tapped'),
    ),
  };
}
