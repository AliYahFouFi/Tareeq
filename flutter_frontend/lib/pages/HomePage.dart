import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/NavBar.dart';
import 'package:flutter_frontend/components/bus_map.dart';
import 'package:flutter_frontend/components/bus_marker.dart';
import 'package:flutter_frontend/components/drawRouteBtn.dart';
import 'package:flutter_frontend/components/floatingInfoCard.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/providers/BusDriverProvider.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/BusStopsProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_frontend/util/polyline_util.dart';
import 'package:provider/provider.dart';
import '../components/infoTile.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initializeMap());
  }

  // in didChangeDependencies we get the busStops from the provider or any other
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.location_searching),
        onPressed:
            () => context.read<BusDriverProvider>().startLocationUpdates(),
        // onPressed: () async {
        //   context.read<BusRouteProvider>().polylines =
        //       await initializeAllPolylines();
        //   context.read<BusStopsProvider>().loadAllBusStops();
        // },
      ),
    );
  }

  setInfoVisibility() {
    setState(() {
      _isInfoVisible = true;
    });
  }
}
