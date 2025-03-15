import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/fireBase_service.dart';

class BusPage extends StatefulWidget {
  const BusPage({super.key});

  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  final FirestoreServices _firestoreServices = FirestoreServices();

  final TextEditingController _busIdController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _registeredNumberController =
      TextEditingController();

  void _addBus() {
    if (_busIdController.text.isNotEmpty &&
        _latController.text.isNotEmpty &&
        _lngController.text.isNotEmpty &&
        _registeredNumberController.text.isNotEmpty) {
      _firestoreServices.addBus(
        _busIdController.text,
        double.parse(_latController.text),
        double.parse(_lngController.text),
        _registeredNumberController.text,
      );
      _busIdController.clear();
      _latController.clear();
      _lngController.clear();
      _registeredNumberController.clear();
    }
  }

  void _updateBusLocation() {
    if (_busIdController.text.isNotEmpty &&
        _latController.text.isNotEmpty &&
        _lngController.text.isNotEmpty) {
      _firestoreServices.updateBusLocation(
        _busIdController.text,
        double.parse(_latController.text),
        double.parse(_lngController.text),
      );
      _latController.clear();
      _lngController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bus Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _busIdController,
              decoration: const InputDecoration(labelText: "Bus ID"),
            ),
            TextField(
              controller: _latController,
              decoration: const InputDecoration(labelText: "Latitude"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _lngController,
              decoration: const InputDecoration(labelText: "Longitude"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _registeredNumberController,
              decoration: const InputDecoration(labelText: "Registered Number"),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addBus,
                  child: const Text("Add Bus"),
                ),
                ElevatedButton(
                  onPressed: _updateBusLocation,
                  child: const Text("Update Location"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Live Bus Locations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreServices.getBusUpdates(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No buses available"));
                  }

                  var buses = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: buses.length,
                    itemBuilder: (context, index) {
                      var bus = buses[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const Icon(
                          Icons.directions_bus,
                          color: Colors.blue,
                        ),
                        title: Text("Bus: ${bus['registered_number']}"),
                        subtitle: Text(
                          "Lat: ${bus['latitude']}, Lng: ${bus['longitude']}",
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
