import 'package:http/http.dart' as http;
import 'dart:convert';
import '../const.dart';

Future<Map<String, dynamic>> getDirections(
  double StartLat,
  double StartLon,
  double EndLat,
  double EndLon,
) async {
  String url =
      "https://maps.googleapis.com/maps/api/directions/json?origin=$StartLat,$StartLon&destination=$EndLat,$EndLon&mode=driving&key=$Api_Key";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to get directions");
  }
}

// Example usage:
/// Fetches and prints the distance and duration for a route between two locations.
///
/// This function utilizes the `getDirections` function to make an API call to
/// the Google Maps Directions API. It retrieves the JSON response containing
/// route information and extracts the distance and duration for the specified
/// route. The extracted distance and duration are then printed to the console.
///
/// Parameters:
/// - [StartLat]: The latitude of the starting location.
/// - [StartLon]: The longitude of the starting location.
/// - [EndLat]: The latitude of the ending location.
/// - [EndLon]: The longitude of the ending location.

void GetDistanceAndDuration(
  double StartLat,
  double StartLon,
  double EndLat,
  double EndLon,
) async {
  var data = await getDirections(StartLat, StartLon, EndLat, EndLon);
  print(data); // Parse the JSON response

  // Extract distance and duration
  var distance = data['routes'][0]['legs'][0]['distance']['text'];
  var duration = data['routes'][0]['legs'][0]['duration']['text'];

  print('Distance: $distance');
  print('Duration: $duration');

  print('tTHIS FUNCTION IS WORKING');
}
