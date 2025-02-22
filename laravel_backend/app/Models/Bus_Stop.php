<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Bus_Stop extends Model
{
    protected $table = 'bus_stops';

    protected $fillable = [
        'name',
        'address',
        'latitude',
        'longitude',
        'bus_route_id',
    ];
}
