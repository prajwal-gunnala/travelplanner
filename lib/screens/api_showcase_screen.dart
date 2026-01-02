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
  final _cityController = TextEditingController();
  final _weatherService = WeatherService();
  final _placeService = PlaceService();
  final _imageService = ImageService();
  final _storageService = StorageService();
  final PageController _pageController = PageController();

  String _userName = '';
  bool _isLoading = false;
  bool _isSaving = false;
  String _status = '';
  bool _placesError = false;
  String _placesErrorMessage = '';
  int _currentImageIndex = 0;
  
  Weather? _weather;
  List<Place> _places = [];
  List<String> _images = [];

  final List<String> _popularCities = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad'];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await _storageService.getUserName();
    setState(() {
      _userName = name ?? 'Traveler';
    });
  }

  Future<void> _search() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _status = 'Loading...';
      _weather = null;
      _places = [];
      _images = [];
      _placesError = false;
      _placesErrorMessage = '';
      _currentImageIndex = 0;
    });

    try {
      final weather = await _weatherService.getWeatherByCity(city);
      final images = await _imageService.searchImages('$city tourism', perPage: 6);
      
      List<Place> places = [];
      try {
        places = await _placeService.getPlacesByCity(city);
      } catch (e) {
        debugPrint('[UI] Places error: $e');
        setState(() {
          _placesError = true;
          _placesErrorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }

      setState(() {
        _weather = weather;
        if (!_placesError) {
          _places = places;
        }
        _images = images;
        _status = '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading data';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (_weather == null || _places.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please search for a city first')),
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Trip saved successfully' : 'Failed to save trip'),
          backgroundColor: success ? Colors.black : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Discover'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_images.isNotEmpty) _buildImagesSection(),
                  if (_weather != null) _buildWeatherSection(),
                  if (_placesError || _places.isNotEmpty) _buildPlacesSection(),
                  if (_weather == null && _places.isEmpty && !_isLoading && !_placesError)
                    _buildEmptyState(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi, $_userName',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Where do you want to go?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Search city',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: _cityController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _cityController.clear();
                                _weather = null;
                                _places = [];
                                _images = [];
                              });
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _search(),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _search,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Search'),
              ),
            ],
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _status,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _popularCities.map((city) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _cityController.text = city;
                  });
                  _search();
                },
                child: Chip(
                  label: Text(city),
                  backgroundColor: Colors.grey[100],
                  side: BorderSide(color: Colors.grey[300]!),
                  labelStyle: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      color: Colors.black,
      height: 240,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                _images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(Icons.image, size: 48, color: Colors.white54),
                  ),
                ),
              );
            },
          ),
          // Page indicators
          if (_images.length > 1)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveTrip,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.bookmark_border, size: 18),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weather',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_weather!.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _weather!.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Humidity: ${_weather!.humidity.toInt()}%'),
                  const SizedBox(height: 4),
                  Text('Wind: ${_weather!.windSpeed.toStringAsFixed(1)} m/s'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesSection() {
    if (_placesError) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.black54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Could not load places',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _placesErrorMessage,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Places to Visit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _places.length,
            itemBuilder: (context, index) {
              final place = _places[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
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
                          if (place.description != null &&
                              place.description!.isNotEmpty) ...[
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.travel_explore, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Search for a city to start planning',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
