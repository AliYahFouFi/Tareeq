<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Buses Management</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100 text-gray-800">

    <div class="p-6 max-w-7xl mx-auto">

        <!-- Header -->
        <div class="flex items-center justify-between mb-6">
            <h1 class="text-2xl font-bold text-blue-600">🚌 Buses Management</h1>
            <a href="#" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">+ Add New Bus</a>
        </div>

        <!-- Search -->
        <div class="mb-4">
            <input type="text" placeholder="Search by name or ID..."
                class="w-full md:w-1/3 px-4 py-2 border rounded shadow-sm focus:outline-none focus:ring focus:border-blue-300">
        </div>

        <!-- Table -->
        <div class="overflow-x-auto bg-white rounded shadow">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-100">
                    <tr>
                        <th class="px-4 py-3 text-left text-sm font-semibold text-gray-600">Bus ID</th>
                        <th class="px-4 py-3 text-left text-sm font-semibold text-gray-600">Name</th>
                        <th class="px-4 py-3 text-left text-sm font-semibold text-gray-600">Status</th>
                        <th class="px-4 py-3 text-left text-sm font-semibold text-gray-600">Current Location</th>
                        <th class="px-4 py-3 text-left text-sm font-semibold text-gray-600">Driver</th>
                        <th class="px-4 py-3 text-left text-sm font-semibold text-gray-600">Route</th>
                        <th class="px-4 py-3 text-left text-sm font-semibold text-gray-600">Last Updated</th>
                        <th class="px-4 py-3 text-left text-sm font-semibold text-gray-600">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 text-sm">
                    <!-- Example Row -->
                    <tr>
                        <td class="px-4 py-3 font-mono text-xs">bus_01</td>
                        <td class="px-4 py-3">Bus A</td>
                        <td class="px-4 py-3">
                            <span
                                class="inline-block px-2 py-1 text-xs text-white bg-green-500 rounded-full">Active</span>
                        </td>
                        <td class="px-4 py-3 text-xs">33.8886, 35.4955</td>
                        <td class="px-4 py-3">Driver Ali</td>
                        <td class="px-4 py-3">Route 1</td>
                        <td class="px-4 py-3 text-xs text-gray-500">5 mins ago</td>
                        <td class="px-4 py-3 space-x-2">
                            <a href="#" class="text-blue-600 hover:underline text-sm">Edit</a>
                            <a href="#" class="text-red-600 hover:underline text-sm">Delete</a>
                        </td>
                    </tr>

                    <!-- Repeat rows with loop -->
                    {{-- @foreach ($buses as $bus) --}}
                    {{-- ... --}}
                    {{-- @endforeach --}}
                </tbody>
            </table>
        </div>

    </div>

</body>

</html>
