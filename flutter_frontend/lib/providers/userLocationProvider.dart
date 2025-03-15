import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocationProvider extends ChangeNotifier {
  final Location _locationController = Location();
  LatLng? _currentPosition;
  bool _serviceEnabled = false;
  LatLng? _lastUpdatedPosition; // Store last position
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  bool isInfoVisible = false;

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
        LatLng newPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        // Update only if moved at least 20 meters
        if (_lastUpdatedPosition == null ||
            calculateDistance(_lastUpdatedPosition!, newPosition) > 20) {
          _currentPosition = newPosition;
          _lastUpdatedPosition = newPosition; // Save last updated position
          notifyListeners();
        }
      }
    });
  }

  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // in meters
    double dLat = (end.latitude - start.latitude) * (pi / 180);
    double dLon = (end.longitude - start.longitude) * (pi / 180);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(start.latitude * (pi / 180)) *
            cos(end.latitude * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  void setInfoVisible(bool value) {
    isInfoVisible = value;
    notifyListeners();
  }
}
