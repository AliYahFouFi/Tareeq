<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BusStopController;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/bus-stops/create', [BusStopController::class, 'create'])->name('bus_stops.create');
Route::post('/bus-stops/store', [BusStopController::class, 'store'])->name('bus_stops.store');
