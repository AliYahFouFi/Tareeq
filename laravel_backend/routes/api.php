<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BusStopController;
use App\Http\Controllers\BusRouteController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

//get all the bus stops
Route::get('/bus-stop', [BusStopController::class, 'getAllStops']);

//get all the bus routes
Route::get('/bus-route', [BusRouteController::class, 'getAllRoutes']);

// Fetch stops for a specific route
Route::get('/routes/{routeId}/stops', [BusRouteController::class, 'getStops']);
