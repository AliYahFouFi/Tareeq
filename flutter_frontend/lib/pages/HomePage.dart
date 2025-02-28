import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/NavBar.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/models/BusRoute_model.dart';
import 'package:flutter_frontend/util/diractions_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_frontend/util/polyline_util.dart';
import 'package:flutter_frontend/util/location_service.dart';
import 'package:flutter_frontend/util/BusStop_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Initial camera position centered on Beirut
  static const LatLng _beirutLocation = LatLng(33.8938, 35.5018);
  late GoogleMapController _mapController;
  List<BusStop> _busStops = [];

  // Two sets of polylines
  Map<PolylineId, Polyline> polylines = {};
  Set<Polyline> polylinesDD = {};

  // A flag to toggle between the sets
  bool showAllPolylines = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initializeMap());
    // WidgetsBinding.instance.addPostFrameCallback((_) => initializePolylines());
  }

  Future<void> initializeMap() async {
    // Fetch stops when the screen loads
    _loadBusStops();
    getUserLiveLocation();
    //for getting the live location of the user [NEEDS TO BE CHANGED [IDK A BETTER WAY FOR THIS RIGHT NOW]]
    LocationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
      }
    });
  }

  //TO initialize polylines and display all the routes fetched form the db
  Future<void> initializePolylines() async {
    routeWaypoints = await busRouteToPolylineWaypoints();
    for (var entry in routeWaypoints.entries) {
      BusRoute route = entry.key;
      List<PolylineWayPoint> waypoints = entry.value;
      List<PointLatLng> originDestination = removeFirstAndLastWaypoints(
        waypoints,
      );
      final coordinates = await fetchPolylinePoints(
        waypoints,
        originDestination[0],
        originDestination[1],
      );
      // polylines.clear();
      generatePolyLineFromPoints(coordinates, polylines, updateAllPolylines);
    }
  }

  // Convert bus stops to Google Map markers
  Set<Marker> getBusStopMarkers() {
    return _busStops.map((stop) {
      return Marker(
        markerId: MarkerId(stop.id.toString()),
        position: LatLng(stop.latitude, stop.longitude),
        infoWindow: InfoWindow(title: stop.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              String? _distance = '';
              String? _duration = '';

              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 250,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Text(stop.name, style: TextStyle(fontSize: 24)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Latitude: ${stop.latitude}'),
                                SizedBox(width: 20),
                                Text('Longitude: ${stop.longitude}'),
                              ],
                            ),
                          ),

                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Get Distance and Duration',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            onTap: () async {
                              var data = await GetDistanceAndDuration(
                                currentPosition!.latitude,
                                currentPosition!.longitude,
                                stop.latitude,
                                stop.longitude,
                                'walking',
                              );
                              setState(() {
                                _distance = data["distance"];
                                _duration = data['duration'];
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Distance: $_distance'),
                                SizedBox(width: 20),
                                Text('Duration: $_duration'),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showAllPolylines = false;
                              drawRoute(
                                endLat: stop.latitude,
                                endLon: stop.longitude,
                                currentPosition: currentPosition!,
                                updatePolylines: updatePolylines,
                              );
                            },

                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Draw Route',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Tareeq', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body:
          currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _beirutLocation,
                  zoom: 12.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
                polylines:
                    showAllPolylines
                        ? Set<Polyline>.of(polylines.values)
                        : polylinesDD, // Switch based on flag
                markers: Set<Marker>.from(getBusStopMarkers())..add(
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    position: currentPosition!,
                    icon: BitmapDescriptor.defaultMarker,
                  ),
                ),
              ),
      bottomNavigationBar: NavBar(),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.location_searching),
        onPressed: () {
          showAllPolylines = true;
          initializePolylines();
        },
      ),
    );
  }

  //this 3 functions are helpers to set the sate so we can use them in the main file
  void updatePolylines(Set<Polyline> newPolylines) {
    setState(() {
      polylinesDD = newPolylines;
    });
  }

  void updateAllPolylines(Map<PolylineId, Polyline> newPolylines) {
    setState(() {
      polylines = newPolylines;
    });
  }

  void _loadBusStops() async {
    try {
      List<BusStop> stops = await BusStopService.fetchBusStops();
      setState(() {
        _busStops = stops;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void loadBusStop(String routeId) async {
    try {
      List<BusStop> stops = await BusStopService.getBusStopsForOneRoute(
        routeId,
      );
      setState(() {
        _busStops = stops;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
