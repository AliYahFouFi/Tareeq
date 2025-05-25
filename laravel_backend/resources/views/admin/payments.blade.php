@extends('layouts.admin')

@section('title')
    <h1 class="text-2xl font-semibold text-gray-900">Payments Management</h1>
@endsection

@section('content')
    <div class="container mx-auto px-4">


        <div class="bg-white rounded shadow overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-100 text-left">
                    <tr>
                        <th class="px-6 py-3 ">
                            Transaction ID</th>

                        <th class="px-6 py-3 ">
                            Amount</th>
                        <th class="px-6 py-3 ">
                            Status</th>
                        <th class="px-6 py-3 ">Date
                        </th>

                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    @forelse ($charges as $charge)
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap">
                                {{ $charge->id }}
                            </td>
                            {{-- <td class="px-6 py-4 whitespace-nowrap">
                                    {{ $charge->customer }}
                                </td> --}}
                            <td class="px-6 py-4 whitespace-nowrap">
                                ${{ number_format($charge->amount / 100, 2) }}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span
                                    class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                        {{ $charge->status === 'succeeded' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800' }}">
                                    {{ ucfirst($charge->status) }}
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                {{ date('Y-m-d H:i', $charge->created) }}
                            </td>
                            {{-- <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                    <a href="#" class="text-indigo-600 hover:text-indigo-900">View Details</a>
                                </td> --}}
                        </tr>
                    @empty
                        <tr>
                            <td class="px-6 py-4" colspan="6">
                                <p class="text-gray-500 text-center">No payment records found.</p>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
    </div>
@endsection
