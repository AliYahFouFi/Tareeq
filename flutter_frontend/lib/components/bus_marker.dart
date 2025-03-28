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
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _BusStopInfoSheet(stop: stop),
  );
}

class _BusStopInfoSheet extends StatelessWidget {
  final BusStop stop;

  const _BusStopInfoSheet({required this.stop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with drag handle
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Header content
          _buildHeader(context),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Draw route button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: DrawRouteButton(
                      stop: stop,
                      currentPosition:
                          context
                              .watch<UserLocationProvider>()
                              .currentPosition!,
                    ),
                  ),

                  // ETA section
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Route: ${stop.routeName}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
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
        // Section title
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'LIVE BUS ARRIVALS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Bus ETA content
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!busesSnapshot.hasData || busesSnapshot.data!.docs.isEmpty) {
          return _buildInfoCard(
            icon: Icons.error_outline,
            color: Colors.orange,
            text: 'No buses currently available',
          );
        }

        final buses =
            busesSnapshot.data!.docs.where((bus) {
              final busData = bus.data() as Map<String, dynamic>;
              final String? routeName = busData['routeName'];
              final bool isActive = busData['active'] as bool? ?? false;
              return isActive &&
                  routeName != null &&
                  routeName.contains(stop.routeName);
            }).toList();

        if (buses.isEmpty) {
          return _buildInfoCard(
            icon: Icons.directions_bus,
            color: Colors.orange,
            text: 'No active buses on this route',
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
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_bus,
                color: Colors.blue,
                size: 24,
              ),
            ),
            title: Text(
              'Bus $busId',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reg: $registeredNumber',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  _buildETAStatus(etaSnapshot),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildETAStatus(AsyncSnapshot<Map<String, String>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Calculating...',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      );
    }

    if (!snapshot.hasData) {
      return Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 16),
          const SizedBox(width: 6),
          Text(
            'ETA unavailable',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(Icons.timer, color: Colors.green[600], size: 16),
        const SizedBox(width: 6),
        Text(
          'ETA: ${snapshot.data!['duration']}',
          style: TextStyle(
            color: Colors.green[600],
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.alt_route, color: Colors.blue[400], size: 16),
        const SizedBox(width: 6),
        Text(
          '${snapshot.data!['distance']} away',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
