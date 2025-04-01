import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/payment_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Stripe.publishableKey =
        'pk_test_51R8N58RqkFEca6vdKc4r0whD5noHO5XrwLCf3KMOQTCFGmKGc3eoJx39Iu9l4242hGR7Z894uCIZHRT5MjgjBYzU00vegOu5nb';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            PaymentService.instance.makePayment();
          },
          child: Text('Pay'),
        ),
      ),
    );
  }
}
