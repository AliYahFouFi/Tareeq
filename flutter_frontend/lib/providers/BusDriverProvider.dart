import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../services/fireBase_service.dart';

class BusDriverProvider extends UserLocationProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String busId;
  bool isActive = false;
  BusDriverProvider({required this.busId}) {
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
  void startLocationUpdates() {
    this.isActive = true;
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
            calculateDistance(_lastUpdatedPosition!, newPosition) > 200) {
          _currentPosition = newPosition;
          _lastUpdatedPosition = newPosition; // Save last updated position
          notifyListeners();
          await _updateBusLocation(newPosition);
        }
      }
    });
    notifyListeners();
  }

  Future<void> _updateBusLocation(LatLng newPosition) async {
    try {
      await _firestore.collection('busses').doc('1').update({
        'latitude': newPosition.latitude,
        'longitude': newPosition.longitude,
        'last_updated': Timestamp.now(),
      });
    } catch (e) {
      print("Error updating bus location: $e");
    }
  }

  Future<LatLng?> getBusLocation() async {
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
}
