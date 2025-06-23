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
            ->groupBy('bus_id'); //  grouped by bus_id

        return view('admin.reports.index', compact('reports'));
    }

    /**
     * Delete the specified report from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy($id)
    {
        try {
            $report = Report::findOrFail($id);
            $report->delete();

            return redirect()->route('admin.reports.index')
                ->with('success', 'Report deleted successfully');
        } catch (\Exception $e) {
            return redirect()->route('admin.reports.index')
                ->with('error', 'Failed to delete report: ' . $e->getMessage());
        }
    }
}
