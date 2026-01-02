/// Weather Service - Handles API calls to OpenWeatherMap for weather data
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../models/weather.dart';

class WeatherService {
  /// Fetch current weather for a city
  /// 
  /// [city] - City name (e.g., "Paris", "Tokyo")
  /// Returns Weather object or null if error
  Future<Weather?> getWeatherByCity(String city) async {
    try {
      if (ApiKeys.openWeatherMapApiKey.isEmpty) {
        debugPrint('[WeatherService] OpenWeatherMap key missing; skipping weather request');
        return null;
      }

      final url = Uri.parse(
        '${ApiKeys.weatherBaseUrl}/weather'
        '?q=$city'
        '&appid=${ApiKeys.openWeatherMapApiKey}'
        '&units=metric', // Use Celsius
      );
      
      debugPrint('[WeatherService] Fetching weather for: $city');
      debugPrint('[WeatherService] URL: $url');

      final response = await http.get(url);
      
      debugPrint('[WeatherService] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        debugPrint('[WeatherService] Weather data received: ${json['weather']?[0]?['description']}');
        return Weather.fromJson(json);
      } else {
        debugPrint('[WeatherService] API Error: ${response.statusCode}');
        debugPrint('[WeatherService] Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('[WeatherService] Error: $e');
      return null;
    }
  }

  /// Fetch current weather by coordinates
  /// 
  /// [lat] - Latitude
  /// [lon] - Longitude
  Future<Weather?> getWeatherByCoordinates(double lat, double lon) async {
    try {
      if (ApiKeys.openWeatherMapApiKey.isEmpty) {
        debugPrint('[WeatherService] OpenWeatherMap key missing; skipping weather request');
        return null;
      }

      final url = Uri.parse(
        '${ApiKeys.weatherBaseUrl}/weather'
        '?lat=$lat'
        '&lon=$lon'
        '&appid=${ApiKeys.openWeatherMapApiKey}'
        '&units=metric',
      );
      
      debugPrint('[WeatherService] Fetching weather for coordinates: lat=$lat, lon=$lon');

      final response = await http.get(url);
      
      debugPrint('[WeatherService] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        debugPrint('[WeatherService] Weather data received for: ${json['name']}');
        return Weather.fromJson(json);
      } else {
        debugPrint('[WeatherService] API Error: ${response.statusCode}');
        debugPrint('[WeatherService] Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('[WeatherService] Error: $e');
      return null;
    }
  }
}
