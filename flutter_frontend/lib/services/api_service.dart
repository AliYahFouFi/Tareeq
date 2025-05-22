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
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        body: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Add null checks for each field
        return User(
          id: data['id']?.toString() ?? '',
          name: data['name']?.toString() ?? '',
          email: data['email']?.toString() ?? '',
          role: data['role']?.toString() ?? '',
          token: data['token']?.toString() ?? '',
          is2FAEnabled: data['is_2fa_enabled'] == 1,
          busId:
              data['busId']?.toString() ??
              '', // Provide empty string as default
        );
      } else {
        print("Login failed: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> enable2FA(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/2fa/setup'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'secret': data['secret'],
          'qrcode_data':
              data['qrcode_data'], // Make sure this matches your backend field
        };
      } else {
        print("Enable 2FA failed: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error during enabling 2FA: $e");
      return null;
    }
  }

  static Future<bool> verify2FA(String token, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/2fa/verify'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json", // Important!
        },
        body: jsonEncode({"code": code}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          "2FA verification failed: ${response.statusCode} - ${response.body}",
        );
        return false;
      }
    } catch (e) {
      print("Error during 2FA verification: $e");
      return false;
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
