import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesProvider with ChangeNotifier {
  bool _isFirstLaunch = true;

  bool get isFirstLaunch => _isFirstLaunch;

  Future<void> checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if the app has been launched before
    _isFirstLaunch = prefs.getBool('first_launch') ?? true;
    notifyListeners();
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    // Mark that the app has been launched
    await prefs.setBool('first_launch', false);
    _isFirstLaunch = false;
    notifyListeners();
  }
}
