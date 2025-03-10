<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BusStopController;
use App\Http\Controllers\BusRouteController;
use App\Http\Controllers\AuthController;
use Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful;


Route::get('/', function () {
    return 'API is working';
});

//get all the bus stops
Route::get('/bus-stop', [BusStopController::class, 'getAllStops']);

//get all the bus routes
Route::get('/bus-route', [BusRouteController::class, 'getAllRoutes']);

// Fetch stops for a specific route
Route::get('/routes/{routeId}/stops', [BusRouteController::class, 'getStops']);

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
});
    
