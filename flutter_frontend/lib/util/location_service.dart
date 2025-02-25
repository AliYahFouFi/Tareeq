import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

/// This functionS checks if the location service is enabled and requests
/// the user to enable it if it is not. It also requests the user's
/// permission to access their location if not already granted.
/// Once the service is enabled and permission is granted, it fetches
/// the user's current location data.
/// If the service is not enabled or permission is not granted, the
/// function returns early without fetching the location data.

Location LocationController = new Location();
late GoogleMapController _mapController;
LatLng? currentPosition = null;

Future<void> getUserLiveLocation() async {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  // Check if the location service is enabled
  _serviceEnabled = await LocationController.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await LocationController.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }
  //Check if the user has granted permission
  _permissionGranted = await LocationController.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await LocationController.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }
  //for getting the live location of the user NEED TO BE CHANGED
  // LocationController.onLocationChanged.listen((LocationData currentLocation) {
  //   if (currentLocation.latitude != null && currentLocation.longitude != null) {
  //     setState(() {
  //       currentPosition = LatLng(
  //         currentLocation.latitude!,
  //         currentLocation.longitude!,
  //       );
  //     });
  //   }
  //   print(currentPosition);
  // });
}

getUserLocation() async {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  // Check if the location service is enabled
  _serviceEnabled = await LocationController.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await LocationController.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  //Check if the user has granted permission
  _permissionGranted = await LocationController.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await LocationController.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }
  _locationData = await LocationController.getLocation();
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
