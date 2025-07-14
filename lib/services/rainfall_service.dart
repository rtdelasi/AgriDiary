import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/rainfall_data.dart';

class RainfallService {
  static final RainfallService _instance = RainfallService._internal();
  factory RainfallService() => _instance;
  RainfallService._internal();

  final Logger _logger = Logger();
  
  // API Keys (you'll need to get these from the respective services)
  static const String _openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY'; // Get from openweathermap.org
  static const String _weatherApiKey = 'YOUR_WEATHERAPI_KEY'; // Get from weatherapi.com
  
  // Cache for rainfall data
  final Map<String, RainfallAnalysis> _rainfallCache = {};
  final Map<String, DateTime> _lastFetchTime = {};

  // Get rainfall data for a specific location
  Future<RainfallAnalysis> getRainfallData(String location) async {
    // Check cache first (cache for 1 hour)
    final now = DateTime.now();
    final lastFetch = _lastFetchTime[location];
    if (lastFetch != null && now.difference(lastFetch).inHours < 1) {
      return _rainfallCache[location] ?? _getMockRainfallData();
    }

    try {
      // Try OpenWeatherMap API first
      final analysis = await _fetchFromOpenWeatherMap(location);
      if (analysis != null) {
        _rainfallCache[location] = analysis;
        _lastFetchTime[location] = now;
        return analysis;
      }

      // Fallback to WeatherAPI
      final weatherApiAnalysis = await _fetchFromWeatherAPI(location);
      if (weatherApiAnalysis != null) {
        _rainfallCache[location] = weatherApiAnalysis;
        _lastFetchTime[location] = now;
        return weatherApiAnalysis;
      }

      // If both APIs fail, return mock data
      return _getMockRainfallData();
    } catch (e) {
      _logger.e('Error fetching rainfall data: $e');
      return _getMockRainfallData();
    }
  }

