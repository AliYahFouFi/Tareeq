// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_frontend/providers/AuthProvider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as context;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_frontend/models/Ticket_model.dart';

class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();
  static const String baseUrl = "http://10.0.2.2:8000/api";
  Future<http.Response> createPaymentIntent() async {
    final response = await http.post(
      Uri.parse("$baseUrl/create-payment-intent"),

      headers: {
        // 'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': 10, // $10 is the amount to be charged
        'currency': 'usd',
      }),
    );
    if (response.statusCode == 200) {
      print('Payment Intent Created Successfully');
      //print(response.body);
      return response; // You need to return the response
    } else {
      throw Exception('Failed to create payment intent www');
    }
  }

  Future<void> makePayment() async {
    try {
      http.Response response = await instance.createPaymentIntent();
      // ignore: unnecessary_null_comparison
      if (response == null) {
        return;
      }
      Map<String, dynamic> data = jsonDecode(response.body);
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['clientSecret'],
          merchantDisplayName: 'Tareeq',
        ),
      );

      try {
        await _processPayment();
      } catch (e) {
        print('PROCESS PAYMENT ERROR $e');
      }
    } catch (e) {
      print("Error making payment: $e");
    }
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      print("Payment Confirmed");
      generateTicket();
      print("Ticket Generated Successfully");
    } catch (e) {
      print("Error processing payment: $e");
    }
  }

  Future<void> generateTicket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          //'trip_id': 'abc123',
          'price': 10.0,
        }),
      );
      if (response.statusCode == 201) {
        print("Ticket generated successfully");
      } else {
        print("Error generating ticket: ${response.statusCode}");
      }
    } on Exception catch (e) {
      print("Error generating ticket: $e");
    }
  }

  Future<List<Ticket>> fetchTickets(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/tickets/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((ticketJson) => Ticket.fromJson(ticketJson)).toList();
    } else {
      throw Exception('Failed to load tickets');
    }
  }
}
