@extends('layouts.admin')

@section('title', 'Edit Route')

@section('content')
    <div class="max-w-2xl mx-auto">
        <h1 class="text-2xl font-bold text-blue-600 mb-6">Edit Route</h1>

        <form action="{{ route('admin.routes.update', $route->id) }}" method="POST" class="bg-white rounded shadow p-6">
            @csrf
            @method('PUT')

            <div class="mb-4">
                <label for="name" class="block text-gray-700 text-sm font-bold mb-2">Route Name</label>
                <input type="text" name="name" id="name"
                    class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                    required value="{{ old('name', $route->name) }}">
                @error('name')
                    <p class="text-red-500 text-xs italic">{{ $message }}</p>
                @enderror
            </div>

            <div class="mb-4">
                <label class="block text-gray-700 text-sm font-bold mb-2">Select Stops (in order)</label>
                <div class="space-y-2" id="stopsContainer">
                    @foreach ($route->stops as $routeStop)
                        <div class="flex items-center space-x-2">
                            <select name="stops[]" class="shadow border rounded py-2 px-3 text-gray-700 w-full" required>
                                <option value="">Select a stop</option>
                                @foreach ($stops as $stop)
                                    <option value="{{ $stop->id }}" {{ $routeStop->id == $stop->id ? 'selected' : '' }}>
                                        {{ $stop->name }}
                                    </option>
                                @endforeach
                            </select>
                            <button type="button"
                                class="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600 delete-stop"
                                onclick="this.parentElement.remove()">×</button>
                        </div>
                    @endforeach
                </div>
                <button type="button" class="mt-2 bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600"
                    onclick="addStop()">
                    Add Stop
                </button>
                @error('stops')
                    <p class="text-red-500 text-xs italic">{{ $message }}</p>
                @enderror
            </div>

            <div class="flex items-center justify-between">
                <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                    Update Route
                </button>
                <a href="{{ route('admin.routes') }}" class="text-gray-600 hover:underline">
                    Cancel
                </a>
            </div>
        </form>
    </div>

    <script>
        function addStop() {
            const container = document.getElementById('stopsContainer');
            const template = `
                <div class="flex items-center space-x-2">
                    <select name="stops[]" class="shadow border rounded py-2 px-3 text-gray-700 w-full" required>
                        <option value="">Select a stop</option>
                        @foreach ($stops as $stop)
                            <option value="{{ $stop->id }}">{{ $stop->name }}</option>
                        @endforeach
                    </select>
                    <button type="button" class="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600 delete-stop" onclick="this.parentElement.remove()">×</button>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', template);
        }
    </script>
@endsection
