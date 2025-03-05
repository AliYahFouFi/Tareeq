import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocationProvider extends ChangeNotifier {
  final Location _locationController = Location();
  LatLng? _currentPosition;
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  LatLng? get currentPosition => _currentPosition;
  LatLng? getUserLocation() {
    return _currentPosition;
  }

  UserLocationProvider() {
    initializeLocation();
  }

  Future<void> initializeLocation() async {
    await _checkPermissions();
    if (_serviceEnabled && _permissionGranted == PermissionStatus.granted) {
      _startLocationUpdates();
    }
  }

  Future<void> _checkPermissions() async {
    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
    }
  }

  void _startLocationUpdates() {
    _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        _currentPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        notifyListeners(); // Notify widgets listening to this provider
      }
    });
  }
}