  // Fetch from OpenWeatherMap API
  Future<RainfallAnalysis?> _fetchFromOpenWeatherMap(String location) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$_openWeatherApiKey&units=metric'
        ),
        headers: {'User-Agent': 'AgriDiary/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseOpenWeatherData(data, location);
      }
    } catch (e) {
      _logger.e('Error fetching from OpenWeatherMap: $e');
    }
    return null;
  }

  // Fetch from WeatherAPI
  Future<RainfallAnalysis?> _fetchFromWeatherAPI(String location) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://api.weatherapi.com/v1/forecast.json?key=$_weatherApiKey&q=$location&days=7&aqi=no'
        ),
        headers: {'User-Agent': 'AgriDiary/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseWeatherAPIData(data, location);
      }
    } catch (e) {
      _logger.e('Error fetching from WeatherAPI: $e');
    }
    return null;
  }

  // Parse OpenWeatherMap data
  RainfallAnalysis _parseOpenWeatherData(Map<String, dynamic> data, String location) {
    final List<RainfallData> weeklyData = [];
    final List<RainfallData> monthlyData = [];
    
    final forecasts = data['list'] as List?;
    if (forecasts != null) {
      for (var forecast in forecasts) {
        final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
        final rain = forecast['rain']?['3h'] ?? 0.0;
        
        final rainfallData = RainfallData(
          date: date,
          amount: (rain as num).toDouble(),
          location: location,
          temperature: (forecast['main']?['temp'] as num?)?.toDouble(),
          humidity: (forecast['main']?['humidity'] as num?)?.toDouble(),
        );
        
        weeklyData.add(rainfallData);
        monthlyData.add(rainfallData);
      }
    }

    final totalWeekly = weeklyData.fold(0.0, (sum, data) => sum + data.amount);
    final totalMonthly = monthlyData.fold(0.0, (sum, data) => sum + data.amount);
    final averageDaily = weeklyData.isNotEmpty ? totalWeekly / weeklyData.length : 0.0;

    return RainfallAnalysis(
      weeklyData: weeklyData,
      monthlyData: monthlyData,
      totalWeeklyRainfall: totalWeekly,
      totalMonthlyRainfall: totalMonthly,
      averageDailyRainfall: averageDaily,
      recommendation: _getRainfallRecommendation(averageDaily),
    );
  }

  // Parse WeatherAPI data
  RainfallAnalysis _parseWeatherAPIData(Map<String, dynamic> data, String location) {
    final List<RainfallData> weeklyData = [];
    final List<RainfallData> monthlyData = [];
    
    final forecasts = data['forecast']?['forecastday'] as List?;
    if (forecasts != null) {
      for (var forecast in forecasts) {
        final date = DateTime.parse(forecast['date']);
        final day = forecast['day'];
        final rain = day['totalprecip_mm'] ?? 0.0;
        
        final rainfallData = RainfallData(
          date: date,
          amount: (rain as num).toDouble(),
          location: location,
          temperature: (day['avgtemp_c'] as num?)?.toDouble(),
          humidity: (day['avghumidity'] as num?)?.toDouble(),
        );
        
        weeklyData.add(rainfallData);
        monthlyData.add(rainfallData);
      }
    }

    final totalWeekly = weeklyData.fold(0.0, (sum, data) => sum + data.amount);
    final totalMonthly = monthlyData.fold(0.0, (sum, data) => sum + data.amount);
    final averageDaily = weeklyData.isNotEmpty ? totalWeekly / weeklyData.length : 0.0;

    return RainfallAnalysis(
      weeklyData: weeklyData,
      monthlyData: monthlyData,
      totalWeeklyRainfall: totalWeekly,
      totalMonthlyRainfall: totalMonthly,
      averageDailyRainfall: averageDaily,
      recommendation: _getRainfallRecommendation(averageDaily),
    );
  }

  // Get rainfall recommendation
  String _getRainfallRecommendation(double averageDaily) {
    if (averageDaily > 15) {
      return 'Heavy rainfall expected. Implement drainage systems and protect crops.';
    } else if (averageDaily > 8) {
      return 'Good rainfall for crop growth. Monitor soil moisture levels.';
    } else if (averageDaily > 3) {
      return 'Moderate rainfall. Consider supplementary irrigation.';
    } else {
      return 'Low rainfall. Implement irrigation systems for optimal crop growth.';
    }
  }

  // Mock data for development/testing
  RainfallAnalysis _getMockRainfallData() {
    final List<RainfallData> weeklyData = [
      RainfallData(date: DateTime.now().subtract(const Duration(days: 6)), amount: 8.5, location: 'Farm Location'),
      RainfallData(date: DateTime.now().subtract(const Duration(days: 5)), amount: 12.3, location: 'Farm Location'),
      RainfallData(date: DateTime.now().subtract(const Duration(days: 4)), amount: 15.7, location: 'Farm Location'),
      RainfallData(date: DateTime.now().subtract(const Duration(days: 3)), amount: 6.2, location: 'Farm Location'),
      RainfallData(date: DateTime.now().subtract(const Duration(days: 2)), amount: 18.9, location: 'Farm Location'),
      RainfallData(date: DateTime.now().subtract(const Duration(days: 1)), amount: 10.4, location: 'Farm Location'),
      RainfallData(date: DateTime.now(), amount: 14.1, location: 'Farm Location'),
    ];

    final totalWeekly = weeklyData.fold(0.0, (sum, data) => sum + data.amount);
    final averageDaily = totalWeekly / weeklyData.length;

    return RainfallAnalysis(
      weeklyData: weeklyData,
      monthlyData: weeklyData, // For demo, using same data
      totalWeeklyRainfall: totalWeekly,
      totalMonthlyRainfall: totalWeekly * 4, // Approximate
      averageDailyRainfall: averageDaily,
      recommendation: _getRainfallRecommendation(averageDaily),
    );
  }

  // Clear cache
  void clearCache() {
    _rainfallCache.clear();
    _lastFetchTime.clear();
  }
} 