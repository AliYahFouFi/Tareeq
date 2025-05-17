<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use App\Services\FirestoreService; // if you put Firestore logic in a separate service
use App\Services\ActivityService;
use Carbon\Carbon;

class BusController extends Controller
{
    protected $firestore;
    protected $activityService;

    public function __construct(FirestoreService $firestore, ActivityService $activityService)
    {
        $this->firestore = $firestore;
        $this->activityService = $activityService;
    }

    public function create()
    {
        // Logic to show the form for creating a new bus

        $drivers = User::where('role', 'driver')->whereNull('busId')->get();
        return view('admin.buses.create', compact('drivers'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'registered_number' => 'required|string|unique:firebase.busses',
            'routeName' => 'required|string',
            'active' => 'required|in:0,1',
        ]);

        $data = [
            'registered_number' => $validated['registered_number'],
            'routeName' => $validated['routeName'],
            'latitude' => 33.89643959497829,
            'longitude' => 35.56445115023338,
            'active' => $validated['active'] === '1',
            'last_updated' => now()->toIso8601String(),
            'timestamp' => now()->toIso8601String(),
        ];

        // Pass registered_number as document ID
        $this->firestore->createDocument('busses', $data, $validated['registered_number']);

        $this->activityService->log(
            'bus',
            'created',
            "New bus '{$validated['registered_number']}' was created",
            $validated['registered_number'],
            'Bus',
            $validated['registered_number']
        );

        return redirect()->route('admin.buses.index')->with('success', 'Bus added successfully!');
    }





    public function index()
    {
        $documents = $this->firestore->getDocuments('busses');

        $busses = [];

        if (isset($documents['documents'])) {
            foreach ($documents['documents'] as $doc) {
                $fields = $doc['fields'];

                $busId = basename($doc['name']);
                $driver = User::where('busId', $busId)->first();

                $busses[] = [
                    'id' => $busId,
                    'registered_number' => $fields['registered_number']['stringValue'] ?? '',
                    'routeName' => $fields['routeName']['stringValue'] ?? '',
                    'latitude' => $fields['latitude']['doubleValue'] ?? $fields['latitude']['integerValue'] ?? '',
                    'longitude' => $fields['longitude']['doubleValue'] ?? $fields['longitude']['integerValue'] ?? '',
                    'active' => $fields['active']['booleanValue'] ?? false,
                    'last_updated' => $fields['last_updated']['timestampValue'] ?? '',
                    'timestamp' => $fields['timestamp']['timestampValue'] ?? '',
                    'driver_name' => $driver ? $driver->name : 'No Driver',
                ];
            }
        }

        return view('admin.buses', compact('busses'));
    }

    public function edit($id)
    {
        $document = $this->firestore->getDocument('busses', $id);
        if (!$document) {
            return redirect()->route('admin.buses.index')->with('error', 'Bus not found');
        }

        $fields = $document['fields'];
        // Get current driver and all available drivers
        $currentDriver = User::where('busId', $id)->first();
        $availableDrivers = User::where('role', 'driver')
            ->where(function ($query) use ($id) {
                $query->whereNull('busId')
                    ->orWhere('busId', $id); // Include current driver
            })
            ->get();

        $bus = [
            'id' => $id,
            'registered_number' => $fields['registered_number']['stringValue'] ?? '',
            'routeName' => $fields['routeName']['stringValue'] ?? '',
            'active' => $fields['active']['booleanValue'] ?? false,
            'driver_id' => $currentDriver ? $currentDriver->id : null,
            'driver_name' => $currentDriver ? $currentDriver->name : 'No Driver',
        ];

        return view('admin.buses.edit', compact('bus', 'availableDrivers'));
    }

    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'registered_number' => 'required|string',
            'routeName' => 'required|string',
            'active' => 'required|in:0,1',
            'driver_id' => 'nullable|exists:users,id',
        ]);

        $data = [
            'registered_number' => $validated['registered_number'],
            'routeName' => $validated['routeName'],
            'active' => $validated['active'] === '1',
            'latitude' => 33.89643959497829,
            'longitude' => 35.56445115023338,
            'last_updated' => now()->toIso8601String(),

        ];

        // Update bus in Firestore
        $this->firestore->updateDocument('busses', $id, $data);

        // Update driver assignments in database
        User::where('busId', $id)->update(['busId' => null]); // Remove old assignment
        if ($validated['driver_id']) {
            User::where('id', $validated['driver_id'])->update(['busId' => $id]); // Assign new driver
        }

        return redirect()->route('admin.buses.index')->with('success', 'Bus updated successfully');
    }

    public function destroy($id)
    {
        // Get bus details before deletion for activity logging
        $busDoc = $this->firestore->getDocument('busses', $id);
        $busNumber = isset($busDoc['fields']['registered_number']['stringValue'])
            ? $busDoc['fields']['registered_number']['stringValue']
            : $id;

        $this->firestore->deleteDocument('busses', $id);

        $this->activityService->log(
            'bus',
            'deleted',
            "Bus '{$busNumber}' was deleted",
            $id,
            'Bus',
            $busNumber
        );

        return redirect()->route('admin.buses.index')->with('success', 'Bus deleted successfully!');
    }
}
