<?php

namespace App\Http\Controllers\API;

use App\Models\Report;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Log;

class ReportController extends Controller
{
    public function store(Request $request)
    {

        $validated = $request->validate([
            'bus_id' => 'required|integer',
            'issue_type' => 'required|string',
            'description' => 'nullable|string',
            'image_path' => 'nullable|string',
        ]);

        $report = Report::create($validated);

        return response()->json([
            'message' => 'Report synced successfully.',
            'report' => $report
        ], 201);
    }
}
