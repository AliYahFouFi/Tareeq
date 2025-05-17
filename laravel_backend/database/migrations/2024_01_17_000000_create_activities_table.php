<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('activities', function (Blueprint $table) {
            $table->id();
            $table->string('type'); // route, stop, bus, user
            $table->string('action'); // created, updated, deleted
            $table->string('description');
            $table->string('entity_id')->nullable();
            $table->string('entity_type')->nullable();
            $table->string('entity_name')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('activities');
    }
};
