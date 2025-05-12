<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BusStopController;
use App\Http\Controllers\BusRouteController;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/admin/dashboard', function () {
    return view('admin.dashboard');
});


// Admin Dashboard Group
Route::prefix('admin')->name('admin.')->group(function () {
    // Route Management
    Route::get('/routes', [BusRouteController::class, 'index'])->name('routes');
    Route::get('/routes/create', [BusRouteController::class, 'create'])->name('routes.create');
    Route::post('/routes', [BusRouteController::class, 'store'])->name('routes.store');
    Route::get('/routes/{id}/edit', [BusRouteController::class, 'edit'])->name('routes.edit');
    Route::put('/routes/{id}', [BusRouteController::class, 'update'])->name('routes.update');
    Route::delete('/routes/{id}', [BusRouteController::class, 'destroy'])->name('routes.destroy');

    Route::get('/stops', [BusStopController::class, 'index'])->name('stops');
    Route::get('/stops/create', [BusStopController::class, 'create'])->name('stops.create');
    Route::post('/stops', [BusStopController::class, 'store'])->name('stops.store');
    Route::get('/stops/{id}/edit', [BusStopController::class, 'edit'])->name('stops.edit');
    Route::put('/stops/{id}', [BusStopController::class, 'update'])->name('stops.update');
    Route::delete('/stops/{id}', [BusStopController::class, 'destroy'])->name('stops.destroy');

    // Other admin routes
    Route::view('/drivers', 'admin.driver')->name('drivers');
    Route::view('/users', 'admin.users')->name('users');
    Route::view('/payments', 'admin.payments')->name('payments');
});
