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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(trip.city),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            ...itinerary.entries.map((entry) => _buildDayCard(entry.key, entry.value)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.city,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${trip.weather.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trip.weather.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Humidity: ${trip.weather.humidity.toInt()}% • Wind: ${trip.weather.windSpeed.toStringAsFixed(1)} m/s',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (trip.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trip.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        trip.imageUrls[index],
                        width: 160,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          width: 160,
                          height: 120,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey[400]),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
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
              const SizedBox(width: 12),
              Text(
                '${places.length} places',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 50,
                            color: Colors.grey[300],
                            margin: const EdgeInsets.symmetric(vertical: 8),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            place.category,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (place.description != null && place.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              place.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isLast) const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

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
}
