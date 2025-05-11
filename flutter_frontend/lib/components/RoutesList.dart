import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/BusRoute_model.dart';

import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/BusStopsProvider.dart';
import 'package:flutter_frontend/util/BusStop_service.dart';
import 'package:flutter_frontend/util/polyline_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

Future<List<Map<String, dynamic>>> getBusRoutesWithFirstAndLastStop() async {
  List<BusRoute> busRoutes = await fetchAllBusRoutes();

  return busRoutes.map((route) {
    List<Stop> stops = route.stops;
    return {
      "route_id": route.route_id,
      "route_name": route.route_name,
      "first_stop": stops.isNotEmpty ? stops.first.name : "Unknown",
      "last_stop": stops.length > 1 ? stops.last.name : stops.first.name,
    };
  }).toList();
}

void showBusRoutesBottomSheet(BuildContext context) async {
  List<Map<String, dynamic>> busRoutes =
      await getBusRoutesWithFirstAndLastStop();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Available Bus Routes",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Route list
            Expanded(
              child: ListView.separated(
                itemCount: busRoutes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  var route = busRoutes[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      Navigator.pop(context);
                      String routeId = route['route_id'].toString();
                      context.read<BusStopsProvider>().setBusStops(
                        await BusStopService.getBusStopsForOneRoute(routeId),
                      );
                      Set<Polyline> polylineForOneRoute =
                          await generatePolylineForOneRoute(routeId);
                      context.read<BusRouteProvider>().polylines =
                          polylineForOneRoute;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.directions_bus,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  route['route_name'].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${route['first_stop']} → ${route['last_stop']}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
