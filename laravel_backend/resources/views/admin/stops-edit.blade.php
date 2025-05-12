/************* ✨ Windsurf Command ⭐ *************/
@extends('layouts.admin')

@section('title', 'Edit Stop')

@section('content')
    <form action="{{ route('admin.stops.update', $stop->id) }}" method="POST">
        @csrf
        @method('PUT')

        <div class="mb-4">
            <label for="name" class="block text-gray-700 text-sm font-bold mb-2">Name</label>
            <input type="text" name="name" id="name" value="{{ $stop->name }}"
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline">
        </div>

        <div class="mb-4">
            <label for="longitude" class="block text-gray-700 text-sm font-bold mb-2">Longitude</label>
            <input type="text" name="longitude" id="longitude" value="{{ $stop->longitude }}"
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline">
        </div>

        <div class="mb-4">
            <label for="latitude" class="block text-gray-700 text-sm font-bold mb-2">Latitude</label>
            <input type="text" name="latitude" id="latitude" value="{{ $stop->latitude }}"
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline">
        </div>

        <button type="submit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
            Update
        </button>
    </form>
@endsection
/******* 56ea205c-944c-4463-9246-b8a77237bb05 *******/
