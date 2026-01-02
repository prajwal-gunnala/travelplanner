/// API Keys Configuration
library;

/// Get your free API keys from:
/// - OpenTripMap: https://dev.opentripmap.org/register (Free tier available)
/// - OpenWeatherMap: https://openweathermap.org/api (Free tier: 1000 calls/day)
/// - Unsplash: https://unsplash.com/developers (Demo: 50 requests/hour)
/// 
/// This app expects keys to be provided via `--dart-define` (recommended).
///
/// Example:
/// `flutter run --dart-define=OTM_API_KEY=... --dart-define=OWM_API_KEY=... --dart-define=UNSPLASH_ACCESS_KEY=...`
///
/// NOTE: Do not hardcode real keys in source control.

class ApiKeys {
  // OpenTripMap API Key
  static const String openTripMapApiKey = '5ae2e3f221c38a28845f05b6e87fc37711ad038dd70ad918448ba773';

  // OpenWeatherMap API Key
  static const String openWeatherMapApiKey = '6b97b23400d9fc069c0e967ee87c9aca';

  // Unsplash API Key (Access Key)
  static const String unsplashAccessKey = 'lISg0hWPkhU4MuQ8z1KqOpQZKcaQKgVkhUi1W_vVLrs';
  
  // API Base URLs
  static const String openTripMapBaseUrl = 'https://api.opentripmap.com/0.1';
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String unsplashBaseUrl = 'https://api.unsplash.com';
}
