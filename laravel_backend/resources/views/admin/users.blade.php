@extends('layouts.admin')

@section('title', 'Routes Management')

@section('content')


    <h1 class="text-2xl font-bold text-orange-600 mb-6">👤 Registered Users</h1>

    <div class="bg-white rounded shadow overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-100 text-left">
                <tr>
                    <th class="px-4 py-2">User ID</th>
                    <th class="px-4 py-2">Name</th>
                    <th class="px-4 py-2">Email</th>
                    <th class="px-4 py-2">Registered At</th>
                    <th class="px-4 py-2">Actions</th>
                </tr>
            </thead>
            <tbody class="text-sm">
                <tr>
                    <td class="px-4 py-2">user_01</td>
                    <td class="px-4 py-2">Zulfikar Yehya</td>
                    <td class="px-4 py-2">zulfikar@example.com</td>
                    <td class="px-4 py-2">2024-09-01</td>
                    <td class="px-4 py-2 space-x-2">
                        <a href="#" class="text-blue-600">Edit</a>
                        <a href="#" class="text-red-600">Delete</a>
                    </td>
                </tr>
                {{-- Replace with @foreach ($users as $user) --}}
            </tbody>
        </table>
    </div>

@endsection
