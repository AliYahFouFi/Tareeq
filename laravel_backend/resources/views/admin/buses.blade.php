@extends('layouts.admin')

@section('title', 'Buses Management')

@section('content')

    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
        <h1 class="text-2xl font-bold text-blue-600">🚌 Buses Management</h1>
        <a href="{{ route('admin.buses.create') }}" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">+ Add
            New Bus</a>
    </div>

    <!-- Search -->
    <div class="mb-4">
        <input type="text" placeholder="Search by name or ID..."
            class="w-full md:w-1/3 px-4 py-2 border rounded shadow-sm focus:outline-none focus:ring focus:border-blue-300">
    </div>

    <!-- Table -->
    <div class="overflow-x-auto bg-white rounded shadow">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-100 text-left">
                <tr>
                    <th class="px-4 py-3">Bus ID</th>
                    <th class="px-4 py-3 ">Name</th>
                    <th class="px-4 py-3 ">Status</th>
                    <th class="px-4 py-3 ">Current Location</th>
                    <th class="px-4 py-3 ">Driver</th>
                    <th class="px-4 py-3 ">Route</th>
                    <th class="px-4 py-3 ">Last Updated</th>
                    <th class="px-4 py-3 ">Actions</th>
                </tr>
            </thead>



            <tbody class="divide-y divide-gray-100 text-sm">
                @foreach ($busses as $bus)
                    <tr>
                        <td class="px-4 py-3 font-mono text-xs">{{ $bus['id'] }}</td>
                        <td class="px-4 py-3">{{ $bus['registered_number'] }}</td>
                        <td class="px-4 py-3">
                            @if ($bus['active'])
                                <span
                                    class="inline-block px-2 py-1 text-xs text-white bg-green-500 rounded-full">Active</span>
                            @else
                                <span
                                    class="inline-block px-2 py-1 text-xs text-white bg-red-500 rounded-full">Inactive</span>
                            @endif
                        </td>
                        <td class="px-4 py-3 text-xs">{{ $bus['latitude'] }}, {{ $bus['longitude'] }}</td>
                        <td class="px-4 py-3">{{ $bus['driver_name'] }}</td>
                        <td class="px-4 py-3">{{ $bus['routeName'] }}</td>
                        <td class="px-4 py-3 text-xs text-gray-500">
                            {{ \Carbon\Carbon::parse($bus['last_updated'])->diffForHumans() }}</td>
                        <td class="px-4 py-3 space-x-2">
                            <a href="{{ route('admin.buses.edit', $bus['id']) }}"
                                class="text-blue-600 hover:underline text-sm">Edit</a>
                            <form action="{{ route('admin.buses.destroy', $bus['id']) }}" method="POST"
                                class="inline-block"
                                onsubmit="return confirm('Are you sure you want to delete this bus?');">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="text-red-600 hover:underline text-sm">Delete</button>
                            </form>
                        </td>
                    </tr>
                @endforeach
            </tbody>




        </table>
    </div>
    </div>
@endsection
