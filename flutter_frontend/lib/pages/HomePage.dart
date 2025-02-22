import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/NavBar.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

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

  @override
  @override
  void initState() {
    super.initState();
    _fetchBusStops(); // Fetch stops when the screen loads
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
      body: GoogleMap(
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
        //restrict the camera to a specific area
        // cameraTargetBounds: CameraTargetBounds(
        //   LatLngBounds(
        //     southwest: LatLng(33.888630, 35.495480),
        //     northeast: LatLng(33.8938, 35.5018),
        //   ),
        // ),
        markers: _getBusStopMarkers(),
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

  /// Retrieves the user's current location.
  ///
  /// This function checks if the location service is enabled and requests
  /// the user to enable it if it is not. It also requests the user's
  /// permission to access their location if not already granted.
  /// Once the service is enabled and permission is granted, it fetches
  /// the user's current location data.
  ///
  /// If the service is not enabled or permission is not granted, the
  /// function returns early without fetching the location data.

  Future<void> _getUserLocation() async {
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
}
