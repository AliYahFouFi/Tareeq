import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  final CollectionReference busses = FirebaseFirestore.instance.collection(
    'busses',
  );

  /// 🚌 Add a new bus to Firestore
  Future<void> addBus(
    String busId,
    double lat,
    double lng,
    String registeredNumber,
  ) async {
    try {
      await busses.doc(busId).set({
        'latitude': lat,
        'longitude': lng,
        'registered_number': registeredNumber,
        'timestamp': FieldValue.serverTimestamp(), // To track updates
      });
      print("✅ Bus added successfully!");
    } catch (e) {
      print("❌ Error adding bus: $e");
    }
  }

  /// 📍 Update bus location
  Future<void> updateBusLocation(
    String busId,
    double newLat,
    double newLng,
  ) async {
    try {
      await busses.doc(busId).update({
        'latitude': newLat,
        'longitude': newLng,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("✅ Bus location updated!");
    } catch (e) {
      print("❌ Error updating bus location: $e");
    }
  }

  /// 🔍 Get real-time updates of all buses
  Stream<QuerySnapshot> getBusUpdates() {
    return busses.snapshots();
  }

  /// 🔍 Get a specific bus details by ID
  Future<DocumentSnapshot> getBusById(String busId) async {
    return await busses.doc(busId).get();
  }
}
