// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/saved_location_marker.dart';
import 'package:flutter_frontend/components/snackbar_helper.dart';
import 'package:flutter_frontend/models/SavedPlace.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/SavedPlacesProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class BusMap extends StatefulWidget {
  final LatLng? initialZoomPosition;
  final LatLng? currentPosition;
  final List<BusStop> busStops;
  final Function getBusStopMarkers;
  final Function(GoogleMapController) onMapCreated;

  const BusMap({
    Key? key,
    required this.currentPosition,
    required this.busStops,
    required this.getBusStopMarkers,
    required this.onMapCreated,
    this.initialZoomPosition,
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
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Set<Marker> _getSavedLocationMarkers(BuildContext context) {
    if (widget.currentPosition == null) return {};

    final savedPlaces = context.watch<SavedPlacesProvider>().places;
    return savedPlaces.map((place) {
      return buildSavedPlaceMarker(
        context: context,
        place: place,
        mainButtonText: 'Show Route',
        mainButtonIcon: Icons.alt_route,
        currentPosition: widget.currentPosition!,
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target:
                widget.initialZoomPosition ??
                widget.currentPosition ??
                _beirutLocation, // Fallback to default location if no user or saved place
            zoom: 15.0,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            widget.onMapCreated(controller);

            // Only animate to saved place if provided, otherwise to user location
            if (widget.initialZoomPosition != null) {
              Future.delayed(const Duration(milliseconds: 500), () {
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(widget.initialZoomPosition!, 17.0),
                );
              });
            } else if (widget.currentPosition != null) {
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
          onLongPress: _onMapLongPressed,
          mapType: MapType.normal,
          polylines: context.watch<BusRouteProvider>().polylines,
          markers: {
            if (widget.currentPosition != null) ...widget.getBusStopMarkers(),
            ..._getSavedLocationMarkers(context),
          },
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

  void _onMapLongPressed(LatLng position) {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: const Text(
                "Save Location",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Location name",
                    hintText: "e.g., Home, Work, Favorite Cafe",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                Text(
                  " This map location will be added to  saved location",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    _saveNamedLocation(position, name);
                    Navigator.pop(context);
                  } else {
                    CustomSnackBar.showError(
                      context: context,
                      message: "Please enter a name for this location",
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Save Location"),
              ),
            ],
          ),
    );
  }

  Future<void> _saveLocationLocally(LatLng position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('saved_lat', position.latitude);
    await prefs.setDouble('saved_lng', position.longitude);
    CustomSnackBar.showSuccess(
      context: context,
      message: "Location saved locally!",
    );
  }

  Future<void> _saveNamedLocation(LatLng position, String name) async {
    final prefs = await SharedPreferences.getInstance();

    final newEntry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(), // unique ID
      'name': name,
      'lat': position.latitude,
      'lng': position.longitude,
    };

    List<String> savedList = prefs.getStringList('saved_locations') ?? [];
    savedList.add(jsonEncode(newEntry));
    await prefs.setStringList('saved_locations', savedList);

    // Add this to the provider so it updates the UI
    final provider = Provider.of<SavedPlacesProvider>(context, listen: false);
    provider.addPlace(
      SavedPlace(
        id: newEntry['id'] as String,
        name: name,
        lat: position.latitude,
        lng: position.longitude,
      ),
    );

    // Add the marker dynamically
    setState(() {
      _savedLocationMarkers.add(
        Marker(
          markerId: MarkerId(name),
          position: position,
          infoWindow: InfoWindow(title: name),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    });
    CustomSnackBar.showSuccess(
      context: context,
      message: "Location '$name' saved locally!",
    );
  }

  Set<Marker> _savedLocationMarkers = {};

  Future<void> _loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('saved_locations') ?? [];

    Set<Marker> markers = {};
    for (String item in savedList) {
      final decoded = jsonDecode(item);
      final name = decoded['name'];
      final lat = decoded['lat'];
      final lng = decoded['lng'];

      markers.add(
        Marker(
          markerId: MarkerId(name),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    setState(() {
      _savedLocationMarkers = markers;
    });
  }

  //____________________________________________________________________________
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
