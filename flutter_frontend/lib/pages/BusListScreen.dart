import 'package:flutter/material.dart';
import 'package:flutter_frontend/Db/database_helper.dart';
import 'package:flutter_frontend/models/BusModel.dart';
import 'package:flutter_frontend/pages/ReportFormScreen.dart'; // Adjust path

class BusListScreen extends StatefulWidget {
  @override
  _BusListScreenState createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  List<Bus> _buses = [];

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  void _loadBuses() async {
    final buses = await BusDatabase.getBuses();
    setState(() {
      _buses = buses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Bus'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _buses.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : ListView.builder(
              itemCount: _buses.length,
              itemBuilder: (context, index) {
                final bus = _buses[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.directions_bus, color: Colors.redAccent),
                    title: Text(bus.name),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportFormScreen(bus: bus),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}