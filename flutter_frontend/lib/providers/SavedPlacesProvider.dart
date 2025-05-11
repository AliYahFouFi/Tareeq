import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/SavedPlace.dart';

class SavedPlacesProvider with ChangeNotifier {
  List<SavedPlace> _places = [];

  List<SavedPlace> get places => _places;

  Future<void> loadPlacesFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('saved_places');
    if (data != null) {
      List decoded = jsonDecode(data);
      _places = decoded.map((e) => SavedPlace.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> savePlacesToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'saved_places',
      jsonEncode(_places.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addPlace(SavedPlace place) async {
    _places.add(place);
    await savePlacesToLocalStorage();
    notifyListeners();
  }

  Future<void> deletePlace(String id) async {
    _places.removeWhere((place) => place.id == id);
    await savePlacesToLocalStorage();
    notifyListeners();
  }
}
