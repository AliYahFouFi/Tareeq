import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/snackbar_helper.dart';
import 'package:flutter_frontend/models/User_model.dart';
import 'package:flutter_frontend/pages/HomePage.dart';
import 'package:flutter_frontend/pages/QRCodeScreen.dart';
import 'package:flutter_frontend/pages/TwoFactorVerificationScreen.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _selectedRole = 'user';
  String userId = '';
  bool _is2FAEnabled = false;
  String _userToken = '';
  String _qrCodeData = '';
  String _secret = ''; // Move this field declaration above the getter

  bool get isLoggedIn => _isLoggedIn;
  String get selectedRole => _selectedRole;
  bool get is2FAEnabled => _is2FAEnabled;
  String get userToken => _userToken;
  String get qrCodeData => _qrCodeData;
  String get secret => _secret;

  AuthProvider() {
    checkIfLoggedIn();
  }

  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future<void> checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getString('token') != null;
    notifyListeners();
  }

  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    notifyListeners();

    User? response = await ApiService.login(email, password);

    if (response != null &&
        response.token.isNotEmpty &&
        response.role.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.token);
      await prefs.setString('role', response.role);
      await prefs.setString('id', response.id);
      await prefs.setString('busId', response.busId);
      _isLoggedIn = true;
      _selectedRole = response.role;
      userId = response.id;
      _userToken = response.token;
      _is2FAEnabled = response.is2FAEnabled;

      // Check if 2FA is not yet set up for this user
      if (!response.is2FAEnabled) {
        // If 2FA is not enabled, call enable2FA to set it up
        final data = await ApiService.enable2FA(response.token);

        if (data != null) {
          // Save QR code data to provider state
          _qrCodeData = data['qrcode_data'];
          _secret = data['secret'];
        } else {
          CustomSnackBar.showError(
            message: "Failed to enable 2FA!",
            context: context,
          );
          notifyListeners();
          return false;
        }
      } else {
        // For users with 2FA already enabled, we need to get their verification code
        // We'll just set a placeholder since we'll require verification either way
        _qrCodeData = "authenticate"; // This is just a placeholder
      }

      notifyListeners();
      return true;
    } else {
      CustomSnackBar.showError(
        message: "Login failed! Please check your credentials.",
        context: context,
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    BuildContext context,
  ) async {
    notifyListeners();

    bool isRegistered = await ApiService.register(
      name,
      email,
      password,
      _selectedRole,
    );

    if (isRegistered) {
      CustomSnackBar.showSuccess(
        message: "Registration successful!",
        context: context,
      );

      // Call login
      bool isLoggedIn = await login(email, password, context);

      if (isLoggedIn) {
        // ✅ After login, check if 2FA is enabled
        if (!_is2FAEnabled) {
          // Navigate to QRCodeScreen for setup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => QRCodeScreen(
                    qrCodeData: _qrCodeData,
                    token: _userToken,
                    secret: _secret,
                  ),
            ),
          );
        } else {
          // If already enabled, still go to verification screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TwoFactorVerificationScreen(token: _userToken),
            ),
          );
        }
      } else {
        CustomSnackBar.showError(
          message: "Login after registration failed!",
          context: context,
        );
      }
    } else {
      CustomSnackBar.showError(
        message: "Registration failed! Please check your credentials.",
        context: context,
      );
    }

    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('id');

    _isLoggedIn = false;
    notifyListeners();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
    CustomSnackBar.showSuccess(message: "Logout successful!", context: context);
  }
}
