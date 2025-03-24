import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/User_model.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<bool> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Registration successful
      } else {
        // Log the error details
        print("Registration failed: ${response.statusCode} - ${response.body}");
        return false; // Registration failed
      }
    } catch (e) {
      print("Error during registration: $e");
      return false; // Handle network or other errors
    }
  }

  // Login
  static Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      body: {"email": email, "password": password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User(
        id: data['id'].toString(),
        name: data['name'],
        email: data['email'],
        role: data['role'],
        token: data['token'],
      );
    } else {
      return null;
    }
  }

  // Logout
  static Future<http.Response> logout(String token) async {
    return await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {"Authorization": "Bearer $token"},
    );
  }
}
