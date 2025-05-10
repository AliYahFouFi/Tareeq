@extends('layouts.admin')

@section('title', 'Routes Management')

@section('content')


    <h1 class="text-2xl font-bold text-red-600 mb-6">💳 Payments</h1>

    <div class="bg-white rounded shadow overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-100 text-left">
                <tr>
                    <th class="px-4 py-2">Transaction ID</th>
                    <th class="px-4 py-2">User</th>
                    <th class="px-4 py-2">Amount</th>
                    <th class="px-4 py-2">Status</th>
                    <th class="px-4 py-2">Date</th>
                </tr>
            </thead>
            <tbody class="text-sm">
                <tr>
                    <td class="px-4 py-2">txn_01</td>
                    <td class="px-4 py-2">Ali Yahfouf</td>
                    <td class="px-4 py-2">$5.00</td>
                    <td class="px-4 py-2">
                        <span class="bg-green-500 text-white px-2 py-1 rounded text-xs">Paid</span>
                    </td>
                    <td class="px-4 py-2">2025-05-01</td>
                </tr>
                {{-- Replace with @foreach ($payments as $payment) --}}
            </tbody>
        </table>
    </div>

@endsection
