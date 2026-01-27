class WeatherModel {
  final double temperature;
  final int humidity;
  final String description;
  final String iconCode;
  final String cityName;

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.iconCode,
    required this.cityName,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      description: json['weather'][0]['description'] as String,
      iconCode: json['weather'][0]['icon'] as String,
      cityName: json['name'] as String,
    );
  }
}
