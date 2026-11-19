class AppConfig {
  const AppConfig._();

  static const String appName = 'API Ninjas Explorer';
  static const String baseUrl = 'https://api.api-ninjas.com';
  static const String apiKeyHeader = 'X-Api-Key';
  static const String website = 'https://api-ninjas.com';
  static const String registerUrl = 'https://api-ninjas.com/register';
  static const String profileUrl = 'https://api-ninjas.com/profile';

  static const String apiKeyFromEnvironment = String.fromEnvironment(
    'API_NINJAS_KEY',
  );

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 20);
}
