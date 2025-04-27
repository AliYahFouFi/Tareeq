<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use PragmaRX\Google2FA\Google2FA;

class TwoFactorController extends Controller
{
    public function enable2FA(Request $request)
    {
        $user = $request->user();
        $google2fa = new Google2FA();
    
        $secret = $google2fa->generateSecretKey();
    
        $user->google2fa_secret = $secret;
        $user->is_2fa_enabled = true;
        $user->save();
    
        // Create QR Code URL (don't convert to image)
        $qrCodeData = $google2fa->getQRCodeUrl(
            'Tareeq App',
            $user->email,
            $secret
        );
    
        return response()->json([
            'secret' => $secret,
            'qrcode_data' => $qrCodeData, // Send the raw data instead of image URL
        ]);
    }

    public function verify2FA(Request $request)
    {
        $request->validate([
            'code' => 'required|string',
        ]);

        $user = $request->user();
        $google2fa = new Google2FA();

        // Check if the entered code is valid for the user's secret
        $valid = $google2fa->verifyKey($user->google2fa_secret, $request->input('code'));

        if ($valid) {
            return response()->json(['message' => '2FA verified']);
        }

        return response()->json(['message' => 'Invalid 2FA code'], 401);
    }
}
