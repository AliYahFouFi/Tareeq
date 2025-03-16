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

bool isValidName(String name) {
  final nameRegex = RegExp(r"^[a-zA-Z\s]{2,}$");
  return nameRegex.hasMatch(name);
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}

bool isValidPassword(String password) {
  final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
  return passwordRegex.hasMatch(password);
}

void register() async {
  String name = nameController.text.trim();
  String email = emailController.text.trim();
  String password = passwordController.text;

  if (!isValidName(name)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Name must contain only letters and be at least 2 characters long!"), 
      backgroundColor: Colors.red),
    );
    return;
  }

  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All fields are required!"), backgroundColor: Colors.red),
    );
    return;
  }

  if (!isValidEmail(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Invalid email format!"), backgroundColor: Colors.red),
    );
    return;
  }

  if (!isValidPassword(password)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Password must be at least 8 characters, include an uppercase letter, a number, and a special character."), 
      backgroundColor: Colors.red),
    );
    return;
  }

  // Show loading indicator
  setState(() => isLoading = true);

  bool isRegistered = await ApiService.register(name, email, password);

  setState(() => isLoading = false);

  if (isRegistered) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Registration successful!"), backgroundColor: Colors.green),
    );

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isLoginMode = true;
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Registration failed! Please check your details."), backgroundColor: Colors.red),
    );
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
