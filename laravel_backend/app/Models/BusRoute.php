<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\BusStop;

class BusRoute extends Model
{
    //
    protected $fillable = [
        'name',
        'schedule',
    ];
    public function stops()
    {
        return $this->belongsToMany(BusStop::class, 'bus_route_stop')
            ->withPivot('order') // Include the "order" column
            ->orderByPivot('order'); // Sort stops by order
    }
}
