<?php

namespace App\Http\Controllers;

use App\Models\BusRoute;
use App\Models\BusStop;
use App\Models\User;
use App\Models\Ticket;
use Illuminate\Http\Request;
use Carbon\Carbon;

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
        // Collect recent activities from various models
        $activities = collect();

        // Add recent routes
        $recentRoutes = BusRoute::latest()->take(3)->get()->map(function ($route) {
            return (object)[
                'action' => 'Route Added',
                'description' => "New route '{$route->name}' was created",
                'created_at' => $route->created_at
            ];
        });
        $activities = $activities->concat($recentRoutes);

        // Add recent stops
        $recentStops = BusStop::latest()->take(3)->get()->map(function ($stop) {
            return (object)[
                'action' => 'Stop Added',
                'description' => "New stop '{$stop->name}' was created",
                'created_at' => $stop->created_at
            ];
        });
        $activities = $activities->concat($recentStops);

        // Sort by created_at and take the 5 most recent activities
        return $activities->sortByDesc('created_at')->take(5);
    }
}
