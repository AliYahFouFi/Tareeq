import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';

class BusMap extends StatefulWidget {
  final LatLng? currentPosition;
  final Map<PolylineId, Polyline> polylines;
  final Set<Polyline> polylinesDD;
  final bool showAllPolylines;
  final List<BusStop> busStops;
  final Set<Marker> Function() getBusStopMarkers;
  final Function(GoogleMapController) onMapCreated;

  const BusMap({
    Key? key,
    required this.currentPosition,
    required this.polylines,
    required this.polylinesDD,
    required this.showAllPolylines,
    required this.busStops,
    required this.getBusStopMarkers,
    required this.onMapCreated,
  }) : super(key: key);

  @override
  _BusMapState createState() => _BusMapState();
}

class _BusMapState extends State<BusMap> {
  static const LatLng _beirutLocation = LatLng(33.8938, 35.5018);
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _beirutLocation,
            zoom: 12.0,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            widget.onMapCreated(controller);

            // Auto-zoom to user location on app start
            if (widget.currentPosition != null) {
              Future.delayed(Duration(milliseconds: 500), () {
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(widget.currentPosition!, 16.0),
                );
              });
            }
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false, // Removes default zoom buttons
          compassEnabled: true,
          mapType: MapType.normal,
          polylines: widget.showAllPolylines
              ? Set<Polyline>.of(widget.polylines.values)
              : widget.polylinesDD,
          markers: widget.getBusStopMarkers(),
          onCameraMove: (position) {
            if ((position.target.latitude - _beirutLocation.latitude).abs() >
                    0.1 ||
                (position.target.longitude - _beirutLocation.longitude).abs() >
                    0.1) {
              _mapController.animateCamera(
                CameraUpdate.newLatLng(_beirutLocation),
              );
            }
          },
        ),

        // Zoom Out Button
        Positioned(
          bottom: 77.5,
          right: 15,
          child:Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEADDFF), // Light purple background
              borderRadius: BorderRadius.circular(16), // Rounded corners
            ),
            child: FloatingActionButton(
              onPressed: _zoomOut,
              elevation: 0, // No extra shadow
              child: const Icon(
                Icons.zoom_out,
                color: Color(0xFF4F378B), // Deep purple icon
              ),
            ),
          ),
        ),
        // Zoom to User Button
        Positioned(
          bottom: 140,
          right: 15,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEADDFF), // Light Purple Background
              borderRadius: BorderRadius.circular(16), // Rounded Corners
            ),
            child: FloatingActionButton(
              onPressed: _zoomToUserLocation,
              elevation: 0, // No extra shadow
              child: const Icon(
                Icons.my_location,
                color: Color(0xFF4F378B), // Deep Purple Icon
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Function to zoom out
  void _zoomOut() {
    _mapController.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  /// Function to zoom to user location
  void _zoomToUserLocation() {
    if (widget.currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(widget.currentPosition!, 16.0),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User location not available")),
      );
    }
  }
}
