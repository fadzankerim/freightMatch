class AppConstants {
  AppConstants._();
  static const String appName    = 'FreightMatch';
  static const String appTagline = 'Your route. Your cargo. Your profit.';

  // API (swap for real base URL)
  static const String baseUrl = 'https://api.freightmatch.app/v1';

  // Storage keys
  static const String keyAuthToken  = 'auth_token';
  static const String keyUserId     = 'user_id';
  static const String keyCurrentUser = 'current_user';
  static const String keyHomeCity   = 'home_city';
  static const String keyOnboarded  = 'onboarded';

  // Map defaults
  static const double defaultLat  = 44.0;
  static const double defaultLng  = 18.0;
  static const double defaultZoom = 7.0;

  // Timeouts
  static const Duration apiTimeout  = Duration(seconds: 30);
  static const Duration splashDelay = Duration(milliseconds: 2400);
}
