import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cropdetect/models/weather_model.dart';
import 'package:cropdetect/services/weather_service.dart';
import 'package:cropdetect/services/cohere_service.dart';
import 'package:cropdetect/l10n/app_localizations.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final _weatherService = WeatherService();
  final _cohereService = CohereService();
  WeatherModel? _weather;
  bool _isLoading = true;
  String? _error;
  String? _dailyTip;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final weather = await _weatherService.getWeather();
      if (!mounted) return;

      setState(() {
        _weather = weather;
        _isLoading = false;
      });

      // Fetch AI Tip
      _fetchDailyTip();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDailyTip() async {
    if (_weather == null) return;
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final language = locale == 'ne' ? 'Nepali' : 'English';

      // We could make "crop" dynamic later. For now, general advice.
      final tip = await _cohereService.generateDailyTip(
        "${_weather!.description} (${_weather!.temperature.round()}°C)",
        "Rice/Maize",
        language,
      );

      if (mounted) {
        setState(() {
          _dailyTip = tip;
        });
      }
    } catch (e) {
      debugPrint("Tip generation failed: $e");
    }
  }

  String _getRecommendation(WeatherModel weather, AppLocalizations l10n) {
    if (weather.humidity > 80) {
      return l10n.highHumidityWarning;
    } else if (weather.temperature > 30) {
      return l10n.highTempWarning;
    } else if (weather.temperature < 10) {
      return l10n.lowTempWarning;
    }
    return l10n.goodWeatherMessage;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 30),
                const SizedBox(height: 8),
                Text(
                  _error!.contains('permissions')
                      ? l10n.locationPermissionDeny
                      : l10n.weatherLoadError,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.grey[700]),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _fetchWeather();
                  },
                  child: Text(l10n.retry),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weather!.cityName,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          l10n.todayWeather,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.network(
                          'https://openweathermap.org/img/wn/${_weather!.iconCode}@2x.png',
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.cloud, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_weather!.temperature.round()}°C',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Existing Recommendation (Hardcoded logic)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getRecommendation(_weather!, l10n),
                          style: GoogleFonts.outfit(
                            color: colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Generative AI Tip
                if (_dailyTip != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: Colors.amber[800],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Smart Daily Tip",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dailyTip!,
                          style: GoogleFonts.outfit(
                            color: Colors.amber[900],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 16,
                      color: Colors.blue[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.humidity}: ${_weather!.humidity}%',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.6,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
