import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../services/fireBase_service.dart';

class BusDriverProvider extends UserLocationProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BusDriverProvider() {
    initializeLocation();
  }

  final Location _locationController = Location();
  LatLng? _currentPosition;
  bool _serviceEnabled = false;
  LatLng? _lastUpdatedPosition; // Store last position
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  final CollectionReference busses = FirebaseFirestore.instance.collection(
    'busses',
  );
  StreamSubscription<LocationData>? _locationSubscription;
  @override
  /// Start listening to location changes and updates the bus location in the
  /// Firestore database when the bus has moved at least 20 meters. This method
  /// is called in the constructor of the class and should not be called
  /// manually.
  void startLocationUpdates(String busId) {
    toggleBusStatus(busId, true);

    _locationSubscription = _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) async {
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
          await _updateBusLocation(newPosition, busId);
        }
      }
    });

    notifyListeners();
  }

  void stopLocationUpdates(String busId) {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
      _locationSubscription = null;
    }
    toggleBusStatus(busId, false);
    notifyListeners();
  }

  Future<void> _updateBusLocation(LatLng newPosition, String busId) async {
    try {
      await _firestore.collection('busses').doc(busId).update({
        'latitude': newPosition.latitude,
        'longitude': newPosition.longitude,
        'last_updated': Timestamp.now(),
      });
    } catch (e) {
      print("Error updating bus location: $e");
    }
  }

  Future<LatLng?> getBusLocation(busId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('busses').doc(busId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return LatLng(data['latitude'], data['longitude']);
      }
    } catch (e) {
      print("Error fetching bus location: $e");
    }
    return null;
  }

  /// 🔍 Get the location of a specific bus
  Future<LatLng?> getBusLatLng(String busId) async {
    try {
      final doc = await busses.doc(busId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return LatLng(
          (data['latitude'] as num).toDouble(),
          (data['longitude'] as num).toDouble(),
        );
      }
      return null;
    } catch (e) {
      print("❌ Error getting bus location: $e");
      return null;
    }
  }

  Future<bool> isBusActive(String busId) async {
    try {
      final doc = await _firestore.collection('busses').doc(busId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['active'] as bool? ?? false; // Handle null case
      }
      return false;
    } catch (e) {
      print("❌ Error checking bus status: $e");
      return false;
    }
  }

  Future<void> toggleBusStatus(String busId, bool status) async {
    try {
      await _firestore.collection('busses').doc(busId).update({
        'active': status,
      });
      _isActive = status;
      notifyListeners();
    } catch (e) {
      print("❌ Error updating bus status: $e");
    }
  }

  bool _isActive = false; // Track active status

  bool get isActive => _isActive;

  Future<void> checkBusStatus(String busId) async {
    try {
      final doc = await _firestore.collection('busses').doc(busId).get();
      if (doc.exists) {
        _isActive = doc.data()?['active'] as bool? ?? false;
        notifyListeners(); // Update UI
      }
    } catch (e) {
      print("❌ Error checking bus status: $e");
    }
  }
}
