// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/drawRouteBtn.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/providers/BusDriverProvider.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/BusStopsProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

Set<Marker> getBusStopMarkers({
  required BuildContext context,
  required List<BusStop> busStops,
  required LatLng currentPosition,
  required String distance,
  required String duration,
}) {
  BitmapDescriptor icon = context.watch<BusStopsProvider>().busStopIcon;

  return busStops.map((stop) {
    return Marker(
      markerId: MarkerId(stop.id.toString()),
      position: LatLng(stop.latitude, stop.longitude),
      infoWindow: InfoWindow(title: stop.name),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      onTap: () => _showStopInfoBottomSheet(context, stop),
    );
  }).toSet();
}

void _showStopInfoBottomSheet(BuildContext context, BusStop stop) {
  showModalBottomSheet(
    context: context,
    builder: (context) => _BusStopInfoSheet(stop: stop),
  );
}

class _BusStopInfoSheet extends StatelessWidget {
  final BusStop stop;

  const _BusStopInfoSheet({required this.stop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DrawRouteButton(
                    stop: stop,
                    currentPosition:
                        context.watch<UserLocationProvider>().currentPosition!,
                  ),
                  const SizedBox(height: 24),
                  _buildETAInfo(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_bus_filled, color: Colors.blue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stop.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildETAInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Live Bus ETAs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        FutureBuilder<LatLng?>(
          future: context.watch<BusDriverProvider>().getBusLatLng('1'),
          builder: (context, busSnapshot) {
            return _buildETAContent(context, busSnapshot);
          },
        ),
      ],
    );
  }

  Widget _buildETAContent(
    BuildContext context,
    AsyncSnapshot<LatLng?> busSnapshot,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('busses').snapshots(),
      builder: (context, busesSnapshot) {
        if (busesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!busesSnapshot.hasData || busesSnapshot.data!.docs.isEmpty) {
          return _buildInfoCard(
            icon: Icons.error_outline,
            color: Colors.orange,
            text: 'No buses available',
          );
        }

        // Filter buses by routename and if it isactive

        final buses =
            busesSnapshot.data!.docs.where((bus) {
              final busData = bus.data() as Map<String, dynamic>;

              final String? routeName = busData['routeName'];
              final bool isActive =
                  busData['active'] as bool? ?? false; // Check active status

              return isActive &&
                  routeName != null &&
                  routeName.contains(stop.routeName);
            }).toList();

        if (buses.isEmpty) {
          return _buildInfoCard(
            icon: Icons.error_outline,
            color: Colors.orange,
            text: 'No buses for this route',
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: buses.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final bus = buses[index];
            final busData = bus.data() as Map<String, dynamic>;
            final busPosition = LatLng(
              (busData['latitude'] as num).toDouble(),
              (busData['longitude'] as num).toDouble(),
            );

            return _buildBusETAItem(
              context,
              bus.id,
              busData['registered_number'] ?? 'Unknown',
              busPosition,
            );
          },
        );
      },
    );
  }

  Widget _buildBusETAItem(
    BuildContext context,
    String busId,
    String registeredNumber,
    LatLng busPosition,
  ) {
    //________________________________

    return FutureBuilder<Map<String, String>>(
      future: context.read<BusRouteProvider>().GetDistanceAndDuration(
        busPosition.latitude,
        busPosition.longitude,
        stop.latitude,
        stop.longitude,
        'Driving',
      ),

      builder: (context, etaSnapshot) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_bus,
                color: Colors.blue,
                size: 28,
              ),
            ),
            title: Text(
              'Bus $busId',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Reg: $registeredNumber',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                // if (isActive)
                _buildETAStatus(etaSnapshot),
                //else
                // _buildInactiveStatus(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInactiveStatus() {
    return Row(
      children: [
        Icon(Icons.do_not_disturb, color: Colors.red[300], size: 16),
        const SizedBox(width: 4),
        Text(
          'Currently inactive',
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  //THIS NEED TO BE MODIFIED
  Widget _buildETAStatus(AsyncSnapshot<Map<String, String>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text('Calculating...', style: TextStyle(color: Colors.grey[600])),
        ],
      );
    }

    if (!snapshot.hasData) {
      return Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 4),
          Text('ETA unavailable', style: TextStyle(color: Colors.grey[600])),
        ],
      );
    }

    return Row(
      children: [
        const Icon(Icons.timer, color: Colors.green, size: 16),
        const SizedBox(width: 4),
        Text(
          'ETA: ${snapshot.data!['duration']}',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.alt_route, color: Colors.blue, size: 16),
        const SizedBox(width: 4),
        Text(
          '${snapshot.data!['distance']} away',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
