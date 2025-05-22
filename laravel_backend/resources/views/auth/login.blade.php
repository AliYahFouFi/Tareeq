<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title') | Tareeq Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head><x-guest-layout>
    <!-- Session Status -->
    <x-auth-session-status class="mb-6" :status="session('status')" />

    <div class="max-w-md mx-auto bg-white p-8 rounded-lg shadow-md">
        <h2 class="text-3xl font-semibold text-center text-indigo-600 mb-8">Welcome Back</h2>

        <form method="POST" action="{{ route('login') }}">
            @csrf

            <!-- Email Address -->
            <div class="mb-6">
                <x-input-label for="email" :value="__('Email')" class="block text-gray-700 mb-2" />
                <x-text-input id="email"
                    class="block w-full rounded-md border border-gray-300 px-4 py-3 focus:border-indigo-500 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
                    type="email" name="email" :value="old('email')" required autofocus autocomplete="username" />
                <x-input-error :messages="$errors->get('email')" class="mt-2 text-red-600 text-sm" />
            </div>

            <!-- Password -->
            <div class="mb-6">
                <x-input-label for="password" :value="__('Password')" class="block text-gray-700 mb-2" />
                <x-text-input id="password"
                    class="block w-full rounded-md border border-gray-300 px-4 py-3 focus:border-indigo-500 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
                    type="password" name="password" required autocomplete="current-password" />
                <x-input-error :messages="$errors->get('password')" class="mt-2 text-red-600 text-sm" />
            </div>

            <!-- Remember Me -->
            <div class="mb-6 flex items-center">
                <input id="remember_me" type="checkbox" name="remember"
                    class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded" />
                <label for="remember_me" class="ml-2 block text-gray-700 text-sm cursor-pointer">
                    {{ __('Remember me') }}
                </label>
            </div>

            <!-- Actions -->
            <div class="flex items-center justify-between">
                @if (Route::has('password.request'))
                    <a href="{{ route('password.request') }}"
                        class="text-sm text-indigo-600 hover:text-indigo-900 underline">
                        {{ __('Forgot your password?') }}
                    </a>
                @endif

                <x-primary-button class="ml-4 px-6 py-3 text-lg font-semibold rounded-md">
                    {{ __('Log in') }}
                </x-primary-button>
            </div>
        </form>
    </div>
</x-guest-layout>
