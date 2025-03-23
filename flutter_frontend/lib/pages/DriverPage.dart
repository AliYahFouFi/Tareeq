import 'package:flutter/material.dart';
import 'package:flutter_frontend/pages/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverPage extends StatelessWidget {
  // Logout function
  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logged out successfully!"), backgroundColor: Colors.blue),
    );

    await Future.delayed(Duration(seconds: 2));

    // Navigate back to login screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Driver Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, Driver!", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => logout(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
