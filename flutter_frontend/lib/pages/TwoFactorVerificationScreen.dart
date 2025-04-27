import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/snackbar_helper.dart';
import 'package:flutter_frontend/pages/HomePage.dart';
import 'package:flutter_frontend/services/api_service.dart';

class TwoFactorVerificationScreen extends StatefulWidget {
  final String token;

  const TwoFactorVerificationScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<TwoFactorVerificationScreen> createState() => _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState extends State<TwoFactorVerificationScreen> {
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
      CustomSnackBar.showSuccess(message: "2FA verified successfully!", context: context);
      
      // Wait a moment to let the user see the success message
      await Future.delayed(Duration(seconds: 1));
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      CustomSnackBar.showError(message: "Invalid 2FA code, try again!", context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.security,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                "Two-Factor Authentication Required",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Please enter the 6-digit code from your authenticator app",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
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