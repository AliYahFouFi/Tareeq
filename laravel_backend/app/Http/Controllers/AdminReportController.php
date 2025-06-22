<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Report;
use Illuminate\Support\Facades\DB;

class AdminReportController extends Controller
{
    
    public function index()
    {
        $reports = DB::table('reports')
            ->orderBy('bus_id')
            ->get()
            ->groupBy('bus_id'); // 👈 grouped by bus_id

        return view('admin.reports.index', compact('reports'));
    }

}
