import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:flutter_frontend/components/snackbar_helper.dart';
import 'package:qr_flutter/qr_flutter.dart'; // <-- Don't forget to import

class QRCodeScreen extends StatefulWidget {
  final String qrCodeData;
  final String token;

  const QRCodeScreen({Key? key, required this.qrCodeData, required this.token}) : super(key: key);

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> verifyCode() async {
    if (_codeController.text.trim().isEmpty || _codeController.text.trim().length != 6) {
      CustomSnackBar.showError(message: "Please enter a valid 6-digit code.", context: context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final isVerified = await ApiService.verify2FA(widget.token, _codeController.text.trim());

    setState(() {
      _isLoading = false;
    });

    if (isVerified) {
      // Show success message
      CustomSnackBar.showSuccess(message: "2FA verified successfully!", context: context);
      
      // Wait a moment to let the user see the success message
      await Future.delayed(Duration(seconds: 1));
      
      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      CustomSnackBar.showError(message: "Invalid 2FA code, try again!", context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Two-Factor Authentication'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
        child: Column(
          children: [
              // QR Code
            QrImageView(
              data: widget.qrCodeData,
              version: QrVersions.auto,
              size: 220.0,
            ),  
            const SizedBox(height: 20),
            const Text(
                "Scan the QR code with your Google Authenticator App",
              textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                  labelText: "Enter the 6-digit code",
                border: OutlineInputBorder(),
                counterText: '', // Hide counter
                  prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 20),
              SizedBox(
                    width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                      onPressed: verifyCode,
                        icon: const Icon(Icons.verified),
                        label: const Text('Verify Code'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                    ),
                  ),
          ],
        ),
      ),
      ),
    );
  }
}
