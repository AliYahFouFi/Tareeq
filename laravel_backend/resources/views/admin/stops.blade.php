@extends('layouts.admin')

@section('title', 'Bus Stops Management')

@section('content')
    @if (session('success'))
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
            <span class="block sm:inline">{{ session('success') }}</span>
        </div>
    @endif

    @if (session('error'))
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
            <span class="block sm:inline">{{ session('error') }}</span>
        </div>
    @endif

    <h1 class="text-2xl font-bold text-blue-600 mb-6">🚏 Bus Stops Management</h1>

    <!-- Add new stop button -->
    <a href="{{ route('admin.stops.create') }}"
        class="bg-blue-600 text-white px-4 py-2 rounded mb-4 inline-block hover:bg-blue-700 transition">
        + Add New Stop
    </a>

    <!-- Stops Table -->
    <div class="bg-white rounded shadow overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-100 text-left">
                <tr>
                    <th class="px-4 py-2">Stop ID</th>
                    <th class="px-4 py-2">Name</th>
                    <th class="px-4 py-2">Address</th>
                    <th class="px-4 py-2">Coordinates</th>
                    <th class="px-4 py-2">Routes Using</th>
                    <th class="px-4 py-2">Actions</th>
                </tr>
            </thead>
            <tbody class="text-sm divide-y divide-gray-200">
                @foreach ($stops as $stop)
                    <tr>
                        <td class="px-4 py-2">{{ $stop->id }}</td>
                        <td class="px-4 py-2">{{ $stop->name }}</td>
                        <td class="px-4 py-2">{{ $stop->address ?: 'N/A' }}</td>
                        <td class="px-4 py-2">
                            {{ number_format($stop->latitude, 6) }}, {{ number_format($stop->longitude, 6) }}
                        </td>
                        <td class="px-4 py-2">{{ $stop->routes_count }}</td>
                        <td class="px-4 py-2 space-x-2">
                            <a href="{{ route('admin.stops.edit', $stop->id) }}"
                                class="text-blue-600 hover:underline">Edit</a>
                            <form action="{{ route('admin.stops.destroy', $stop->id) }}" method="POST" class="inline">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="text-red-600 hover:underline"
                                    onclick="return confirm('Are you sure you want to delete this bus stop?')">
                                    Delete
                                </button>
                            </form>
                        </td>
                    </tr>
                @endforeach

                @if (count($stops) === 0)
                    <tr>
                        <td colspan="6" class="px-4 py-2 text-center text-gray-500">
                            No bus stops found. Click "Add New Stop" to create one.
                        </td>
                    </tr>
                @endif
            </tbody>
        </table>
    </div>
@endsection
