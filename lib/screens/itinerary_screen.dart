import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/place.dart';

class ItineraryScreen extends StatelessWidget {
  final Trip trip;

  const ItineraryScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final itinerary = _generateItinerary(trip.places);

    return Scaffold(
      appBar: AppBar(
        title: Text('${trip.city} Itinerary'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with weather and images
            _buildHeader(context),
            
            // Itinerary days
            ...itinerary.entries.map((entry) => _buildDayCard(entry.key, entry.value)),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.teal[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.city,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.wb_sunny, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                '${trip.weather.temperature.toStringAsFixed(1)}°C, ${trip.weather.description}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.water_drop, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text('Humidity: ${trip.weather.humidity.toInt()}%'),
            ],
          ),
          if (trip.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trip.imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        trip.imageUrls[index],
                        width: 160,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            Container(
                              width: 160,
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image),
                            ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayCard(int day, List<Place> places) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Day $day',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${places.length} places',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...places.asMap().entries.map((entry) {
              final index = entry.key;
              final place = entry.value;
              final isLast = index == places.length - 1;
              
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.teal,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 40,
                              color: Colors.grey[300],
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(place.category),
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  place.category,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            if (place.description != null && place.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                place.description!,
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Split places into days (3-4 places per day)
  Map<int, List<Place>> _generateItinerary(List<Place> places) {
    const placesPerDay = 4;
    final Map<int, List<Place>> itinerary = {};
    
    int currentDay = 1;
    for (int i = 0; i < places.length; i += placesPerDay) {
      final endIndex = (i + placesPerDay < places.length) ? i + placesPerDay : places.length;
      itinerary[currentDay] = places.sublist(i, endIndex);
      currentDay++;
    }
    
    return itinerary;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'museum':
        return Icons.museum;
      case 'landmark':
        return Icons.landscape;
      case 'religious':
        return Icons.temple_hindu;
      case 'park':
        return Icons.park;
      case 'historic':
        return Icons.history_edu;
      default:
        return Icons.place;
    }
  }
}
