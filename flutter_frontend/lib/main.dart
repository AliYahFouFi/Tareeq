import 'package:flutter/material.dart';
import 'pages/HomePage.dart';
import 'components/NavBar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'My App', home: HomePage());
  }
}
