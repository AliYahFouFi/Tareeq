@extends('layouts.admin')

@section('title', 'Routes Management')

@section('content')



    <h1 class="text-2xl font-bold text-blue-600 mb-6">🗺️ Routes Management</h1>

    <!-- Add new route button -->
    <a href="#" class="bg-blue-600 text-white px-4 py-2 rounded mb-4 inline-block">+ Add New Route</a>

    <!-- Routes Table -->
    <div class="bg-white rounded shadow overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-100 text-left">
                <tr>
                    <th class="px-4 py-2">Route ID</th>
                    <th class="px-4 py-2">Start Point</th>
                    <th class="px-4 py-2">End Point</th>
                    <th class="px-4 py-2">Stops Count</th>
                    <th class="px-4 py-2">Actions</th>
                </tr>
            </thead>
            <tbody class="text-sm">
                <!-- Sample row -->
                <tr>
                    <td class="px-4 py-2">route_01</td>
                    <td class="px-4 py-2">Beirut</td>
                    <td class="px-4 py-2">Tripoli</td>
                    <td class="px-4 py-2">10</td>
                    <td class="px-4 py-2 space-x-2">
                        <a href="#" class="text-blue-600 hover:underline">Edit</a>
                        <a href="#" class="text-red-600 hover:underline">Delete</a>
                    </td>
                </tr>
                {{-- Loop over routes from your database --}}
            </tbody>
        </table>
    </div>

@endsection
