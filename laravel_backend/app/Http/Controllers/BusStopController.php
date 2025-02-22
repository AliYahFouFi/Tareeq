<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Bus_Stop;

class BusStopController extends Controller
{


    //get all bus stops
    public function index()
    {
        $bus_stops = Bus_Stop::all();
        return response()->json($bus_stops);
    }
}
