<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BusStopController;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/bus-stops/create', [BusStopController::class, 'create'])->name('bus_stops.create');
Route::post('/bus-stops/store', [BusStopController::class, 'store'])->name('bus_stops.store');


Route::get('/admin/dashboard', function () {
    return view('admin.dashboard');
});
// Route::get('/admin/busses', function () {
//     return view('admin.busses');
// });

// Route::get('/admin/users', function () {
//     return view('admin.users');
// });

// Route::get('/admin/driver', function () {
//     return view('admin.driver');
// });

// Route::get('/admin/payments', function () {
//     return view('admin.payments');
// });

// Route::get('/admin/stops', function () {
//     return view('admin.stops');
// });
// Route::get('/admin/routes', function () {
//     return view('admin.routes');
// });


// Admin Dashboard Group
Route::prefix('admin')->name('admin.')->group(function () {
    Route::view('/routes', 'admin.routes')->name('routes');
    Route::view('/stops', 'admin.stops')->name('stops');
    Route::view('/drivers', 'admin.driver')->name('drivers');
    Route::view('/users', 'admin.users')->name('users');
    Route::view('/payments', 'admin.payments')->name('payments');
});

// Bus Stop Routes
Route::get('admin/stops', [BusStopController::class, 'showAllStops'])->name('admin-stops.index');
Route::delete('admin/stops/{id}', [BusStopController::class, 'destroy'])->name('admin-stops.destroy');
Route::get('admin/stops/{id}/edit', [BusStopController::class, 'edit'])->name('admin-stops.edit');
Route::put('admin/stops/{id}', [BusStopController::class, 'update'])->name('admin-stops.update');
Route::get('admin/stops/create', [BusStopController::class, 'create'])->name('admin-stops.create');
Route::post('admin/stops', [BusStopController::class, 'store'])->name('admin-stops.store');
