<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BusStopController;
use App\Http\Controllers\BusRouteController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\TicketController;
use App\Http\Controllers\TwoFactorController;



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
    Route::post('/user/2fa/setup', [TwoFactorController::class, 'enable2FA']);
    Route::post('/user/2fa/verify', [TwoFactorController::class, 'verify2FA']);
});

Route::post('/create-payment-intent', [PaymentController::class, 'createPaymentIntent']);
//
Route::post('/tickets/{Userid}', [TicketController::class, 'generateTicket']);
Route::get('/tickets/{Userid}', [TicketController::class, 'getUserTickets']);
Route::delete('/tickets/{id}', [TicketController::class, 'deleteTicket']);
