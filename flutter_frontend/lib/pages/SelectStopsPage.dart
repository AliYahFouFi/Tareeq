import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/BusRoute_model.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/util/BusStop_service.dart';

import 'package:flutter_frontend/util/polyline_util.dart';
import 'package:provider/provider.dart'; // Your route fetching logic

class SelectStopsPage extends StatefulWidget {
  @override
  _SelectStopsPageState createState() => _SelectStopsPageState();
}

class _SelectStopsPageState extends State<SelectStopsPage> {
  List<BusRoute> routes = [];
  BusRoute? selectedRoute;
  List<BusStop> routeStops = [];
  BusStop? originStop;
  BusStop? destinationStop;
  List<BusStop> stopsBetween = [];
  String? travelDistance;
  String? travelDuration;

  @override
  void initState() {
    super.initState();
    fetchAllBusRoutes().then((fetchedRoutes) {
      setState(() {
        routes = fetchedRoutes;
      });
    });
  }

  void _onRouteSelected(BusRoute? route) async {
    if (route == null) return;
    List<BusStop> stops = await BusStopService.getBusStopsForOneRoute(
      route.route_id.toString(),
    );

    setState(() {
      selectedRoute = route;
      routeStops = stops;
      originStop = null;
      destinationStop = null;
      stopsBetween = [];
    });
  }

  Future<void> fetchDistanceAndDuration() async {
    if (originStop != null && destinationStop != null) {
      final result = await context
          .read<BusRouteProvider>()
          .GetDistanceAndDuration(
            originStop!.latitude,
            originStop!.longitude,
            destinationStop!.latitude,
            destinationStop!.longitude,
            'driving', // or 'walking', 'transit', etc.
          );

      setState(() {
        travelDistance = result['distance'];
        travelDuration = result['duration'];
      });
    }
  }

  void _updatePreview() {
    if (originStop != null && destinationStop != null) {
      int originIndex = routeStops.indexOf(originStop!);
      int destinationIndex = routeStops.indexOf(destinationStop!);

      if (originIndex != -1 && destinationIndex != -1) {
        int start =
            originIndex < destinationIndex ? originIndex : destinationIndex;
        int end =
            originIndex > destinationIndex ? originIndex : destinationIndex;

        setState(() {
          stopsBetween = routeStops.sublist(start, end + 1);
        });
        fetchDistanceAndDuration(); // Call here
      }
    }
  }

  void _showRouteSnackBar(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Please select a route first!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Route and Stops',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Route dropdown
            DropdownButtonFormField<BusRoute>(
              value: selectedRoute,
              decoration: InputDecoration(
                labelText: 'Select Route',
                border: OutlineInputBorder(),
              ),
              items:
                  routes.map((route) {
                    return DropdownMenuItem<BusRoute>(
                      value: route,
                      child: Text(route.route_name),
                    );
                  }).toList(),
              onChanged: _onRouteSelected,
            ),
            SizedBox(height: 20),

            // Origin
            DropdownButtonFormField<BusStop>(
              value: originStop,
              decoration: InputDecoration(
                labelText: 'Origin Stop',
                border: OutlineInputBorder(),
              ),
              items:
                  selectedRoute == null
                      ? []
                      : routeStops.map((stop) {
                        return DropdownMenuItem<BusStop>(
                          value: stop,
                          child: Text(stop.name),
                        );
                      }).toList(),
              onChanged:
                  selectedRoute == null
                      ? (_) => _showRouteSnackBar(context)
                      : (value) {
                        setState(() {
                          originStop = value;
                        });
                        _updatePreview();
                      },
            ),
            SizedBox(height: 20),

            // Destination
            DropdownButtonFormField<BusStop>(
              value: destinationStop,
              decoration: InputDecoration(
                labelText: 'Destination Stop',
                border: OutlineInputBorder(),
              ),
              items:
                  selectedRoute == null
                      ? []
                      : routeStops.map((stop) {
                        return DropdownMenuItem<BusStop>(
                          value: stop,
                          child: Text(stop.name),
                        );
                      }).toList(),
              onChanged:
                  selectedRoute == null
                      ? (_) => _showRouteSnackBar(context)
                      : (value) {
                        setState(() {
                          destinationStop = value;
                        });
                        _updatePreview();
                      },
            ),
            SizedBox(height: 30),

            // Fancy preview
            if (stopsBetween.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.teal),
                      SizedBox(width: 8),
                      Text(
                        "Estimated Time: ",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        travelDuration ?? "-- mins",
                        style: TextStyle(color: Colors.teal.shade700),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.directions, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        "Distance: ",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        travelDistance ?? "--",
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),
                  Text(
                    'Route Preview (${stopsBetween.length} stops):',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: stopsBetween.length,
                    itemBuilder: (context, index) {
                      final stop = stopsBetween[index];

                      final isFirst = index == 0;
                      final isLast = index == stopsBetween.length - 1;

                      Icon leadingIcon;
                      TextStyle textStyle = TextStyle(fontSize: 16);

                      if (isFirst) {
                        leadingIcon = Icon(Icons.flag, color: Colors.green);
                        textStyle = textStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        );
                      } else if (isLast) {
                        leadingIcon = Icon(Icons.flag, color: Colors.red);
                        textStyle = textStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        );
                      } else {
                        leadingIcon = Icon(
                          Icons.circle,
                          size: 15,
                          color: Colors.grey,
                        );
                      }

                      return ListTile(
                        leading: leadingIcon,
                        title: Text(stop.name, style: textStyle),
                        subtitle: Text(stop.address),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
