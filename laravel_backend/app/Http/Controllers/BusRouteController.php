<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BusRoute;

class BusRouteController extends Controller
{


    // Function to retrieves the stops for a specific bus route
    public function getStops($routeId)
    {
        // Fetch the route with its ordered stops
        $route = BusRoute::with(['stops' => function ($query) {
            $query->orderBy('bus_route_stop.order'); // Order by pivot table's "order" column
        }])->find($routeId);

        if (!$route) {
            return response()->json(['error' => 'Route not found'], 404);
        }

        // Format the response
        $formattedStops = $route->stops->map(function ($stop) {
            return [
                'id' => $stop->id,
                'name' => $stop->name,
                'address' => $stop->address,
                'latitude' => $stop->latitude,
                'longitude' => $stop->longitude,
            ];
        });

        return response()->json([
            'route_id' => $route->id,
            'route_name' => $route->name,
            'stops' => $formattedStops,
        ]);
    }
    public function getAllRoutes()
    {
        try {
            // Fetch routes with ordered stops
            $routes = BusRoute::with(['stops' => function ($query) {
                $query->orderByPivot('order')->select('bus_stops.*');
            }])->get();

            // Format response
            $formattedRoutes = $routes->map(function ($route) {
                $formattedStops = $route->stops->map(function ($stop) {
                    return [
                        'id' => $stop->id,
                        'name' => $stop->name,
                        'latitude' => $stop->latitude,
                        'longitude' => $stop->longitude,
                        'order' => $stop->pivot->order, // Include order if needed
                    ];
                });

                return [
                    'route_id' => $route->id,
                    'route_name' => $route->name,
                    'stops' => $formattedStops,
                ];
            });

            return response()->json($formattedRoutes);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Failed to fetch routes',
                'details' => $e->getMessage()
            ], 500);
        }
    }
}
