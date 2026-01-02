/// Place Service - Fetches tourist places using OpenStreetMap Overpass API
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../models/place.dart';

class PlaceService {
  final Uri _overpassUrl = Uri.parse('https://overpass-api.de/api/interpreter');
  final String _owmGeoBaseUrl = 'https://api.openweathermap.org/geo/1.0';

  /// Get coordinates for a city using OpenWeatherMap geocoding
  Future<Map<String, dynamic>?> _getCityCoordinates(String city) async {
    try {
      final url = Uri.parse('$_owmGeoBaseUrl/direct').replace(
        queryParameters: {
          'q': city,
          'limit': '1',
          'appid': ApiKeys.openWeatherMapApiKey,
        },
      );

      debugPrint('[PlaceService] Getting coordinates for: $city');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final result = data[0];
          debugPrint('[PlaceService] Found: ${result['name']}, ${result['country']}');
          return result;
        }
      }

      debugPrint('[PlaceService] No coordinates found for "$city"');
      return null;
    } catch (e) {
      debugPrint('[PlaceService] Error getting coordinates: $e');
      return null;
    }
  }

  /// Get places using OpenStreetMap Overpass API
  Future<List<Place>> _getPlacesFromOverpass({
    required String city,
    required String country,
    required double lat,
    required double lon,
    int radiusMeters = 10000,
    int limit = 20,
  }) async {
    try {
      // Overpass query for tourist attractions
      final query = '''
[out:json][timeout:25];
(
  node["tourism"="attraction"](around:$radiusMeters,$lat,$lon);
  node["tourism"="museum"](around:$radiusMeters,$lat,$lon);
  node["tourism"="viewpoint"](around:$radiusMeters,$lat,$lon);
  node["historic"](around:$radiusMeters,$lat,$lon);
  node["amenity"="place_of_worship"](around:$radiusMeters,$lat,$lon);
  way["tourism"="attraction"](around:$radiusMeters,$lat,$lon);
  way["tourism"="museum"](around:$radiusMeters,$lat,$lon);
  way["historic"](around:$radiusMeters,$lat,$lon);
);
out center $limit;
''';

      debugPrint('[PlaceService] Querying Overpass API...');
      final response = await http.post(
        _overpassUrl,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': query},
      );

      if (response.statusCode != 200) {
        debugPrint('[PlaceService] Overpass error: ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);
      final elements = data['elements'] as List? ?? [];
      
      debugPrint('[PlaceService] Overpass returned ${elements.length} elements');

      final places = <Place>[];
      final seen = <String>{};

      for (final el in elements) {
        final tags = el['tags'] as Map<String, dynamic>? ?? {};
        final name = tags['name']?.toString();
        if (name == null || name.isEmpty) continue;

        final id = 'osm:${el['type']}/${el['id']}';
        if (seen.contains(id)) continue;
        seen.add(id);

        final coords = _extractLatLon(el);
        if (coords == null) continue;

        final category = _inferCategory(tags);
        final description = (tags['description'] ?? tags['short_description'] ?? tags['wikipedia'])?.toString();

        places.add(
          Place(
            name: name,
            latitude: coords.$1,
            longitude: coords.$2,
            category: category,
            description: (description != null && description.isNotEmpty)
                ? description
                : 'A popular place to visit in $city.',
          ),
        );
      }

      debugPrint('[PlaceService] Returning ${places.length} places');
      return places;
    } catch (e) {
      debugPrint('[PlaceService] Overpass error: $e');
      return [];
    }
  }

  /// Extract coordinates from Overpass element
  (double, double)? _extractLatLon(Map<String, dynamic> element) {
    final lat = element['lat'];
    final lon = element['lon'];
    if (lat is num && lon is num) {
      return (lat.toDouble(), lon.toDouble());
    }

    final center = element['center'];
    if (center is Map) {
      final clat = center['lat'];
      final clon = center['lon'];
      if (clat is num && clon is num) {
        return (clat.toDouble(), clon.toDouble());
      }
    }

    return null;
  }

  /// Infer category from OSM tags
  String _inferCategory(Map<String, dynamic> tags) {
    final tourism = tags['tourism']?.toString();
    final historic = tags['historic']?.toString();
    final amenity = tags['amenity']?.toString();
    final leisure = tags['leisure']?.toString();

    if (tourism == 'museum') return 'museum';
    if (tourism == 'viewpoint') return 'landmark';
    if (tourism == 'attraction') return 'attraction';
    if (amenity == 'place_of_worship') return 'religious';
    if (leisure == 'park') return 'park';
    if (historic != null && historic.isNotEmpty) return 'historic';
    return 'attraction';
  }

  /// Get places for a city
  Future<List<Place>> getPlacesByCity(String city) async {
    debugPrint('[PlaceService] Getting places for: $city');
    
    final cityData = await _getCityCoordinates(city);
    if (cityData == null) {
      debugPrint('[PlaceService] Could not find coordinates for $city');
      return [];
    }

    final places = await _getPlacesFromOverpass(
      city: cityData['name'] ?? city,
      country: cityData['country'] ?? '',
      lat: (cityData['lat'] as num).toDouble(),
      lon: (cityData['lon'] as num).toDouble(),
    );

    return places;
  }

  /// Search places by query
  Future<List<Place>> searchPlaces(String query) async {
    return await getPlacesByCity(query);
  }
}

