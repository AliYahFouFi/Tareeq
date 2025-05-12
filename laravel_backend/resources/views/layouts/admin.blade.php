<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>@yield('title') | Admin Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="flex min-h-screen bg-gray-100">

    <!-- Sidebar -->
    <aside class="w-64 bg-white shadow-lg border-r border-gray-200 p-6 flex flex-col">
        <!-- Logo / Title -->
        <div class="text-2xl font-extrabold text-blue-600 mb-10">
            🚌 Bus Admin
        </div>

        <!-- Navigation -->
        <nav class="flex-1 space-y-2">
            <a href="{{ route('admin.routes') }}"
                class="flex items-center px-4 py-2 rounded-md text-gray-700 hover:bg-blue-50 hover:text-blue-600 transition">
                🗺️ <span class="ml-2">Routes</span>
            </a>



            <a href="{{ route('admin.stops') }}"
                class="flex items-center px-4 py-2 rounded-md text-gray-700 hover:bg-green-50 hover:text-green-600 transition">
                🛑 <span class="ml-2">Stops</span>
            </a>



            <a href="{{ route('admin.drivers') }}"
                class="flex items-center px-4 py-2 rounded-md text-gray-700 hover:bg-purple-50 hover:text-purple-600 transition">
                👨‍✈️ <span class="ml-2">Drivers</span>
            </a>
            <a href="{{ route('admin.users') }}"
                class="flex items-center px-4 py-2 rounded-md text-gray-700 hover:bg-orange-50 hover:text-orange-600 transition">
                👤 <span class="ml-2">Users</span>
            </a>
            <a href="{{ route('admin.payments') }}"
                class="flex items-center px-4 py-2 rounded-md text-gray-700 hover:bg-red-50 hover:text-red-600 transition">
                💳 <span class="ml-2">Payments</span>
            </a>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 p-6">
        <h1 class="text-2xl font-bold mb-6">@yield('title')</h1>
        @yield('content')
    </main>

</body>

</html>
