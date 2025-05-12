<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BusRoute;
use App\Models\BusStop;

class BusRouteController extends Controller
{
    public function index()
    {
        $routes = BusRoute::with('stops')->get()->map(function ($route) {
            return [
                'id' => $route->id,
                'name' => $route->name,
                'start_point' => $route->stops->first()?->name ?? 'N/A',
                'end_point' => $route->stops->last()?->name ?? 'N/A',
                'stops_count' => $route->stops->count(),
            ];
        });

        return view('admin.routes', compact('routes'));
    }

    public function create()
    {
        $stops = BusStop::all();
        return view('admin.routes.create', compact('stops'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'stops' => 'required|array|min:2',
            'stops.*' => 'exists:bus_stops,id'
        ]);

        $route = BusRoute::create([
            'name' => $request->name
        ]);

        // Attach stops with order
        foreach ($request->stops as $index => $stopId) {
            $route->stops()->attach($stopId, ['order' => $index]);
        }

        return redirect()->route('admin.routes')->with('success', 'Route created successfully!');
    }

    public function edit($id)
    {
        $route = BusRoute::with('stops')->findOrFail($id);
        $stops = BusStop::all();
        return view('admin.routes.edit', compact('route', 'stops'));
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'stops' => 'required|array|min:2',
            'stops.*' => 'exists:bus_stops,id'
        ]);

        $route = BusRoute::findOrFail($id);
        $route->update([
            'name' => $request->name
        ]);

        // Sync stops with order
        $route->stops()->detach();
        foreach ($request->stops as $index => $stopId) {
            $route->stops()->attach($stopId, ['order' => $index]);
        }

        return redirect()->route('admin.routes')->with('success', 'Route updated successfully!');
    }

    public function destroy($id)
    {
        $route = BusRoute::findOrFail($id);
        $route->delete();
        return redirect()->route('admin.routes')->with('success', 'Route deleted successfully!');
    }

    // API methods for mobile app
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
            $routes = BusRoute::with(['stops' => function ($query) {
                $query->orderByPivot('order')->select('bus_stops.*');
            }])->get();

            $formattedRoutes = $routes->map(function ($route) {
                $formattedStops = $route->stops->map(function ($stop) {
                    return [
                        'id' => $stop->id,
                        'name' => $stop->name,
                        'latitude' => $stop->latitude,
                        'longitude' => $stop->longitude,
                        'order' => $stop->pivot->order,
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
