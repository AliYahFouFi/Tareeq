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

  @override
  /// Start listening to location changes and updates the bus location in the
  /// Firestore database when the bus has moved at least 20 meters. This method
  /// is called in the constructor of the class and should not be called
  /// manually.
  void startLocationUpdates(String busId) {
    toggleBusStatus(busId);
    _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) async {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        LatLng newPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        // Update only if moved at least 200 meters
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

  Future<void> toggleBusStatus(String busId) async {
    try {
      // 1. Fetch the current bus document
      final DocumentSnapshot busSnapshot = await busses.doc(busId).get();

      if (busSnapshot.exists) {
        // 2. Get the current 'active' status (default to false if not set)
        final bool currentStatus = busSnapshot['active'] ?? false;

        // 3. Toggle the value
        final bool newStatus = !currentStatus;

        // 4. Update Firestore
        await busses.doc(busId).update({'active': newStatus});

        print("✅ Bus status toggled to $newStatus");
      } else {
        print("❌ Bus document does not exist");
      }
    } catch (e) {
      print("❌ Error toggling bus status: $e");
    }
  }
}
