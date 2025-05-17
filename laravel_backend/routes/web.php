<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BusStopController;
use App\Http\Controllers\BusRouteController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\TestFirestoreController;
use App\Http\Controllers\BusController;
use App\Http\Controllers\DriverController;

require __DIR__ . '/auth.php';

Route::get('/', function () {
    return view('welcome');
});




// Admin Dashboard Group
Route::prefix('admin')->name('admin.')->middleware(['auth'])->group(function () {
    // Dashboard
    Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('dashboard');

    // Route Management
    Route::get('/routes', [BusRouteController::class, 'index'])->name('routes');
    Route::get('/routes/create', [BusRouteController::class, 'create'])->name('routes.create');
    Route::post('/routes', [BusRouteController::class, 'store'])->name('routes.store');
    Route::get('/routes/{id}/edit', [BusRouteController::class, 'edit'])->name('routes.edit');
    Route::put('/routes/{id}', [BusRouteController::class, 'update'])->name('routes.update');
    Route::delete('/routes/{id}', [BusRouteController::class, 'destroy'])->name('routes.destroy');

    // Stop Management
    Route::get('/stops', [BusStopController::class, 'index'])->name('stops');
    Route::get('/stops/create', [BusStopController::class, 'create'])->name('stops.create');
    Route::post('/stops', [BusStopController::class, 'store'])->name('stops.store');
    Route::get('/stops/{id}/edit', [BusStopController::class, 'edit'])->name('stops.edit');
    Route::put('/stops/{id}', [BusStopController::class, 'update'])->name('stops.update');
    Route::delete('/stops/{id}', [BusStopController::class, 'destroy'])->name('stops.destroy');

    // User Management
    Route::get('/users', [UserController::class, 'index'])->name('users');
    Route::get('/users/create', [UserController::class, 'create'])->name('users.create');
    Route::post('/users', [UserController::class, 'store'])->name('users.store');
    Route::get('/users/{id}/edit', [UserController::class, 'edit'])->name('users.edit');
    Route::put('/users/{id}', [UserController::class, 'update'])->name('users.update');
    Route::delete('/users/{id}', [UserController::class, 'destroy'])->name('users.destroy');

    // Driver Management
    Route::get('/drivers', [DriverController::class, 'index'])->name('drivers.index');
    Route::get('/drivers/create', [DriverController::class, 'create'])->name('drivers.create');
    Route::post('/drivers', [DriverController::class, 'store'])->name('drivers.store');
    Route::get('/drivers/{id}/edit', [DriverController::class, 'edit'])->name('drivers.edit');
    Route::put('/drivers/{id}', [DriverController::class, 'update'])->name('drivers.update');
    Route::delete('/drivers/{id}', [DriverController::class, 'destroy'])->name('drivers.destroy');

    // Bus Management
    Route::get('/buses', [BusController::class, 'index'])->name('buses.index');
    Route::get('/buses/create', [BusController::class, 'create'])->name('buses.create');
    Route::post('/buses', [BusController::class, 'store'])->name('buses.store');
    Route::get('/buses/{id}/edit', [BusController::class, 'edit'])->name('buses.edit');
    Route::put('/buses/{id}', [BusController::class, 'update'])->name('buses.update');
    Route::delete('/buses/{id}', [BusController::class, 'destroy'])->name('buses.destroy');



    // Other admin routes

    Route::view('/payments', 'admin.payments')->name('payments');
});



//firestore test
Route::get('/firestore', [TestFirestoreController::class, 'index']);
Route::post('/firestore', [TestFirestoreController::class, 'store']);
