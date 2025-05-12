<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title') | Tareeq Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
    <div class="min-h-screen flex">
        <!-- Sidebar -->
        <div class="bg-white w-64 min-h-screen flex flex-col shadow-lg">
            <!-- Logo -->
            <div class="p-4 bg-blue-600">
                <div class="flex items-center">
                    <span class="text-white text-2xl font-semibold">🚌 Tareeq</span>
                </div>
            </div>

            <!-- Navigation -->
            <nav class="flex-1 px-2 py-4 space-y-2">
                <a href="{{ route('admin.dashboard') }}" 
                   class="flex items-center px-4 py-2 text-gray-700 hover:bg-blue-100 hover:text-blue-600 rounded-lg transition-colors {{ request()->routeIs('admin.dashboard') ? 'bg-blue-100 text-blue-600' : '' }}">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                    </svg>
                    Dashboard
                </a>

                <a href="{{ route('admin.routes') }}"
                   class="flex items-center px-4 py-2 text-gray-700 hover:bg-blue-100 hover:text-blue-600 rounded-lg transition-colors {{ request()->routeIs('admin.routes*') ? 'bg-blue-100 text-blue-600' : '' }}">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"></path>
                    </svg>
                    Routes
                </a>

                <a href="{{ route('admin.stops') }}"
                   class="flex items-center px-4 py-2 text-gray-700 hover:bg-blue-100 hover:text-blue-600 rounded-lg transition-colors {{ request()->routeIs('admin.stops*') ? 'bg-blue-100 text-blue-600' : '' }}">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                    </svg>
                    Stops
                </a>

                <a href="{{ route('admin.drivers') }}"
                   class="flex items-center px-4 py-2 text-gray-700 hover:bg-blue-100 hover:text-blue-600 rounded-lg transition-colors {{ request()->routeIs('admin.drivers') ? 'bg-blue-100 text-blue-600' : '' }}">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                    </svg>
                    Drivers
                </a>

                <a href="{{ route('admin.users') }}"
                   class="flex items-center px-4 py-2 text-gray-700 hover:bg-blue-100 hover:text-blue-600 rounded-lg transition-colors {{ request()->routeIs('admin.users') ? 'bg-blue-100 text-blue-600' : '' }}">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path>
                    </svg>
                    Users
                </a>

                <a href="{{ route('admin.payments') }}"
                   class="flex items-center px-4 py-2 text-gray-700 hover:bg-blue-100 hover:text-blue-600 rounded-lg transition-colors {{ request()->routeIs('admin.payments') ? 'bg-blue-100 text-blue-600' : '' }}">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path>
                    </svg>
                    Payments
                </a>
            </nav>

            <!-- User Info -->
            <div class="border-t border-gray-200 p-4">
                <div class="flex items-center">
                    <div class="ml-3">
                        <p class="text-sm font-medium text-gray-700">Admin User</p>
                        <p class="text-xs text-gray-500">admin@tareeq.com</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="flex-1">
            <!-- Top Navigation -->
            <header class="bg-white shadow">
                <div class="px-4 py-6">
                    @yield('title')
                </div>
            </header>

            <!-- Page Content -->
            <main class="p-6">
                @yield('content')
            </main>
        </div>
    </div>
</body>
</html>
