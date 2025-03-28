import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/snackbar_helper.dart';
import 'package:flutter_frontend/models/User_model.dart';
import 'package:flutter_frontend/pages/HomePage.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _selectedRole = 'user';

  bool get isLoggedIn => _isLoggedIn;
  String get selectedRole => _selectedRole;

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

      _isLoggedIn = true;
      _selectedRole = response.role;
      notifyListeners();

      CustomSnackBar.showSuccess(
        message: "Login successful!",
        context: context,
      );

      notifyListeners();
      return true; // Return true on successful login
    } else {
      CustomSnackBar.showError(
        message: "Login failed! Please check your credentials.",
        context: context,
      );

      notifyListeners();
      return false; // Return false on login failure
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

      _isLoggedIn = true;
      notifyListeners();
    } else {
      {
        CustomSnackBar.showError(
          message: "Registration failed! Please check your credentials.",
          context: context,
        );
      }
    }
    login(email, password, context);
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
