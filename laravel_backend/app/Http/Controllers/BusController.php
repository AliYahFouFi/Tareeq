<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\FirestoreService; // if you put Firestore logic in a separate service
use Carbon\Carbon;

class BusController extends Controller
{
    protected $firestore;

    public function __construct(FirestoreService $firestore)
    {
        $this->firestore = $firestore;
    }

    public function create()
    {
        return view('admin.buses.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'registered_number' => 'required|string',
            'routeName' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'active' => 'required|in:0,1',  // validate active as string "0" or "1"
        ]);

        $data = [
            'registered_number' => $validated['registered_number'],
            'routeName' => $validated['routeName'],
            'latitude' => (float)$validated['latitude'],
            'longitude' => (float)$validated['longitude'],
            'active' => $validated['active'] === '1',  // cast to boolean true or false
            'last_updated' => now()->toIso8601String(),  // store timestamp as ISO string
            'timestamp' => now()->toIso8601String(),
        ];

        // Pass registered_number as document ID
        $this->firestore->createDocument('busses', $data, $validated['registered_number']);

        return redirect()->route('admin.buses.index')->with('success', 'Bus added successfully!');
    }





    public function index()
    {
        $documents = $this->firestore->getDocuments('busses');

        $busses = [];

        if (isset($documents['documents'])) {
            foreach ($documents['documents'] as $doc) {
                $fields = $doc['fields'];

                $busses[] = [
                    'id' => basename($doc['name']), // Firestore document ID
                    'registered_number' => $fields['registered_number']['stringValue'] ?? '',
                    'routeName' => $fields['routeName']['stringValue'] ?? '',
                    'latitude' => $fields['latitude']['doubleValue'] ?? $fields['latitude']['integerValue'] ?? '',
                    'longitude' => $fields['longitude']['doubleValue'] ?? $fields['longitude']['integerValue'] ?? '',
                    'active' => $fields['active']['booleanValue'] ?? false,
                    'last_updated' => $fields['last_updated']['timestampValue'] ?? '',
                    'timestamp' => $fields['timestamp']['timestampValue'] ?? '',
                    // 'driver' => $fields['driver']['stringValue'] ?? 'N/A', // optional, if you have it
                ];
            }
        }

        return view('admin.buses', compact('busses'));
    }
}
