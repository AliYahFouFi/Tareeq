@extends('layouts.admin')

@section('title', 'Edit Bus')

@section('content')
    <div class="max-w-2xl mx-auto">
        <h1 class="text-2xl font-bold text-blue-600 mb-6">Edit Bus</h1>
        <form action="{{ route('admin.buses.update', $bus['id']) }}" method="POST" class="bg-white rounded shadow p-6">
            @csrf
            @method('PUT')
            <div class="mb-4">
                <label for="registered_number" class="block text-gray-700 text-sm font-bold mb-2">Bus Registration
                    Number</label>
                <input type="text" name="registered_number" id="registered_number"
                    class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                    required value="{{ old('registered_number', $bus['registered_number']) }}">
                @error('registered_number')
                    <p class="text-red-500 text-xs italic">{{ $message }}</p>
                @enderror
            </div>

            <div class="mb-4">
                <label for="driver_id" class="block text-gray-700 text-sm font-bold mb-2">Driver Name</label>
                <select name="driver_id" id="driver_id"
                    class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline">
                    <option value="">No Driver</option>
                    @foreach ($availableDrivers as $driver)
                        <option value="{{ $driver->id }}"
                            {{ old('driver_id', $bus['driver_id']) == $driver->id ? 'selected' : '' }}>
                            {{ $driver->name }}
                        </option>
                    @endforeach
                </select>
                @error('driver_id')
                    <p class="text-red-500 text-xs italic">{{ $message }}</p>
                @enderror
            </div>

            <div class="mb-4">
                <label for="routeName" class="block text-gray-700 text-sm font-bold mb-2">Route Name</label>
                <input type="text" name="routeName" id="routeName"
                    class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                    required value="{{ old('routeName', $bus['routeName']) }}">
                @error('routeName')
                    <p class="text-red-500 text-xs italic">{{ $message }}</p>
                @enderror
            </div>

            <div class="mb-4">
                <label class="block text-gray-700 text-sm font-bold mb-2">Status</label>
                <div class="mt-2">
                    <label class="inline-flex items-center">
                        <input type="radio" class="form-radio" name="active" value="1"
                            {{ old('active', $bus['active']) ? 'checked' : '' }}>
                        <span class="ml-2">Active</span>
                    </label>
                    <label class="inline-flex items-center ml-6">
                        <input type="radio" class="form-radio" name="active" value="0"
                            {{ old('active', $bus['active']) ? '' : 'checked' }}>
                        <span class="ml-2">Inactive</span>
                    </label>
                </div>
                @error('active')
                    <p class="text-red-500 text-xs italic">{{ $message }}</p>
                @enderror
            </div>

            <div class="flex items-center justify-between">
                <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                    Update Bus
                </button>
                <a href="{{ route('admin.buses.index') }}" class="text-gray-600 hover:underline">
                    Cancel
                </a>
            </div>
        </form>
    </div>
@endsection
