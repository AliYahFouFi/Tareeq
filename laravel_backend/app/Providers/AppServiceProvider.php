<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Services\ActivityService;

class AppServiceProvider extends ServiceProvider
{
    public const HOME = '/admin/dashboard';

    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(ActivityService::class, function ($app) {
            return new ActivityService();
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
