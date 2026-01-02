import 'place.dart';
import 'weather.dart';

class Trip {
  final String id;
  final String city;
  final DateTime savedDate;
  final Weather weather;
  final List<Place> places;
  final List<String> imageUrls;

  Trip({
    required this.id,
    required this.city,
    required this.savedDate,
    required this.weather,
    required this.places,
    required this.imageUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'savedDate': savedDate.toIso8601String(),
      'weather': {
        'city': weather.city,
        'temperature': weather.temperature,
        'description': weather.description,
        'humidity': weather.humidity,
        'windSpeed': weather.windSpeed,
      },
      'places': places.map((p) => {
        'name': p.name,
        'latitude': p.latitude,
        'longitude': p.longitude,
        'category': p.category,
        'description': p.description,
      }).toList(),
      'imageUrls': imageUrls,
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      city: json['city'],
      savedDate: DateTime.parse(json['savedDate']),
      weather: Weather(
        city: json['weather']['city'],
        temperature: json['weather']['temperature'],
        description: json['weather']['description'],
        humidity: json['weather']['humidity'],
        windSpeed: json['weather']['windSpeed'],
      ),
      places: (json['places'] as List).map((p) => Place(
        name: p['name'],
        latitude: p['latitude'],
        longitude: p['longitude'],
        category: p['category'] ?? 'attraction',
        description: p['description'],
      )).toList(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }
}
