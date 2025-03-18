<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BusStop;

class BusStopController extends Controller
{


    //get all bus stops
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
                'route' => $stop->routess->first()?->name ?? 'Unknown', // Get the first route name
            ];
        });

        return response()->json($bus_stops);
    }


    public function create()
    {
        return view('bus_stops.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'address' => 'nullable|string|max:255',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        BusStop::create($request->all());

        return redirect()->route('bus_stops.create')->with('success', 'Bus Stop added successfully!');
    }
}
