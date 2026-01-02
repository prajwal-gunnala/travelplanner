/// Image Service - Handles API calls to Unsplash for destination images
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class ImageService {
  /// Search for destination images
  /// 
  /// [query] - Search term (e.g., "Paris France", "Eiffel Tower")
  /// [perPage] - Number of images to return (default: 5)
  /// Returns list of image URLs or empty list if error
  Future<List<String>> searchImages(String query, {int perPage = 5}) async {
    try {
      if (ApiKeys.unsplashAccessKey.isEmpty) {
        debugPrint('[ImageService] Unsplash key missing; skipping image search');
        return [];
      }

      final url = Uri.parse(
        '${ApiKeys.unsplashBaseUrl}/search/photos'
        '?query=$query'
        '&per_page=$perPage'
        '&orientation=landscape',
      );
      
      debugPrint('[ImageService] Searching images for: $query');
      debugPrint('[ImageService] URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Client-ID ${ApiKeys.unsplashAccessKey}',
        },
      );
      
      debugPrint('[ImageService] Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['results'] as List? ?? [];
        
        debugPrint('[ImageService] Found ${results.length} images');
        
        // Extract regular size image URLs
        return results
            .map<String>((photo) => photo['urls']['regular'] as String)
            .toList();
      } else {
        debugPrint('[ImageService] API Error: ${response.statusCode}');
        debugPrint('[ImageService] Response: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('[ImageService] Error: $e');
      return [];
    }
  }

  /// Get a random destination image
  /// 
  /// [query] - Optional search term to filter
  Future<String?> getRandomImage({String? query}) async {
    try {
      if (ApiKeys.unsplashAccessKey.isEmpty) {
        debugPrint('[ImageService] Unsplash key missing; skipping random image');
        return null;
      }

      String urlString = '${ApiKeys.unsplashBaseUrl}/photos/random'
          '?orientation=landscape';
      
      if (query != null) {
        urlString += '&query=$query';
      }

      final url = Uri.parse(urlString);
      
      debugPrint('[ImageService] Getting random image${query != null ? ' for: $query' : ''}');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Client-ID ${ApiKeys.unsplashAccessKey}',
        },
      );
      
      debugPrint('[ImageService] Random Image Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        debugPrint('[ImageService] Got random image successfully');
        return json['urls']['regular'] as String?;
      } else {
        debugPrint('[ImageService] API Error: ${response.statusCode}');
        debugPrint('[ImageService] Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('[ImageService] Error: $e');
      return null;
    }
  }
}
