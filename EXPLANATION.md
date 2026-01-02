# Smart Travel Planner - Project Explanation

A beginner-friendly Flutter travel planning app for discovering destinations, checking weather, and creating trip itineraries.

---

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point and theme configuration
├── config/
│   └── api_keys.dart         # API configuration (keys and base URLs)
├── models/
│   ├── place.dart            # Place/destination data model
│   ├── weather.dart          # Weather data model
│   └── trip.dart             # Trip and itinerary models
├── services/
│   ├── weather_service.dart  # OpenWeatherMap API calls
│   ├── image_service.dart    # Unsplash API calls
│   ├── place_service.dart    # Tourist place data (sample data)
│   └── storage_service.dart  # Local storage (SharedPreferences)
├── screens/
│   ├── login_screen.dart     # User login (name entry)
│   ├── home_screen.dart      # Main dashboard with search
│   ├── place_list_screen.dart    # List of places in a city
│   ├── place_detail_screen.dart  # Detailed place view
│   ├── itinerary_screen.dart     # Create/edit itineraries
│   └── saved_trips_screen.dart   # View saved trips
└── widgets/
    ├── place_card.dart       # Reusable place card widget
    ├── weather_widget.dart   # Weather display widget
    └── custom_search_bar.dart # Search input widget
```

---

## 🔧 Dependencies Used

| Package | Purpose |
|---------|---------|
| `http` | Making HTTP requests to APIs |
| `shared_preferences` | Storing data locally (offline support) |
| `cached_network_image` | Caching images for faster loading |
| `provider` | State management (available if needed) |
| `intl` | Date formatting |

---

## 🌐 APIs Integrated

### 1. OpenTripMap API
- **Purpose**: Fetch tourist attractions and place details
- **Endpoints**:
  - `/places/geoname` - Get city coordinates
  - `/places/radius` - Get places around coordinates
  - `/places/xid/{xid}` - Get detailed place info
- **Free Tier**: Available with registration
- **Used in**: `PlaceService`

### 2. OpenWeatherMap API
- **Purpose**: Get real-time weather data
- **Endpoint**: `api.openweathermap.org/data/2.5/weather`
- **Free Tier**: 1,000 calls/day
- **Used in**: `WeatherService`

### 3. Unsplash API
- **Purpose**: Get beautiful destination images
- **Endpoint**: `api.unsplash.com/search/photos`
- **Free Tier**: 50 requests/hour (demo)
- **Used in**: `ImageService`

---

## 📱 Screens Explained

### 1. Login Screen (`login_screen.dart`)
- Simple name entry to personalize the app
- Stores username using SharedPreferences
- Gradient background with travel-themed design

### 2. Home Screen (`home_screen.dart`)
- Personalized greeting with user's name
- Search bar to find destinations
- Current weather display for default city
- Grid of featured cities to explore
- Bottom navigation bar

### 3. Place List Screen (`place_list_screen.dart`)
- Shows all tourist places for a selected city
- Each place displayed as a card with image
- Tap to view details

### 4. Place Detail Screen (`place_detail_screen.dart`)
- Large hero image with parallax effect
- Place description and rating
- Current weather at the location
- Photo gallery from Unsplash
- Button to create itinerary

### 5. Itinerary Screen (`itinerary_screen.dart`)
- Select trip start and end dates
- Auto-generates daily activities
- Organizes places across trip days
- Save trip to local storage

### 6. Saved Trips Screen (`saved_trips_screen.dart`)
- View all saved trips
- Shows destination, dates, and duration
- Delete trips with confirmation
- Works completely offline

---

## 💾 Offline Storage

The app uses `SharedPreferences` for offline storage:

```dart
// Saving a trip
await storageService.saveTrip(trip);

// Getting saved trips
List<Trip> trips = await storageService.getSavedTrips();

// Deleting a trip
await storageService.deleteTrip(tripId);
```

Data stored:
- User's name (for personalization)
- Saved trips (as JSON)

---

## 🚀 How to Run

### 1. Get API Keys

**OpenTripMap:**
1. Go to [dev.opentripmap.org](https://dev.opentripmap.org/)
2. Click "Register" and create an account
3. Get your API key from the dashboard
4. Copy your API key

**OpenWeatherMap:**
1. Go to [openweathermap.org](https://openweathermap.org/)
2. Sign up for free account
3. Go to API Keys section
4. Copy your API key

**Unsplash:**
1. Go to [unsplash.com/developers](https://unsplash.com/developers)
2. Create a developer account
3. Create a new application
4. Copy the Access Key

### 2. Add API Keys

Open `lib/config/api_keys.dart` and replace placeholders:

```dart
static const String openTripMapApiKey = 'YOUR_KEY_HERE';
static const String openWeatherMapApiKey = 'YOUR_KEY_HERE';
static const String unsplashAccessKey = 'YOUR_KEY_HERE';
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

---

## 🎨 Design Choices

### Color Scheme
- **Primary**: Teal (`Colors.teal`)
- **Reasoning**: Travel/nature feel, calming, professional

### UI Components
- **Cards**: Rounded corners (16px radius)
- **Buttons**: Rounded (12px radius)
- **Images**: Cached for performance

### Material 3
- Using Flutter's latest Material Design 3
- Modern look with dynamic color support

---

## 📝 Key Code Concepts

### 1. Async/Await for API Calls
```dart
Future<Weather?> getWeather(String city) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return Weather.fromJson(json.decode(response.body));
  }
  return null;
}
```

### 2. StatefulWidget for Dynamic UI
```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
```

### 3. JSON Serialization
```dart
factory Place.fromJson(Map<String, dynamic> json) {
  return Place(
    id: json['id'],
    name: json['name'],
    // ...
  );
}
```

### 4. Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
);
```

---

## ✅ Features Checklist

- [x] User login with name
- [x] Search destinations
- [x] View tourist places by city
- [x] Real-time weather display
- [x] Beautiful destination images
- [x] Create trip itineraries
- [x] Save trips locally
- [x] View and delete saved trips
- [x] Offline storage support
- [x] Material 3 design

---

## 🐛 Troubleshooting

### "API key not working"
- Make sure you've added your keys to `api_keys.dart`
- Check if you've exceeded the free tier limits

### "Images not loading"
- Check internet connection
- Unsplash has a rate limit of 50 requests/hour

### "Weather not showing"
- Verify OpenWeatherMap API key
- City name must be spelled correctly

---

## 📚 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/language)
- [Material Design 3](https://m3.material.io/)
- [HTTP Package](https://pub.dev/packages/http)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)

---

*Built as a college project - Smart Travel Planner App*
