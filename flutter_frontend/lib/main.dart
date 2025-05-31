import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/login.dart';
import 'package:flutter_frontend/db/database_helper.dart';
import 'package:flutter_frontend/models/SavedPlace.dart';
import 'package:flutter_frontend/pages/AboutUs.dart';
import 'package:flutter_frontend/pages/SelectStopsPage.dart';
import 'package:flutter_frontend/pages/TimetablePage.dart';
import 'package:flutter_frontend/pages/TwoFactorVerificationScreen.dart';
import 'package:flutter_frontend/pages/WelcomePage.dart';
import 'package:flutter_frontend/providers/AppPreferencesProvider.dart';
import 'package:flutter_frontend/providers/AuthProvider.dart';
import 'package:flutter_frontend/providers/BusDriverProvider.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/BusStopsProvider.dart';
import 'package:flutter_frontend/providers/SavedPlacesProvider.dart';
import 'package:flutter_frontend/providers/userLocationProvider.dart';
import 'pages/HomePage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/pages/IssuesPage.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully!");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }
  final savedPlacesProvider = SavedPlacesProvider();
  await savedPlacesProvider.loadPlacesFromLocalStorage();

  final appPreferencesProvider = AppPreferencesProvider();
  await appPreferencesProvider.checkFirstLaunch();

  runApp(
    MyApp(
      savedPlacesProvider: savedPlacesProvider,
      appPreferencesProvider: appPreferencesProvider,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SavedPlacesProvider savedPlacesProvider;
  final AppPreferencesProvider appPreferencesProvider;

  const MyApp({
    super.key,
    required this.savedPlacesProvider,
    required this.appPreferencesProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BusStopsProvider()),
        ChangeNotifierProvider(create: (context) => BusRouteProvider()),
        ChangeNotifierProvider(create: (context) => UserLocationProvider()),
        ChangeNotifierProvider(create: (context) => BusDriverProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider.value(value: savedPlacesProvider),
        ChangeNotifierProvider.value(value: appPreferencesProvider),
      ],
      child: MaterialApp(
        routes: {
          '/home': (context) => HomePage(),
          '/welcome': (context) => WelcomePage(),
          '/verify2fa':
              (context) => TwoFactorVerificationScreen(
                token:
                    Provider.of<AuthProvider>(context, listen: false).userToken,
              ),
          '/login': (context) => LoginScreen(),
          '/AboutUs': (context) => AboutUsPage(),
          '/selectStopPage': (context) => SelectStopsPage(),
          '/timetable': (context) => VisualTimetablePage(),
          '/issues': (context) => IssuesPage(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Tareeq',
        home: Consumer<AppPreferencesProvider>(
          builder: (context, appPrefs, _) {
            return appPrefs.isFirstLaunch ? WelcomePage() : HomePage();
          },
        ),
      ),
    );
  }
}
