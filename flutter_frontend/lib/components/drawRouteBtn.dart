import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/util/diractions_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class DrawRouteButton extends StatelessWidget {
  final BusStop stop;
  final Function setInfoVisible;
  final LatLng currentPosition; // Ensure you import your Position model

  const DrawRouteButton({
    Key? key,
    required this.stop,
    required this.setInfoVisible,
    required this.currentPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        context.read<BusRouteProvider>().polylines = await drawRoute(
          endLat: stop.latitude,
          endLon: stop.longitude,
          currentPosition: currentPosition,
        );
        await context.read<BusRouteProvider>().GetDistanceAndDuration(
          currentPosition!.latitude,
          currentPosition!.longitude,
          stop.latitude,
          stop.longitude,
          'walking',
        );

        setInfoVisible();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Draw Route', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
