@extends('layouts.admin')

@section('title', 'Add New Bus')

@section('content')
    <div class="max-w-2xl mx-auto">
        <h1 class="text-2xl font-bold text-blue-600 mb-6">Add New Bus</h1>

        <form action="{{ route('admin.buses.store') }}" method="POST" class="bg-white rounded shadow p-6">
            @csrf
            <div class="mb-4">
                <label for="registered_number" class="block text-gray-700 text-sm font-bold mb-2">Bus Registration
                    Number</label>
                <input type="text" name="registered_number" id="registered_number"
                    class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                    required value="{{ old('registered_number') }}">
                @error('registered_number')
                    <p class="text-red-500 text-xs italic">{{ $message }}</p>
                @enderror
            </div>

            <div class="mb-4">
                <label for="routeName" class="block text-gray-700 text-sm font-bold mb-2">Route Name</label>
                <input type="text" name="routeName" id="routeName"
                    class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                    required value="{{ old('routeName') }}">
                @error('routeName')
                    <p class="text-red-500 text-xs italic">{{ $message }}</p>
                @enderror
            </div>

            <div class="grid grid-cols-2 gap-4 mb-4">
                <div>
                    <label for="latitude" class="block text-gray-700 text-sm font-bold mb-2">Latitude</label>
                    <input type="number" step="any" name="latitude" id="latitude"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                        required value="{{ old('latitude') }}">
                    @error('latitude')
                        <p class="text-red-500 text-xs italic">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label for="longitude" class="block text-gray-700 text-sm font-bold mb-2">Longitude</label>
                    <input type="number" step="any" name="longitude" id="longitude"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                        required value="{{ old('longitude') }}">
                    @error('longitude')
                        <p class="text-red-500 text-xs italic">{{ $message }}</p>
                    @enderror
                </div>
            </div>

            <div class="mb-4">
                <label class="block text-gray-700 text-sm font-bold mb-2">Status</label>
                <div class="mt-2">
                    <label class="inline-flex items-center">
                        <input type="radio" class="form-radio" name="active" value="1" checked>
                        <span class="ml-2">Active</span>
                    </label>
                    <label class="inline-flex items-center ml-6">
                        <input type="radio" class="form-radio" name="active" value="0">
                        <span class="ml-2">Inactive</span>
                    </label>
                </div>
                @error('active')
                    <p class="text-red-500 text-xs italic">{{ $message }}</p>
                @enderror
            </div>

            <div class="flex items-center justify-between">
                <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                    Add Bus
                </button>
                <a href="{{ route('admin.buses.index') }}" class="text-gray-600 hover:underline">
                    Cancel
                </a>
            </div>
        </form>
    </div>
@endsection
