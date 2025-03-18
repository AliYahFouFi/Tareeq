<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Bus_Route;

class BusStop extends Model
{
    protected $table = 'bus_stops';

    protected $fillable = [
        'name',
        'address',
        'latitude',
        'longitude',
    ];

    public function routes()
    {
        return $this->belongsToMany(BusRoute::class, 'bus_route_stop')
            ->withPivot('order');
    }
    public function routess()
    {
        return $this->belongsToMany(BusRoute::class, 'bus_route_stop');
    }
}
