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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Initial camera position centered on Beirut
  static const LatLng _beirutLocation = LatLng(33.8938, 35.5018);
  late GoogleMapController _mapController;
  Location _Location = new Location();
  List<BusStop> _busStops = [];
  Map<PolylineId, Polyline> polylines = {};

  LatLng? currentPosition = null;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initializeMap());

    _fetchBusStops(); // Fetch stops when the screen loads
  }

  Future<void> initializeMap() async {
    _getUserLiveLocation();

    final polylineWaypoints = await _getBusRoutePolyline('1');
    List<PointLatLng> originDestination = removeFirstAndLastWaypoints(
      polylineWaypoints,
    );

    final coordinates = await _fetchPolylinePoints(
      polylineWaypoints,
      originDestination[0],
      originDestination[1],
    );
    _generatePolyLineFromPoints(coordinates);
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
        onTap: () => (),
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
          _getUserLocation();
        },
      ),
    );
  }

  /// This function checks if the location service is enabled and requests
  /// the user to enable it if it is not. It also requests the user's
  /// permission to access their location if not already granted.
  /// Once the service is enabled and permission is granted, it fetches
  /// the user's current location data.
  /// If the service is not enabled or permission is not granted, the
  /// function returns early without fetching the location data.

  Future<void> _getUserLiveLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if the location service is enabled
    _serviceEnabled = await _Location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _Location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    //Check if the user has granted permission
    _permissionGranted = await _Location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _Location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    //for getting the live location of the user
    _Location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
      }
      print(currentPosition);
    });
  }

  _getUserLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    // Check if the location service is enabled
    _serviceEnabled = await _Location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _Location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    //Check if the user has granted permission
    _permissionGranted = await _Location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _Location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await _Location.getLocation();
    //go to the user's location
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_locationData.latitude!, _locationData.longitude!),
          zoom: 16.0,
        ),
      ),
    );
  }

  //get the stops from the db as a list and convert them to polyline points <polyLineWayPoint>that will be used in_fetchBusRoutePolyline

  Future<List<PolylineWayPoint>> _getBusRoutePolyline(String routeId) async {
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
        throw Exception(
          'Failed to fetch bus route data: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching route data: $e');
      return polylineWaypoints; // Return empty list on error
    }
  }

  Future<List<LatLng>> _fetchPolylinePoints(
    List<PolylineWayPoint> polylineWaypoints,
    PointLatLng origin,
    PointLatLng destination,
  ) async {
    final PolylinePoints polylinePoints = PolylinePoints();
    PolylineRequest polylineRequest = PolylineRequest(
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

  Future<void> _generatePolyLineFromPoints(
    List<LatLng> pointCoordinates,
  ) async {
    const PolylineId id = PolylineId('polyline');

    final Polyline polyline = Polyline(
      polylineId: id,
      points: pointCoordinates,
      width: 5,
      color: Colors.red,
    );
    setState(() => polylines[id] = polyline);
  }
}
