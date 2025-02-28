import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/NavBar.dart';
import 'package:flutter_frontend/const.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/models/BusRoute_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_frontend/util/polyline_util.dart';
import 'package:flutter_frontend/util/location_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

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
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initializeMap());
    // WidgetsBinding.instance.addPostFrameCallback((_) => initializePolylines());
  }

  Future<void> initializeMap() async {
    // Fetch stops when the screen loads
    _fetchBusStops();
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
    final routeWaypoints = await busRouteToPolylineWaypoints();
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
      _generatePolyLineFromPoints(coordinates);
    }
  }

  // Fetch bus stops from Laravel API
  Future<void> _fetchBusStops() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/bus-stop"),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _busStops = data.map((stop) => BusStop.fromJson(stop)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Convert bus stops to Google Map markers
  Set<Marker> _getBusStopMarkers() {
    return _busStops.map((stop) {
      return Marker(
        markerId: MarkerId(stop.id.toString()),
        position: LatLng(stop.latitude, stop.longitude),
        infoWindow: InfoWindow(title: stop.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap:
            () => showBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stop.name,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(stop.address, style: TextStyle(fontSize: 16.0)),
                    ],
                  ),
                );
              },
            ),
      );
    }).toSet();
  }

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
                polylines: Set<Polyline>.of(polylines.values),
                markers: Set<Marker>.from(_getBusStopMarkers())..add(
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
          initializePolylines();
        },
      ),
    );
  }

  Future<void> _generatePolyLineFromPoints(
    List<LatLng> pointCoordinates,
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
    setState(() => polylines[id] = polyline);
    print('Polyline generated successfully');
  }
}
