<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BusStopController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
Route::get('/check-api', function () {
    return response()->json(['message' => 'API is working!']);
});

Route::get('/bus-stop', [BusStopController::class, 'index']);
