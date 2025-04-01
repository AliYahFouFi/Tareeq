import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

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
        'amount': 10, // $10
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
      await _processPayment();

      print("Payment Intent Createdwwwww: ${data['clientSecret']}");
      //i think we can add a function to generate the Qr code here
    } catch (e) {
      print("Error making payment: $e");
    }
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();
      print("Payment Confirmed");
    } catch (e) {
      print("Error processing payment: $e");
    }
  }
}
