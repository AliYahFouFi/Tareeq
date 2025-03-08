import 'package:flutter/material.dart';
import '../components/infotile.dart'; // Import the InfoTile widget if it's in a separate file

class FloatingInfoCard extends StatelessWidget {
  final String distance;
  final String duration;
  final bool isVisible;

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
      top: 10, // Adjust distance from the app bar
      left: 16,
      right: 16,
      child: Card(
        elevation: 4, // Adds shadow for a floating effect
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white, // Light background for better contrast
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
