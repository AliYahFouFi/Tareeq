<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Str;
use App\Models\Ticket;
use App\Models\User;

class TicketController extends Controller
{



    public function generateTicket(Request $request, $Userid)
    {
        if (!User::find($Userid)) {
            return response()->json(['error' => 'User not found'], 404);
        }
        $data = $request->validate([
            // 'trip_id' => 'required',
            'price' => 'required|numeric',
        ]);

        $ticketNumber = strtoupper(Str::random(10));

        $ticket = Ticket::create([
            'user_id' => $Userid,
            'ticket_number' => $ticketNumber,
            // 'trip_id' => $data['trip_id'],
            'price' => $data['price'],
        ]);

        return response()->json($ticket, 201);
    }

    public function getUserTickets($Userid)
    {
        $tickets = Ticket::where('user_id', $Userid)->latest()->get();

        return response()->json($tickets);
    }
}
