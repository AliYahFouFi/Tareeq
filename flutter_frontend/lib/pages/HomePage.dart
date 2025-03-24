import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/NavBar.dart';
import 'package:flutter_frontend/components/bus_map.dart';
import 'package:flutter_frontend/components/bus_marker.dart';
import 'package:flutter_frontend/components/drawer.dart';
import 'package:flutter_frontend/components/floatingInfoCard.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/providers/BusDriverProvider.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/BusStopsProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _mapController;
  List<BusStop> _busStops = [];
  LatLng? _currentPosition;
  bool _isInfoVisible = false;
  String _distance = '';
  String _duration = '';
  String selectedRole = ' ';
  bool _isLoggedIn = false;
  bool _isDriver = false;
  String _busId = '';
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) => initializeMap());
  }

  // in didChangeDependencies we get the busStops from the provider or any other
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _busStops = context.watch<BusStopsProvider>().busStops;
    _currentPosition = context.watch<UserLocationProvider>().getUserLocation();
    _distance = context.watch<BusRouteProvider>().distance;
    _duration = context.watch<BusRouteProvider>().duration;
    _isInfoVisible = context.watch<UserLocationProvider>().isInfoVisible;
  }

  Future<void> initializeMap() async {
    await context.read<UserLocationProvider>().initializeLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareeq', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      drawer: AppDrawer(),
      body: Stack(
        children: [
          // Map Section (This is at the bottom)
          Positioned.fill(
            child: BusMap(
              currentPosition: _currentPosition,
              busStops: _busStops,
              getBusStopMarkers:
                  () => getBusStopMarkers(
                    busStops: _busStops,
                    currentPosition: _currentPosition!,
                    distance: _distance,
                    duration: _duration,
                    context: context,
                  ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
          ),

          // Floating Info Box
          if (_isInfoVisible)
            // Floating Info Card
            FloatingInfoCard(
              distance: _distance,
              duration: _duration,
              isVisible: _isInfoVisible,
            ),
        ],
      ),
      bottomNavigationBar: NavBar(),

      floatingActionButton:
          _isLoggedIn && _isDriver
              ?
              //if the role is driver show a button to make the bus active
              FloatingActionButton.extended(
                onPressed:
                    () => context
                        .read<BusDriverProvider>()
                        .startLocationUpdates(_busId),
                label: const Text(
                  "Start Tracking",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.location_searching, size: 28),
                backgroundColor:
                    Colors.blueAccent, // Change this color as needed
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              )
              : SizedBox(height: 0),
    );
  }

  _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    final id = prefs.getString('id');
    if (token != null && role != null) {
      setState(() {
        _isLoggedIn = true;
        _isDriver = role == 'driver';
        _busId = id!;
      });
    } else {
      setState(() {
        _isLoggedIn = false;
        _isDriver = false;
        _busId = '';
      });
    }
  }
}
