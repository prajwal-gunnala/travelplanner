/// Storage Service - Handles local data persistence using SharedPreferences
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip.dart';

class StorageService {
  static const String _tripsKey = 'saved_trips';
  static const String _userNameKey = 'user_name';

  /// Save user name
  Future<bool> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userNameKey, name);
    } catch (e) {
      return false;
    }
  }

  /// Get user name
  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final name = await getUserName();
    return name != null && name.isNotEmpty;
  }

  /// Save a trip
  Future<bool> saveTrip(Trip trip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trips = await getSavedTrips();
      
      // Add new trip at the beginning
      trips.insert(0, trip);
      
      // Convert to JSON
      final tripsJson = trips.map((t) => t.toJson()).toList();
      
      // Save to SharedPreferences
      return await prefs.setString(_tripsKey, json.encode(tripsJson));
    } catch (e) {
      return false;
    }
  }

  /// Get all saved trips
  Future<List<Trip>> getSavedTrips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tripsString = prefs.getString(_tripsKey);
      
      if (tripsString == null || tripsString.isEmpty) {
        return [];
      }
      
      final List<dynamic> tripsJson = json.decode(tripsString);
      return tripsJson.map((json) => Trip.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a trip by ID
  Future<bool> deleteTrip(String tripId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trips = await getSavedTrips();
      
      trips.removeWhere((trip) => trip.id == tripId);
      
      final tripsJson = trips.map((t) => t.toJson()).toList();
      return await prefs.setString(_tripsKey, json.encode(tripsJson));
    } catch (e) {
      return false;
    }
  }

  /// Clear all trips
  Future<bool> clearAllTrips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tripsKey);
    } catch (e) {
      return false;
    }
  }
}
