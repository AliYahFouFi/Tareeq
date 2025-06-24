<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BusStop;
use App\Services\ActivityService;

class BusStopController extends Controller
{
    protected $activityService;

    public function __construct(ActivityService $activityService)
    {
        $this->activityService = $activityService;
    }

    // API endpoint for mobile app
    public function getAllStops()
    {
        $bus_stops = BusStop::with(['routes'])->get();

        $bus_stops = $bus_stops->map(function ($stop) {
            return [
                'id' => $stop->id,
                'name' => $stop->name,
                'address' => $stop->address,
                'latitude' => $stop->latitude,
                'longitude' => $stop->longitude,
                'route' => $stop->routess->first()?->name ?? 'Unknown',
            ];
        });

        return response()->json($bus_stops);
    }

    // Admin Panel Methods
    public function index()
    {
        $stops = BusStop::withCount('routes')->paginate(20);
        return view('admin.stops', compact('stops'));
    }

    public function create()
    {
        return view('admin.stops.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'address' => 'nullable|string|max:255',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
        ]);

        $stop = BusStop::create($request->all());

        $this->activityService->log(
            'stop',
            'created',
            "New stop '{$stop->name}' was created",
            $stop->id,
            'BusStop',
            $stop->name
        );

        return redirect()->route('admin.stops')->with('success', 'Bus stop created successfully!');
    }

    public function edit($id)
    {
        $stop = BusStop::findOrFail($id);
        return view('admin.stops.edit', compact('stop'));
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'address' => 'nullable|string|max:255',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
        ]);

        $stop = BusStop::findOrFail($id);
        $stop->update($request->all());

        return redirect()->route('admin.stops')->with('success', 'Bus stop updated successfully!');
    }

    public function destroy($id)
    {
        $stop = BusStop::findOrFail($id);

        // Check if stop is used in any routes
        if ($stop->routes()->exists()) {
            return redirect()->route('admin.stops')
                ->with('error', 'Cannot delete this stop as it is being used in one or more routes. Please remove it from all routes first.');
        }

        $stopName = $stop->name;
        $stop->delete();

        $this->activityService->log(
            'stop',
            'deleted',
            "Stop '{$stopName}' was deleted",
            $id,
            'BusStop',
            $stopName
        );

        return redirect()->route('admin.stops')->with('success', 'Bus stop deleted successfully!');
    }
}
