<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('bus_route_stop', function (Blueprint $table) {
            $table->id();
            $table->foreignId('bus_route_id')->constrained()->onDelete('cascade');
            $table->foreignId('bus_stop_id')->constrained()->onDelete('cascade');
            $table->integer('order')->default(0); // Sequence of stops (1, 2, 3...)
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bus_route_stop');
    }
};
