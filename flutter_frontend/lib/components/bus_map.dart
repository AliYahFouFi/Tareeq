// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/snackbar_helper.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:provider/provider.dart';

class BusMap extends StatefulWidget {
  final LatLng? currentPosition;
  final List<BusStop> busStops;
  final Set<Marker> Function() getBusStopMarkers;
  final Function(GoogleMapController) onMapCreated;

  const BusMap({
    Key? key,
    required this.currentPosition,
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
  final double _buttonSize = 50.0;
  final double _buttonSpacing = 10.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target:
                context.watch<UserLocationProvider>().getUserLocation() ??
                _beirutLocation,
            zoom: 15,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            widget.onMapCreated(controller);
            if (widget.currentPosition != null) {
              Future.delayed(const Duration(milliseconds: 500), () {
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(widget.currentPosition!, 16.0),
                );
              });
            }
          },
          myLocationEnabled: true,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          mapType: MapType.normal,
          polylines: context.watch<BusRouteProvider>().polylines,
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

        // Zoom Controls (Top Right)
        Positioned(
          top: _buttonSpacing,
          right: _buttonSpacing,
          child: Column(
            children: [
              _buildMapControlButton(
                icon: Icons.add,
                onPressed: _zoomIn,
                tooltip: 'Zoom in',
              ),
              SizedBox(height: _buttonSpacing),
              _buildMapControlButton(
                icon: Icons.remove,
                onPressed: _zoomOut,
                tooltip: 'Zoom out',
              ),
            ],
          ),
        ),

        // My Location Button (Bottom Right)
        Positioned(
          bottom: _buttonSpacing,
          right: _buttonSpacing,
          child: _buildMapControlButton(
            icon: Icons.my_location,
            onPressed: _zoomToUserLocation,
            tooltip: 'My location',
          ),
        ),
      ],
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: _buttonSize,
        height: _buttonSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: Icon(icon, color: Colors.deepPurple, size: 20),
          ),
        ),
      ),
    );
  }

  void _zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }

  void _zoomToUserLocation() {
    if (widget.currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(widget.currentPosition!, 16.0),
      );
    } else {
      CustomSnackBar.showError(
        context: context,
        message: "No user location found",
      );
    }
  }
}
