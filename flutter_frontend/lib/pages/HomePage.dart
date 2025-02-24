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
  List<PolylineWayPoint> polylineWaypoints = [];
  LatLng? currentPosition = null;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initializeMap());
    // _fetchBusRoutes();
    _fetchBusStops(); // Fetch stops when the screen loads
  }

  Future<void> initializeMap() async {
    _getUserLiveLocation();
    final coordinates = await _fetchPolylinePoints();
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

  // Fetch bus routes from Laravel API
  // Future<void> _fetchBusRoutes() async {
  //   try {
  //     final Routeresponse = await http.get(
  //       Uri.parse('http://10.0.2.2:8000/api/routes/1/stops'),
  //     );
  //     if (Routeresponse.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(Routeresponse.body);
  //       final BusRoute route = BusRoute.fromJson(data);
  //       setState(() {
  //         _busRoutes = [route];
  //       });
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Error: $e')));
  //   }
  // }

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

  //get the stops from the db and convert them to polyline points <polyLineWayPoint>

  // Future<List<PolylineWayPoint>> _getBusRoutePolyline(String routeId) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse("http://10.0.2.2:8000/api/routes/$routeId/stops"),
  //     );

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);

  //       if (data.containsKey('stops')) {
  //         List<dynamic> stops = data['stops'];

  //         polylineWaypoints =
  //             stops.map<PolylineWayPoint>((stop) {
  //               return PolylineWayPoint(
  //                 location: "${stop['latitude']},${stop['longitude']}",
  //                 stopOver: true,
  //               );
  //             }).toList();
  //       }
  //       return polylineWaypoints;
  //     } else {
  //       throw Exception(
  //         'Failed to fetch bus route data: ${response.statusCode}',
  //       );
  //     }
  //   } catch (e) {
  //     print('Error fetching route data: $e');
  //     return polylineWaypoints; // Return empty list on error
  //   }
  // }

  Future<List<LatLng>> _fetchPolylinePoints() async {
    final PolylinePoints polylinePoints = PolylinePoints();
    PolylineRequest polylineRequest = PolylineRequest(
      origin: PointLatLng(33.90140000, 35.51960000),
      destination: PointLatLng(33.90100000, 35.54220000),
      mode: TravelMode.driving,
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
