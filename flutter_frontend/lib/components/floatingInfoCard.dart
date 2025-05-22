import 'package:flutter/material.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:provider/provider.dart';
import '../components/infotile.dart'; // Import the InfoTile widget if it's in a separate file

class FloatingInfoCard extends StatelessWidget {
  final String distance;
  final String duration;
  final bool isVisible;
  //to set the visible to off with no provider usage
  final bool VisibleIsOff = false;
  const FloatingInfoCard({
    Key? key,
    required this.distance,
    required this.duration,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return SizedBox.shrink(); // Hide if not visible

    return Positioned(
      top: 6, // Adjust distance from the app bar
      left: 16,
      right: 65,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InfoTile(
                icon: Icons.directions,
                label: "Distance",
                value: distance,
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<BusRouteProvider>().setPolyline({});
                  context.read<BusRouteProvider>().distance = "0.0 km";
                  context.read<BusRouteProvider>().duration = "0 min";
                  context.read<UserLocationProvider>().isInfoVisible = false;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.white),
                    SizedBox(width: 5),
                    Text("Cancel", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              InfoTile(
                icon: Icons.access_time,
                label: "Duration",
                value: duration,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
