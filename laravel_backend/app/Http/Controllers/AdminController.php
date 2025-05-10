<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Bus;

class AdminController extends Controller
{
    //

    public function dashboard()
    {
        return view('admin.dashboard');
    }
}
