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
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          _buildDragHandle(),

          // Header with stop info
          _buildHeader(context),

          // Main content area
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: DrawRouteButton(
                      stop: stop,
                      currentPosition:
                          context
                              .watch<UserLocationProvider>()
                              .currentPosition!,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  sliver: SliverToBoxAdapter(child: _buildETAInfo(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bus icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus_rounded,
              color: Colors.blue,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // Stop info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(Icons.route, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Route: ${stop.routeName}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
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
        Text(
          'LIVE BUS ARRIVALS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 12),

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
          return _buildLoadingIndicator();
        }

        if (!busesSnapshot.hasData || busesSnapshot.data!.docs.isEmpty) {
          return _buildInfoCard(
            icon: Icons.error_outline_rounded,
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
            icon: Icons.directions_bus_rounded,
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

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading bus information...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_bus_rounded,
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
      return _buildStatusRow(
        icon: Icons.timelapse_rounded,
        color: Colors.grey,
        text: 'Calculating ETA...',
      );
    }

    if (!snapshot.hasData) {
      return _buildStatusRow(
        icon: Icons.error_outline_rounded,
        color: Colors.red,
        text: 'ETA unavailable',
      );
    }

    return Column(
      children: [
        _buildStatusRow(
          icon: Icons.timer_rounded,
          color: Colors.green,
          text: 'ETA: ${snapshot.data!['duration']}',
          isBold: true,
        ),
        const SizedBox(height: 6),
        _buildStatusRow(
          icon: Icons.alt_route_rounded,
          color: Colors.blue,
          text: '${snapshot.data!['distance']} away',
        ),
      ],
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required Color color,
    required String text,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
          ),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
