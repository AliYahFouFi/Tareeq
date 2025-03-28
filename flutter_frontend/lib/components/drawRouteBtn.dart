// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:flutter_frontend/util/diractions_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class DrawRouteButton extends StatelessWidget {
  final BusStop stop;
  final LatLng currentPosition;

  const DrawRouteButton({
    Key? key,
    required this.stop,
    required this.currentPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.alt_route, size: 20, color: Colors.white),
      label: const Text('SHOW ROUTE'),
      onPressed: () async {
        context.read<BusRouteProvider>().polylines = await drawRoute(
          endLat: stop.latitude,
          endLon: stop.longitude,
          currentPosition: currentPosition,
        );

        await context.read<BusRouteProvider>().GetDistanceAndDuration(
          currentPosition.latitude,
          currentPosition.longitude,
          stop.latitude,
          stop.longitude,
          'walking',
        );

        final userLocationProvider = context.read<UserLocationProvider>();
        final busRouteProvider = context.read<BusRouteProvider>();

        LatLng currentPos = userLocationProvider.currentPosition!;

        busRouteProvider.updateRoute(
          currentPos,
          LatLng(stop.latitude, stop.longitude),
        );

        userLocationProvider.addListener(() {
          if (userLocationProvider.currentPosition != null) {
            busRouteProvider.updateRoute(
              userLocationProvider.currentPosition!,
              LatLng(stop.latitude, stop.longitude),
            );
          }
        });

        context.read<UserLocationProvider>().setInfoVisible(true);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        shadowColor: Colors.deepPurple.withOpacity(0.3),
      ),
    );
  }
}
