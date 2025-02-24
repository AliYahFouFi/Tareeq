<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BusRoute;

class BusRouteController extends Controller
{
    function getAllRoutes()
    {
        $routes = BusRoute::all();
        return response()->json($routes);
    }

    //get the routes by order

    // app/Http/Controllers/RouteController.php
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
}
