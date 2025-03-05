import 'package:flutter/material.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/BusStopsProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'pages/HomePage.dart';
import 'package:provider/provider.dart';

void main() {
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tareeq',
        home: HomePage(),
      ),
    );
  }
}
