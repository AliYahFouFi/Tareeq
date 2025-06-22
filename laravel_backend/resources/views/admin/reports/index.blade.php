@extends('layouts.admin')

@section('title', 'Reports by Bus ID')

@section('content')
<div class="max-w-6xl mx-auto px-4 py-6">
    <h1 class="text-2xl font-bold text-blue-600 mb-6">Reports by Bus ID</h1>

    @forelse ($reports as $busId => $group)
        <div class="mb-8 bg-white rounded-lg shadow p-6">
            <h2 class="text-lg font-semibold text-gray-800 mb-4">🚌 Bus ID: {{ $busId }}</h2>
            <div class="space-y-4">
                @foreach ($group as $report)
                    <div class="border rounded p-4 bg-gray-50">
                        <p><span class="font-semibold text-gray-700">Issue Type:</span> {{ $report->issue_type }}</p>
                        <p><span class="font-semibold text-gray-700">Description:</span> {{ $report->description }}</p>
                        @if ($report->image_path)
                            <img src="{{ asset($report->image_path) }}" alt="Report Image"
                                class="mt-2 w-40 h-auto rounded shadow">
                        @endif
                        <p class="text-sm text-gray-500 mt-2">🕒 {{ \Carbon\Carbon::parse($report->created_at)->format('Y-m-d H:i') }}</p>
                    </div>
                @endforeach
            </div>
        </div>
    @empty
        <p class="text-gray-500">No reports available.</p>
    @endforelse
</div>
@endsection
