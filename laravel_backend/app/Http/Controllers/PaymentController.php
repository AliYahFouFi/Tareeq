<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Env;
use Illuminate\Support\Facades\Validator;
use Stripe\Exception\ApiErrorException;

class PaymentController extends Controller
{

    public function createPaymentIntent(Request $request)
    {
        // Validate input
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:1',
            'currency' => 'sometimes|string|size:3',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => $validator->errors()->first()
            ], 422);
        }

        try {
            $stripe = new \Stripe\StripeClient(Env::get('STRIPE_SECRET'));

            // Create PaymentIntent (amount should be in smallest currency unit - cents for USD)
            $paymentIntent = $stripe->paymentIntents->create([
                'amount' => 1000, // Convert dollars to cents
                'currency' =>  'usd',
                'automatic_payment_methods' => [
                    'enabled' => true,
                ],
                'metadata' => [
                    // 'user_id' => $request->user()->id,
                    'purpose' => 'bus_ticket_payment',
                ],
            ]);

            return response()->json([
                'clientSecret' => $paymentIntent->client_secret,
                'paymentIntentId' => $paymentIntent->id,
            ]);
        } catch (ApiErrorException $e) {
            return response()->json([
                'error' => 'Payment processing error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function index()
    {
        try {
            $stripe = new \Stripe\StripeClient(env('STRIPE_SECRET'));
            $charges = $stripe->charges->all(['limit' => 100]);

            return view('admin.payments', [
                'charges' => $charges->data
            ]);
        } catch (\Exception $e) {
            return back()->with('error', 'Error fetching payment data: ' . $e->getMessage());
        }
    }
}
