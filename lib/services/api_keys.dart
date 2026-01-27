import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  static String get openWeatherMap => dotenv.env['OPENWEATHERMAP_KEY'] ?? '';

  static String get cohereApiKey => dotenv.env['COHERE_API_KEY'] ?? '';
}
