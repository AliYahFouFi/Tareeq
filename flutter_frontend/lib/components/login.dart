import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoginMode = true;  // A flag to toggle between Login and Register

  // Login function
  void login() async {
    String? token = await ApiService.login(emailController.text, passwordController.text);

    if (token != null) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login successful!"),
        backgroundColor: Colors.green,
      ));

      // Save token for future requests
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // Delay to ensure snack bar shows before navigating
      await Future.delayed(Duration(seconds: 2));

      // Navigate to Home Screen and close the login screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login failed! Please check your credentials."),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Register function
  void register() async {
    // Here you can add the register API call (assuming it's in ApiService)
    bool isRegistered = await ApiService.register(emailController.text, passwordController.text);

    if (isRegistered) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registration successful!"),
        backgroundColor: Colors.green,
      ));

      // Delay to ensure snack bar shows before navigating to Login screen
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        isLoginMode = true;  // Switch to login mode after successful registration
      });
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registration failed! Please check your details."),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLoginMode ? "Login" : "Register")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: isLoginMode ? login : register,
              child: Text(isLoginMode ? "Login" : "Register"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLoginMode = !isLoginMode;  // Toggle between Login and Register
                });
              },
              child: Text(isLoginMode ? "Don't have an account? Register here" : "Already have an account? Login here"),
            ),
          ],
        ),
      ),
    );
  }
}
