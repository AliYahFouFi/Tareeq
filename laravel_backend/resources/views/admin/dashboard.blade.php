<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100 text-gray-800 font-sans">

    <div class="flex h-screen overflow-hidden">

        <!-- Sidebar -->
        <aside class="w-64 bg-white shadow-md">
            <div class="p-4 text-2xl font-bold text-blue-600 border-b border-gray-200">
                🚌 Bus Admin
            </div>
            <nav class="mt-4">
                <ul class="space-y-2 px-4">
                    <li><a href="#" class="block px-3 py-2 rounded hover:bg-blue-100">Dashboard</a></li>
                    <li><a href="#" class="block px-3 py-2 rounded hover:bg-blue-100">Buses</a></li>
                    <li><a href="#" class="block px-3 py-2 rounded hover:bg-blue-100">Routes</a></li>
                    <li><a href="#" class="block px-3 py-2 rounded hover:bg-blue-100">Stops</a></li>
                    <li><a href="#" class="block px-3 py-2 rounded hover:bg-blue-100">Drivers</a></li>
                    <li><a href="#" class="block px-3 py-2 rounded hover:bg-blue-100">Users</a></li>
                    <li><a href="#" class="block px-3 py-2 rounded hover:bg-blue-100">Payments</a></li>
                    <li><a href="#" class="block px-3 py-2 text-red-600 rounded hover:bg-red-100">Logout</a></li>
                </ul>
            </nav>
        </aside>

        <!-- Main Content -->
        <div class="flex-1 flex flex-col">

            <!-- Navbar -->
            <header class="bg-white shadow p-4 flex justify-between items-center">
                <h1 class="text-xl font-semibold">Dashboard</h1>
                <span class="text-sm text-gray-500">Welcome, Admin</span>
            </header>

            <!-- Content -->
            <main class="flex-1 overflow-y-auto p-6 space-y-6">

                <!-- Stat Cards -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div class="bg-white shadow-md rounded-lg p-4">
                        <h2 class="text-gray-600 text-sm">Total Buses</h2>
                        <p class="text-2xl font-bold text-blue-500">15</p>
                    </div>
                    <div class="bg-white shadow-md rounded-lg p-4">
                        <h2 class="text-gray-600 text-sm">Active Routes</h2>
                        <p class="text-2xl font-bold text-green-500">7</p>
                    </div>
                    <div class="bg-white shadow-md rounded-lg p-4">
                        <h2 class="text-gray-600 text-sm">Tickets Sold Today</h2>
                        <p class="text-2xl font-bold text-yellow-500">123</p>
                    </div>
                </div>

                <!-- Map or Chart Area -->
                <div class="bg-white shadow-md rounded-lg p-6">
                    <h3 class="text-lg font-semibold mb-4">Live Bus Map (Coming Soon)</h3>
                    <div class="bg-gray-200 h-64 rounded flex items-center justify-center text-gray-500">
                        Map or Chart Placeholder
                    </div>
                </div>

            </main>
        </div>
    </div>

</body>

</html>
