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
void testdiraction() async {
  var data = await getDirections(33.9014, 35.5196, 33.9010, 35.5422);
  print(data); // Parse the JSON response
}
