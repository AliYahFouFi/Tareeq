import 'package:flutter/material.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:flutter_frontend/util/diractions_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/SavedPlace.dart';

Marker buildSavedPlaceMarker({
  required BuildContext context,
  required SavedPlace place,
  required String mainButtonText,
  required IconData mainButtonIcon,
  required LatLng currentPosition,
}) {
  return Marker(
    markerId: MarkerId(place.id),
    position: LatLng(place.lat, place.lng),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    onTap: () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        backgroundColor: Colors.white,
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Saved Location',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final busRouteProvider = context.read<BusRouteProvider>();
                      final userLocationProvider =
                          context.read<UserLocationProvider>();

                      // Clear any old listeners
                      if (busRouteProvider.updateRouteListener != null) {
                        userLocationProvider.removeListener(
                          busRouteProvider.updateRouteListener!,
                        );
                      }

                      // Step 1: Draw route
                      busRouteProvider.polylines = await drawRoute(
                        endLat: place.lat,
                        endLon: place.lng,
                        currentPosition: currentPosition,
                      );

                      // Step 2: Get distance & duration
                      await busRouteProvider.GetDistanceAndDuration(
                        currentPosition.latitude,
                        currentPosition.longitude,
                        place.lat,
                        place.lng,
                        'walking',
                      );

                      // Step 3: Update route based on current location
                      LatLng destination = LatLng(place.lat, place.lng);
                      busRouteProvider.updateRoute(
                        currentPosition,
                        destination,
                      );

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
                      busRouteProvider.updateRouteListener =
                          updateRouteCallback;

                      context.read<UserLocationProvider>().setInfoVisible(true);
                      Navigator.pop(context);
                    },

                    icon: Icon(mainButtonIcon, size: 20, color: Colors.white),
                    label: Text(
                      mainButtonText,
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    },
  );
}
