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
        final busRouteProvider = context.read<BusRouteProvider>();
        final userLocationProvider = context.read<UserLocationProvider>();

        // Clear any old listeners
        if (busRouteProvider.updateRouteListener != null) {
          userLocationProvider.removeListener(
            busRouteProvider.updateRouteListener!,
          );
        }

        // Step 1: Draw route
        busRouteProvider.polylines = await drawRoute(
          endLat: stop.latitude,
          endLon: stop.longitude,
          currentPosition: currentPosition,
        );

        // Step 2: Get distance & duration
        await busRouteProvider.GetDistanceAndDuration(
          currentPosition.latitude,
          currentPosition.longitude,
          stop.latitude,
          stop.longitude,
          'walking',
        );

        // Step 3: Update route based on current location
        LatLng destination = LatLng(stop.latitude, stop.longitude);
        busRouteProvider.updateRoute(currentPosition, destination);

        // Step 4: Define a listener callback that updates the route
        void updateRouteCallback() {
          if (userLocationProvider.currentPosition != null) {
            busRouteProvider.updateRoute(
              userLocationProvider.currentPosition!,
              destination,
            );
          }
        }

        // Step 5: Attach the listener & store it for later removal
        userLocationProvider.addListener(updateRouteCallback);
        busRouteProvider.updateRouteListener = updateRouteCallback;

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
