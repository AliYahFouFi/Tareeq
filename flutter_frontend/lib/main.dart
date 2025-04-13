import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/pages/AboutUs.dart';
import 'package:flutter_frontend/pages/TimetablePage.dart';
import 'package:flutter_frontend/providers/AuthProvider.dart';
import 'package:flutter_frontend/providers/BusDriverProvider.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/BusStopsProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'pages/HomePage.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully!");
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
          '/AboutUs': (context) => AboutUsPage(),
          // '/Ticket': (context) => TicketPage(),
          '/timetable': (context) => VisualTimetablePage(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Tareeq',
        home: HomePage(),
      ),
    );
  }
}
