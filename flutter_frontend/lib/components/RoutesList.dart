import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/BusRoute_model.dart';
import 'package:flutter_frontend/util/polyline_util.dart';

Future<List<Map<String, dynamic>>> getBusRoutesWithFirstAndLastStop() async {
  List<BusRoute> busRoutes = await fetchAllBusRoutes();

  return busRoutes.map((route) {
    List<Stop> stops = route.stops;
    return {
      "route_id": route.route_id,
      "route_name": route.route_name,
      "first_stop": stops.isNotEmpty ? stops.first.name : "Unknown",
      "last_stop": stops.length > 1 ? stops.last.name : stops.first.name,
    };
  }).toList();
}

void showBusRoutesBottomSheet(BuildContext context) async {
  List<Map<String, dynamic>> busRoutes =
      await getBusRoutesWithFirstAndLastStop();

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 179, 20, 20),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(16),
        height: 400, // Adjust based on content
        child: Column(
          children: [
            Text(
              "Available Bus Routes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: busRoutes.length,
                itemBuilder: (context, index) {
                  var route = busRoutes[index];
                  return GestureDetector(
                    onTap: () async {
                      print(
                        "THIS FUNCTION IS BUS DETAILS WORKING SOOIHUJIASFGHUASDF",
                      );
                    },
                    child: Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          route['route_name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "From: ${route['first_stop']} → To: ${route['last_stop']}",
                        ),
                        leading: Icon(Icons.directions_bus, color: Colors.blue),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
