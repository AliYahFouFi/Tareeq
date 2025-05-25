<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class Admin
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {

        // Check if the user is authenticated
        if (Auth::check() && Auth::user()->is_admin) {
            // If not authenticated or not an admin, redirect to the login page
            return $next($request);
        }
        Auth::logout();
        abort(403, 'Unauthorized action.');
    }
}
