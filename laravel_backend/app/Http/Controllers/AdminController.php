<?php

namespace App\Http\Controllers;

use App\Models\BusRoute;
use App\Models\BusStop;
use App\Models\User;
use App\Models\Ticket;
use App\Models\Activity;
use Illuminate\Http\Request;
use Carbon\Carbon;
use App\Services\FirestoreService;

class AdminController extends Controller
{
    public function dashboard()
    {
        try {
            // Get counts for the stats cards
            $data = [
                'routesCount' => BusRoute::count(),
                'stopsCount' => BusStop::count(),
                'usersCount' => User::count() ?? 0,
                'ticketsCount' => Ticket::count() ?? 0,
                'recentActivity' => $this->getRecentActivity()
            ];

            return view('admin.dashboard', $data);
        } catch (\Exception $e) {
            // In case some models don't exist yet, provide default values
            $data = [
                'routesCount' => BusRoute::count(),
                'stopsCount' => BusStop::count(),
                'usersCount' => 0,
                'ticketsCount' => 0,
                'recentActivity' => collect([])
            ];

            return view('admin.dashboard', $data);
        }
    }

    private function getRecentActivity()
    {
        return Activity::latest()
            ->take(10)
            ->get()
            ->map(function ($activity) {
                return (object)[
                    'action' => ucfirst($activity->action),
                    'description' => $activity->description,
                    'created_at' => $activity->created_at,
                    'type' => $activity->type
                ];
            });

        // Sort by created_at and take the 5 most recent activities
        return $activities->sortByDesc('created_at')->take(5);
    }
}
