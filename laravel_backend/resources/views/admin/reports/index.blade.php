@extends('layouts.admin')

@section('title', 'Reports by Bus ID')

@section('content')
    <div class="max-w-6xl mx-auto px-4 py-6">
        <h1 class="text-2xl font-bold text-blue-600 mb-6">Reports by Bus ID</h1>

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

        @forelse ($reports as $busId => $group)
            <div class="mb-8 bg-white rounded-lg shadow p-6">
                <h2 class="text-lg font-semibold text-gray-800 mb-4">🚌 Bus ID: {{ $busId }}</h2>
                <div class="space-y-4">
                    @foreach ($group as $report)
                        <div class="border rounded p-4 bg-gray-50">
                            <div class="flex justify-between">
                                <div>
                                    <p><span class="font-semibold text-gray-700">Issue Type:</span>
                                        {{ $report->issue_type }}</p>
                                    <p><span class="font-semibold text-gray-700">Description:</span>
                                        {{ $report->description }}</p>
                                    @if ($report->image_path)
                                        <img src="{{ asset($report->image_path) }}" alt="Report Image"
                                            class="mt-2 w-40 h-auto rounded shadow">
                                    @endif
                                    <p class="text-sm text-gray-500 mt-2">🕒
                                        {{ \Carbon\Carbon::parse($report->created_at)->format('Y-m-d H:i') }}</p>
                                </div>
                                <div>
                                    <form action="{{ route('admin.reports.destroy', $report->id) }}" method="POST"
                                        onsubmit="return confirm('Are you sure you want to delete this report?');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="text-red-500 hover:text-red-700">
                                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none"
                                                viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                            </svg>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        @empty
            <p class="text-gray-500">No reports available.</p>
        @endforelse
    </div>
@endsection
