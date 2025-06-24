<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class DriverController extends Controller
{


    public function index()
    {
        // Logic to fetch and display drivers

        $drivers = User::where('role', 'driver')->get();
        return view('admin.drivers.index', compact('drivers'));
    }

    public function create()
    {
        // Logic to show the form for creating a new driver
        return view('admin.drivers.create');
    }

    public function store(Request $request)
    {
        // Logic to store a new driver
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8',
            'busId' => 'nullable|string',
        ]);

        // Store the driver in the database

        User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => bcrypt($validated['password']),
            'role' => 'driver',
            'busId' => null,
        ]);

        return redirect()->route('admin.drivers.index')->with('success', 'Driver created successfully!');
    }

    public function edit($id)
    {
        // Logic to show the form for editing a driver
        $driver = User::findOrFail($id);

        return view('admin.drivers.edit', compact('driver'));
    }

    public function update(Request $request, $id)
    {
        // Logic to update a driver
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $id,
            'password' => 'nullable|min:8',
            'busId' => 'nullable|string',
        ]);

        // Update the driver in the database
        // ...
        $driver = User::findOrFail($id);
        $driver->name = $validated['name'];
        $driver->email = $validated['email'];
        if ($validated['password']) {
            $driver->password = bcrypt($validated['password']);
        }
        $driver->busId = $validated['busId'];
        $driver->save();
        // Update the driver in the database
        return redirect()->route('admin.drivers.index')->with('success', 'Driver updated successfully!');
    }

    public function destroy($id)
    {
        // Logic to delete a driver
        $driver = User::findOrFail($id);
        $driver->delete();

        return redirect()->route('admin.drivers.index')->with('success', 'Driver deleted successfully!');
    }
}
