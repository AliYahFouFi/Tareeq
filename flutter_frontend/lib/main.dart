import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/firebase_options.dart';
import 'package:flutter_frontend/pages/AboutUs.dart';
import 'package:flutter_frontend/pages/BusDetailsPage.dart';
import 'package:flutter_frontend/pages/BusPage.dart';
import 'package:flutter_frontend/pages/PaymentPage.dart';

import 'package:flutter_frontend/providers/AuthProvider.dart';
import 'package:flutter_frontend/providers/BusDriverProvider.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/BusStopsProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'pages/HomePage.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully!");
    // Stripe.publishableKey =
    //     'pk_test_51R8N58RqkFEca6vdKc4r0whD5noHO5XrwLCf3KMOQTCFGmKGc3eoJx39Iu9l4242hGR7Z894uCIZHRT5MjgjBYzU00vegOu5nb';
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BusStopsProvider()),
        ChangeNotifierProvider(create: (context) => BusRouteProvider()),
        ChangeNotifierProvider(create: (context) => UserLocationProvider()),
        ChangeNotifierProvider(create: (context) => BusDriverProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],

      child: MaterialApp(
        routes: {
          '/payment': (context) => PaymentPage(),
          '/AboutUs': (context) => AboutUsPage(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Tareeq',
        home: // PaymentPage(),
            HomePage(),
      ),
    );
  }
}
