// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';

class RoutePreviewPage extends StatelessWidget {
  final String routeName;
  final List<BusStop> stops;

  const RoutePreviewPage({required this.routeName, required this.stops});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route: $routeName'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: stops.length,
        itemBuilder: (context, index) {
          final stop = stops[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.location_on,
                      color:
                          index == 0
                              ? Colors.green
                              : index == stops.length - 1
                              ? Colors.red
                              : Colors.teal,
                    ),
                    if (index != stops.length - 1)
                      Container(
                        height: 40,
                        width: 2,
                        color: Colors.teal.withOpacity(0.5),
                      ),
                  ],
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        stop.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(stop.address),
                      trailing: Text(
                        index == 0
                            ? "Start"
                            : index == stops.length - 1
                            ? "End"
                            : "",
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
