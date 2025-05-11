@extends('layouts.admin')

@section('title', 'Routes Management')

@section('content')


    <h1 class="text-2xl font-bold text-green-600 mb-6">🛑 Stops Management</h1>

    <a href="#" class="bg-green-600 text-white px-4 py-2 rounded mb-4 inline-block">+ Add Stop</a>

    <div class="bg-white rounded shadow overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-100 text-left">
                <tr>
                    <th class="px-4 py-2">Stop ID</th>
                    <th class="px-4 py-2">Name</th>
                    <th class="px-4 py-2">Coordinates</th>
                    <th class="px-4 py-2">Route</th>
                    <th class="px-4 py-2">Actions</th>
                </tr>
            </thead>
            <tbody class="text-sm">
                @foreach ($stops as $stop)
                    <tr>
                        <td class="px-4 py-2">{{ $stop->id }}</td>
                        <td class="px-4 py-2">{{ $stop->name }}</td>
                        <td class="px-4 py-2">{{ $stop->latitude }}, {{ $stop->longitude }}</td>
                        <td class="px-4 py-2">{{ $stop->route->name ?? 'N/A' }}</td>
                        <td class="px-4 py-2 space-x-2">
                            {{-- <a href="{{ route('stops.edit', $stop->id) }}" class="text-blue-600">Edit</a> --}}

                            <form action="{{ route('admin-stops.destroy', $stop->id) }}" method="POST" class="inline">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="text-red-600"
                                    onclick="return confirm('Are you sure?')">Delete</button>
                            </form>
                        </td>
                    </tr>
                @endforeach

            </tbody>
        </table>
    </div>
@endsection
