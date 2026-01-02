import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/place_service.dart';
import '../services/image_service.dart';
import '../services/storage_service.dart';
import '../models/weather.dart';
import '../models/place.dart';
import '../models/trip.dart';

class ApiShowcaseScreen extends StatefulWidget {
  const ApiShowcaseScreen({super.key});

  @override
  State<ApiShowcaseScreen> createState() => _ApiShowcaseScreenState();
}

class _ApiShowcaseScreenState extends State<ApiShowcaseScreen> {
  final _cityController = TextEditingController(text: 'Hyderabad');
  final _weatherService = WeatherService();
  final _placeService = PlaceService();
  final _imageService = ImageService();
  final _storageService = StorageService();

  bool _isLoading = false;
  bool _isSaving = false;
  String _status = 'Ready to search';
  
  // Results
  Weather? _weather;
  List<Place> _places = [];
  List<String> _images = [];

  Future<void> _search() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _status = 'Fetching data for $city...';
      _weather = null;
      _places = [];
      _images = [];
    });

    try {
      // 1. Fetch Weather
      setState(() => _status = 'Fetching Weather (OpenWeatherMap)...');
      final weather = await _weatherService.getWeatherByCity(city);
      
      // 2. Fetch Places
      setState(() => _status = 'Fetching Places (OpenTripMap/Overpass)...');
      final places = await _placeService.getPlacesByCity(city);

      // 3. Fetch Images
      setState(() => _status = 'Fetching Images (Unsplash)...');
      final images = await _imageService.searchImages('$city tourism', perPage: 6);

      setState(() {
        _weather = weather;
        _places = places;
        _images = images;
        _status = 'Data loaded successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (_weather == null || _places.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please search for a city first!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final trip = Trip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      city: _cityController.text.trim(),
      savedDate: DateTime.now(),
      weather: _weather!,
      places: _places,
      imageUrls: _images,
    );

    final success = await _storageService.saveTrip(trip);

    setState(() => _isSaving = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip to ${trip.city} saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save trip'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Destinations'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (_weather != null && _places.isNotEmpty)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.bookmark_add),
              onPressed: _isSaving ? null : _saveTrip,
              tooltip: 'Save Trip',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Enter City Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('SEARCH'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_status, style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),

            // Results Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Weather Section
                    _buildSectionHeader('1. OpenWeatherMap (Weather)', Icons.cloud),
                    _buildWeatherCard(),
                    const SizedBox(height: 20),

                    // 2. Places Section
                    _buildSectionHeader('2. OpenTripMap / Overpass (Places)', Icons.place),
                    _buildPlacesList(),
                    const SizedBox(height: 20),

                    // 3. Images Section
                    _buildSectionHeader('3. Unsplash (Images)', Icons.image),
                    _buildImagesGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (_weather == null) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No weather data')));
    }
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('${_weather!.temperature.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text(_weather!.description, style: const TextStyle(fontSize: 16)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Humidity: ${_weather!.humidity}%'),
                Text('Wind: ${_weather!.windSpeed} m/s'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesList() {
    if (_places.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No places found')));
    }
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _places.length,
        separatorBuilder: (ctx, i) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final place = _places[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Text('${i + 1}'),
            ),
            title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(place.category),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          );
        },
      ),
    );
  }

  Widget _buildImagesGrid() {
    if (_images.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No images found')));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _images.length,
      itemBuilder: (ctx, i) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _images[i],
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.error)),
          ),
        );
      },
    );
  }
}
