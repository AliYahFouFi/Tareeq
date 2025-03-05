import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/NavBar.dart';
import 'package:flutter_frontend/components/bus_map.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/BusStopsProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:flutter_frontend/util/diractions_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_frontend/util/polyline_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _mapController;
  List<BusStop> _busStops = [];
  LatLng? _currentPosition;
  // A flag to toggle between the sets

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
  }

  Future<void> initializeMap() async {
    await context.read<UserLocationProvider>().initializeLocation();
  }

  // Convert bus stops to Google Map markers
  Set<Marker> getBusStopMarkers() {
    BitmapDescriptor icon = context.watch<BusStopsProvider>().busStopIcon;
    return _busStops.map((stop) {
      return Marker(
        markerId: MarkerId(stop.id.toString()),
        position: LatLng(stop.latitude, stop.longitude),
        infoWindow: InfoWindow(title: stop.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              String? _distance = '';
              String? _duration = '';

              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 250,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Text(stop.name, style: TextStyle(fontSize: 24)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Latitude: ${stop.latitude}'),
                                SizedBox(width: 20),
                                Text('Longitude: ${stop.longitude}'),
                              ],
                            ),
                          ),

                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Get Distance and Duration',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            onTap: () async {
                              var data = await GetDistanceAndDuration(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                                stop.latitude,
                                stop.longitude,
                                'walking',
                              );
                              setState(() {
                                _distance = data["distance"];
                                _duration = data['duration'];
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Distance: $_distance'),
                                SizedBox(width: 20),
                                Text('Duration: $_duration'),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              context
                                  .read<BusRouteProvider>()
                                  .polylines = await drawRoute(
                                endLat: stop.latitude,
                                endLon: stop.longitude,
                                currentPosition: _currentPosition!,
                              );
                            },

                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Draw Route',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Tareeq', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: BusMap(
        currentPosition: _currentPosition,

        busStops: _busStops,
        getBusStopMarkers: getBusStopMarkers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
      bottomNavigationBar: NavBar(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.location_searching),
        onPressed: () async {
          context.read<BusRouteProvider>().polylines =
              await initializeAllPolylines();
          context.read<BusStopsProvider>().loadAllBusStops();
        },
      ),
    );
  }
}
