import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

static Future<bool> register(String name, String email, String password, String role) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'name': name, 'email': email, 'password': password, 'role': role},
    );
    
   if (response.statusCode == 200 || response.statusCode == 201){
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
static Future<Map<String, dynamic>?> login(String email, String password) async {
  final response = await http.post(
    Uri.parse("$baseUrl/login"),
    body: {
      "email": email,
      "password": password,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return {
      "token": data["token"], 
      "role": data["role"], // Make sure the backend sends 'role'
    };
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