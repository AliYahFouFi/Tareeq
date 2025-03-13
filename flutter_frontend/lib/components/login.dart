import 'package:flutter/material.dart';
import 'package:flutter_frontend/pages/HomePage.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoginMode = true;
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn();
  }

  // Check if user is already logged in
  void checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    setState(() {
      isLoggedIn = token != null;
      isLoading = false;
    });
  }

  // Login function
  void login() async {
    String? token = await ApiService.login(emailController.text, passwordController.text);

    if (token != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login successful!"),
        backgroundColor: Colors.green,
      ));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      await Future.delayed(Duration(seconds: 2));

      setState(() {
        isLoggedIn = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login failed! Please check your credentials."),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Register function
  void register() async {
    bool isRegistered = await ApiService.register(nameController.text, emailController.text, passwordController.text);

    if (isRegistered) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registration successful!"),
        backgroundColor: Colors.green,
      ));

      await Future.delayed(Duration(seconds: 2));

      setState(() {
        isLoginMode = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registration failed! Please check your details."),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Logout function
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Logged out successfully!"),
      backgroundColor: Colors.blue,
    ));

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), 
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Authentication")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoggedIn
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("You are already logged in!", 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: Text("Go to Home"),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: logout,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Logout"),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  if (!isLoginMode) 
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Name"),
                    ),
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
                        isLoginMode = !isLoginMode;
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
