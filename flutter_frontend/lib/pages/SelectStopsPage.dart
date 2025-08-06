import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/BusRoute_model.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/util/BusStop_service.dart';
import 'package:flutter_frontend/util/polyline_util.dart';
import 'package:provider/provider.dart';

class SelectStopsPage extends StatefulWidget {
  @override
  _SelectStopsPageState createState() => _SelectStopsPageState();
}

class _SelectStopsPageState extends State<SelectStopsPage> {
  List<BusRoute> routes = [];
  BusRoute? selectedRoute;
  List<BusStop> routeStops = [];
  BusStop? originStop;
  BusStop? destinationStop;
  List<BusStop> stopsBetween = [];
  String? travelDistance;
  String? travelDuration;

  @override
  void initState() {
    super.initState();
    fetchAllBusRoutes().then((fetchedRoutes) {
      setState(() {
        routes = fetchedRoutes;
      });
    });
  }

  void _onRouteSelected(BusRoute? route) async {
    if (route == null) return;
    List<BusStop> stops = await BusStopService.getBusStopsForOneRoute(
      route.route_id.toString(),
    );

    setState(() {
      selectedRoute = route;
      routeStops = stops;
      originStop = null;
      destinationStop = null;
      stopsBetween = [];
      travelDistance = null;
      travelDuration = null;
    });
  }

  Future<void> fetchDistanceAndDuration() async {
    if (originStop != null && destinationStop != null) {
      final result = await context
          .read<BusRouteProvider>()
          .GetDistanceAndDuration(
            originStop!.latitude,
            originStop!.longitude,
            destinationStop!.latitude,
            destinationStop!.longitude,
            'driving',
          );

      setState(() {
        travelDistance = result['distance'];
        travelDuration = result['duration'];
      });
    }
  }

  void _updatePreview() {
    if (originStop != null && destinationStop != null) {
      int originIndex = routeStops.indexOf(originStop!);
      int destinationIndex = routeStops.indexOf(destinationStop!);

      if (originIndex != -1 && destinationIndex != -1) {
        int start =
            originIndex < destinationIndex ? originIndex : destinationIndex;
        int end =
            originIndex > destinationIndex ? originIndex : destinationIndex;

        setState(() {
          stopsBetween = routeStops.sublist(start, end + 1);
        });
        fetchDistanceAndDuration();
      }
    }
  }

  void _showRouteSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please select a route first!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        title: const Text(
          'Plan Your Journey',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route selection
                      _buildSectionHeader("1. Select Your Route"),
                      const SizedBox(height: 8),
                      _buildRouteDropdown(),
                      const SizedBox(height: 24),

                      // Origin and destination
                      _buildSectionHeader("2. Choose Your Stops"),
                      const SizedBox(height: 16),
                      _buildStopDropdown(
                        label: "Starting Point",
                        value: originStop,
                        onChanged: (value) {
                          setState(() => originStop = value);
                          _updatePreview();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildStopDropdown(
                        label: "Destination",
                        value: destinationStop,
                        onChanged: (value) {
                          setState(() => destinationStop = value);
                          _updatePreview();
                        },
                      ),
                      const SizedBox(height: 24),

                      // Route preview
                      if (stopsBetween.isNotEmpty) ...[
                        _buildSectionHeader("Journey Details"),
                        const SizedBox(height: 16),
                        _buildJourneyInfoCard(),
                        const SizedBox(height: 16),
                        _buildStopsList(),
                      ],
                      const SizedBox(height: 80), // Space for bottom tip
                    ],
                  ),
                ),
              ),
              // Bottom tip
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  border: Border(
                    top: BorderSide(color: Colors.deepPurple[100]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Colors.deepPurple[400],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tip: Select a route first, then choose your start and end stops',
                        style: TextStyle(
                          color: Colors.deepPurple[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _buildRouteDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<BusRoute>(
        isExpanded: true, // Ensures the dropdown button takes full width
        value: selectedRoute,
        decoration: InputDecoration(
          labelText: 'Bus Route',
          labelStyle: TextStyle(color: Colors.grey[700]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: Icon(
            Icons.directions_bus_rounded,
            color: Colors.deepPurple,
          ),
        ),
        items:
            routes.map((route) {
              return DropdownMenuItem<BusRoute>(
                value: route,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Text(
                    route.route_name,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
        onChanged: _onRouteSelected,
        style: const TextStyle(color: Colors.black87),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildStopDropdown({
    required String label,
    required BusStop? value,
    required Function(BusStop?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<BusStop>(
        isExpanded: true, // This ensures the dropdown button takes full width
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: Icon(
            label.contains("Starting") ? Icons.flag : Icons.location_pin,
            color: label.contains("Starting") ? Colors.green : Colors.red,
          ),
        ),
        items:
            selectedRoute == null
                ? []
                : routeStops.map((stop) {
                  return DropdownMenuItem<BusStop>(
                    value: stop,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Text(
                        stop.name,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
        onChanged:
            selectedRoute == null
                ? (_) => _showRouteSnackBar(context)
                : (value) => onChanged(value),
        style: const TextStyle(color: Colors.black87),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildJourneyInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  icon: Icons.access_time_rounded,
                  color: Colors.teal,
                  title: "Duration",
                  value: travelDuration ?? "--",
                ),
                _buildInfoItem(
                  icon: Icons.directions_rounded,
                  color: Colors.blue,
                  title: "Distance",
                  value: travelDistance ?? "--",
                ),
                _buildInfoItem(
                  icon: Icons.stop_circle_rounded,
                  color: Colors.purple,
                  title: "Stops",
                  value: stopsBetween.length.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStopsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Journey Stops:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stopsBetween.length,
              separatorBuilder:
                  (_, __) => Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final stop = stopsBetween[index];
                final isFirst = index == 0;
                final isLast = index == stopsBetween.length - 1;

                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          isFirst
                              ? Colors.green.withOpacity(0.1)
                              : isLast
                              ? Colors.red.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFirst
                          ? Icons.flag_rounded
                          : isLast
                          ? Icons.location_pin
                          : Icons.circle_rounded,
                      color:
                          isFirst
                              ? Colors.green
                              : isLast
                              ? Colors.red
                              : Colors.blue,
                      size: isFirst || isLast ? 20 : 12,
                    ),
                  ),
                  title: Text(
                    stop.name,
                    style: TextStyle(
                      fontWeight:
                          isFirst || isLast
                              ? FontWeight.w600
                              : FontWeight.normal,
                      color:
                          isFirst
                              ? Colors.green[800]
                              : isLast
                              ? Colors.red[800]
                              : Colors.grey[800],
                    ),
                  ),
                  subtitle: Text(
                    stop.address,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
