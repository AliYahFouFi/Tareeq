import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/NavBar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beirut Map')),
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
        cameraTargetBounds: CameraTargetBounds(
          LatLngBounds(
            southwest: LatLng(33.888630, 35.495480),
            northeast: LatLng(33.8938, 35.5018),
          ),
        ),
        //IN THIS SET OF MARKERS THE BUS STOPS ARE MARKED we should get the bus stops from the database
        // ignore: prefer_collection_literals
        markers: Set<Marker>.of([
          Marker(
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            markerId: const MarkerId('beirut'),
            position: LatLng(33.888630, 35.495480),
            infoWindow: const InfoWindow(title: 'Beirut'),
          ),
          Marker(
            markerId: const MarkerId('beirut2'),
            position: LatLng(33.8938, 35.5018),
          ),
        ]),
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
