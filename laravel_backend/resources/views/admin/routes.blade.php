@extends('layouts.admin')

@section('title', 'Routes Management')

@section('content')
    @if (session('success'))
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
            <span class="block sm:inline">{{ session('success') }}</span>
        </div>
    @endif

    <h1 class="text-2xl font-bold text-blue-600 mb-6">🗺️ Routes Management</h1>

    <!-- Add new route button -->
    <a href="{{ route('admin.routes.create') }}"
        class="bg-blue-600 text-white px-4 py-2 rounded mb-4 inline-block hover:bg-blue-700 transition">
        + Add New Route
    </a>

    <!-- Routes Table -->
    <div class="bg-white rounded shadow overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-100 text-left">
                <tr>
                    <th class="px-4 py-2">Route ID</th>
                    <th class="px-4 py-2">Name</th>
                    <th class="px-4 py-2">Start Point</th>
                    <th class="px-4 py-2">End Point</th>
                    <th class="px-4 py-2">Stops Count</th>
                    <th class="px-4 py-2">Actions</th>
                </tr>
            </thead>
            <tbody class="text-sm divide-y divide-gray-200">
                @foreach ($routesPaginated as $route)
                    <tr>
                        <td class="px-4 py-2">{{ $route['id'] }}</td>
                        <td class="px-4 py-2">{{ $route['name'] }}</td>
                        <td class="px-4 py-2">{{ $route['start_point'] }}</td>
                        <td class="px-4 py-2">{{ $route['end_point'] }}</td>
                        <td class="px-4 py-2">{{ $route['stops_count'] }}</td>
                        <td class="px-4 py-2 space-x-2">
                            <a href="{{ route('admin.routes.edit', $route['id']) }}"
                                class="text-blue-600 hover:underline">Edit</a>
                            <form action="{{ route('admin.routes.destroy', $route['id']) }}" method="POST" class="inline">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="text-red-600 hover:underline"
                                    onclick="return confirm('Are you sure you want to delete this route?')">
                                    Delete
                                </button>
                            </form>
                        </td>
                    </tr>
                @endforeach

                @if (count($routesPaginated) === 0)
                    <tr>
                        <td colspan="6" class="px-4 py-2 text-center text-gray-500">
                            No routes found. Click "Add New Route" to create one.
                        </td>
                    </tr>
                @endif
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="mt-4">
        {{ $routesPaginated->links() }}
    </div>
@endsection
