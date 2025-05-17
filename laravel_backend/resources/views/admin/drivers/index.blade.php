@extends('layouts.admin')

@section('title', 'Drivers Management')

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

    <h1 class="text-2xl font-bold text-blue-600 mb-6">👨‍✈️ Drivers Management</h1>

    <!-- Add new driver button -->
    <a href="{{ route('admin.drivers.create') }}"
        class="bg-blue-600 text-white px-4 py-2 rounded mb-4 inline-block hover:bg-blue-700 transition">
        + Add New Driver
    </a>

    <!-- Drivers Table -->
    <div class="bg-white rounded shadow overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-100 text-left">
                <tr>
                    <th class="px-4 py-2">Driver ID</th>
                    <th class="px-4 py-2">Name</th>
                    <th class="px-4 py-2">Email</th>
                    <th class="px-4 py-2">Assigned Bus</th>
                    <th class="px-4 py-2">Actions</th>
                </tr>
            </thead>
            <tbody class="text-sm divide-y divide-gray-200">
                @foreach ($drivers as $driver)
                    <tr>
                        <td class="px-4 py-2">{{ $driver->id }}</td>
                        <td class="px-4 py-2">{{ $driver->name }}</td>
                        <td class="px-4 py-2">{{ $driver->email }}</td>
                        <td class="px-4 py-2">{{ $driver->busId ?: 'Not Assigned' }}</td>
                        <td class="px-4 py-2 space-x-2">
                            <a href="{{ route('admin.drivers.edit', $driver->id) }}"
                                class="text-blue-600 hover:underline">Edit</a>
                            <form action="{{ route('admin.drivers.destroy', $driver->id) }}" method="POST" class="inline">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="text-red-600 hover:underline"
                                    onclick="return confirm('Are you sure you want to delete this driver?')">
                                    Delete
                                </button>
                            </form>
                        </td>
                    </tr>
                @endforeach

                @if (count($drivers) === 0)
                    <tr>
                        <td colspan="5" class="px-4 py-2 text-center text-gray-500">
                            No drivers found. Click "Add New Driver" to create one.
                        </td>
                    </tr>
                @endif
            </tbody>
        </table>
    </div>
@endsection
