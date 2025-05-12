@extends('layouts.admin')

@section('title', 'Admin Dashboard')

@section('content')
    <div class="container mx-auto px-4">
        <h1 class="text-3xl font-bold text-blue-600 mb-8">🚌 Tareeq Dashboard</h1>

        <!-- Stats Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <!-- Total Routes -->
            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex items-center">
                    <div class="p-3 rounded-full bg-blue-100 text-blue-600">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"></path>
                        </svg>
                    </div>
                    <div class="ml-4">
                        <h2 class="text-gray-600 text-sm">Total Routes</h2>
                        <p class="text-2xl font-semibold text-gray-700">{{ $routesCount }}</p>
                    </div>
                </div>
            </div>

            <!-- Total Stops -->
            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex items-center">
                    <div class="p-3 rounded-full bg-green-100 text-green-600">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        </svg>
                    </div>
                    <div class="ml-4">
                        <h2 class="text-gray-600 text-sm">Total Stops</h2>
                        <p class="text-2xl font-semibold text-gray-700">{{ $stopsCount }}</p>
                    </div>
                </div>
            </div>

            <!-- Total Users -->
            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex items-center">
                    <div class="p-3 rounded-full bg-purple-100 text-purple-600">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                        </svg>
                    </div>
                    <div class="ml-4">
                        <h2 class="text-gray-600 text-sm">Total Users</h2>
                        <p class="text-2xl font-semibold text-gray-700">{{ $usersCount }}</p>
                    </div>
                </div>
            </div>

            <!-- Total Tickets -->
            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex items-center">
                    <div class="p-3 rounded-full bg-yellow-100 text-yellow-600">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"></path>
                        </svg>
                    </div>
                    <div class="ml-4">
                        <h2 class="text-gray-600 text-sm">Total Tickets</h2>
                        <p class="text-2xl font-semibold text-gray-700">{{ $ticketsCount }}</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Quick Actions</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
            <!-- Routes Management -->
            <a href="{{ route('admin.routes') }}" class="block bg-white rounded-lg shadow hover:shadow-lg transition-shadow duration-200">
                <div class="p-6">
                    <div class="flex items-center">
                        <div class="p-3 rounded-full bg-blue-100 text-blue-600">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <h3 class="text-xl font-semibold text-gray-700">Routes</h3>
                            <p class="text-gray-500">Manage bus routes and stops</p>
                        </div>
                    </div>
                </div>
            </a>

            <!-- Stops Management -->
            <a href="{{ route('admin.stops') }}" class="block bg-white rounded-lg shadow hover:shadow-lg transition-shadow duration-200">
                <div class="p-6">
                    <div class="flex items-center">
                        <div class="p-3 rounded-full bg-green-100 text-green-600">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <h3 class="text-xl font-semibold text-gray-700">Stops</h3>
                            <p class="text-gray-500">Manage bus stop locations</p>
                        </div>
                    </div>
                </div>
            </a>

            <!-- User Management -->
            <a href="{{ route('admin.users') }}" class="block bg-white rounded-lg shadow hover:shadow-lg transition-shadow duration-200">
                <div class="p-6">
                    <div class="flex items-center">
                        <div class="p-3 rounded-full bg-purple-100 text-purple-600">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <h3 class="text-xl font-semibold text-gray-700">Users</h3>
                            <p class="text-gray-500">Manage user accounts</p>
                        </div>
                    </div>
                </div>
            </a>
        </div>

        <!-- Recent Activity -->
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Recent Activity</h2>
        <div class="bg-white rounded-lg shadow overflow-hidden">
            <div class="p-6">
                <table class="min-w-full">
                    <thead>
                        <tr>
                            <th class="text-left text-xs font-medium text-gray-500 uppercase tracking-wider py-3 px-4">Action</th>
                            <th class="text-left text-xs font-medium text-gray-500 uppercase tracking-wider py-3 px-4">Description</th>
                            <th class="text-left text-xs font-medium text-gray-500 uppercase tracking-wider py-3 px-4">Time</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @foreach($recentActivity as $activity)
                            <tr>
                                <td class="py-4 px-4">{{ $activity->action }}</td>
                                <td class="py-4 px-4">{{ $activity->description }}</td>
                                <td class="py-4 px-4">{{ $activity->created_at->diffForHumans() }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>
@endsection
