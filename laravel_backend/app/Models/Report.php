<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Bus;


class Report extends Model
{
    protected $fillable = [
    'bus_id',
    'issue_type',
    'description',
    'image_path',
    ];

}
