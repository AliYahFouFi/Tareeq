import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/providers/BusDriverProvider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class BusDetailsPage extends StatelessWidget {
  final String busId; // Bus ID passed from previous screen

  BusDetailsPage({super.key, required this.busId});

  // Reference to the buses collection in Firestore
  final CollectionReference busses = FirebaseFirestore.instance.collection(
    'busses',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus $busId Details"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            busses
                .doc(busId)
                .snapshots(), // Listen to changes in the specific bus document
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No data available for this bus"));
          }

          var busData = snapshot.data!.data() as Map<String, dynamic>;

          // Extracting bus information
          String registeredNumber = busData['registered_number'] ?? 'N/A';
          double latitude = busData['latitude'] ?? 0.0;
          double longitude = busData['longitude'] ?? 0.0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bus Registered Number: $registeredNumber',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Latitude: ${latitude.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 16),
                ),

                SizedBox(height: 10),
                Text(
                  'Longitude: ${longitude.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                // Map showing the current bus location
                Container(
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude, longitude),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('bus_location'),
                        position: LatLng(latitude, longitude),
                        infoWindow: InfoWindow(title: 'Bus Location'),
                      ),
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
