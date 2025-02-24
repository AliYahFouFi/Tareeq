<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BusStop;

class BusStopController extends Controller
{


    //get all bus stops
    public function getAllStops()
    {
        $bus_stops = BusStop::all();
        return response()->json($bus_stops);
    }
}
