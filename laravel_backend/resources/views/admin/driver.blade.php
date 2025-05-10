@extends('layouts.admin')

@section('title', 'Routes Management')

@section('content')


    <body class="bg-gray-100 p-6">

        <h1 class="text-2xl font-bold text-purple-600 mb-6">👨‍✈️ Drivers Management</h1>

        <a href="#" class="bg-purple-600 text-white px-4 py-2 rounded mb-4 inline-block">+ Add Driver</a>

        <div class="bg-white rounded shadow overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-100 text-left">
                    <tr>
                        <th class="px-4 py-2">Driver ID</th>
                        <th class="px-4 py-2">Name</th>
                        <th class="px-4 py-2">Phone</th>
                        <th class="px-4 py-2">Assigned Bus</th>
                        <th class="px-4 py-2">Actions</th>
                    </tr>
                </thead>
                <tbody class="text-sm">
                    <tr>
                        <td class="px-4 py-2">drv_01</td>
                        <td class="px-4 py-2">Ali Yahfouf</td>
                        <td class="px-4 py-2">+961 70 000 000</td>
                        <td class="px-4 py-2">Bus A</td>
                        <td class="px-4 py-2 space-x-2">
                            <a href="#" class="text-blue-600">Edit</a>
                            <a href="#" class="text-red-600">Delete</a>
                        </td>
                    </tr>
                    {{-- Replace with @foreach ($drivers as $driver) --}}
                </tbody>
            </table>
        </div>

    @endsection
