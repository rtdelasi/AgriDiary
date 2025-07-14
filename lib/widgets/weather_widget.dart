import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String? _weatherDesc;
  double? _temperature;
  String? _icon;
  String? _locationName;
  bool _loading = true;
  String? _error;
  static const String _apiKey = '8e05be75a960415bb11180128252406';
  String? _lastWeatherDesc;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Initialize notification service
    _notificationService.initialize();
    // Defer heavy operations to prevent blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeather();
    });
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _error = 'Location services are disabled. Please enable them.';
          _loading = false;
        });
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _error =
                'Location permission denied. Please allow location access to get weather updates.';
            _loading = false;
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _error =
              'Location permission permanently denied. Please enable it in app settings.';
          _loading = false;
        });
      }
      return;
    }
  }

  Future<void> _fetchWeather() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      await _checkLocationPermission();
      if (_error != null) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.low),
      );
      await _fetchWeatherData(position);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to fetch weather: ${e.toString()}';
          _loading = false;
        });
      }
    }
  }

  Future<void> _fetchWeatherData(Position position) async {
    try {
      final url =
          'https://api.weatherapi.com/v1/current.json?key=$_apiKey&q=${position.latitude},${position.longitude}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        final location = data['location'];
        final desc = current['condition']['text'];
        final temp = current['temp_c']?.toDouble();
        final icon = current['condition']['icon'];
        final locationName = location['name'];

        // Check for weather changes and send notifications
        if (_lastWeatherDesc != null && _lastWeatherDesc != desc) {
          await _handleWeatherChange(desc, temp);
        }

        if (mounted) {
          setState(() {
            _weatherDesc = desc;
            _temperature = temp;
            _icon = icon;
            _locationName = locationName;
            _lastWeatherDesc = desc;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Connect to the internet';
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connect to the internet';
          _loading = false;
        });
      }
    }
  }

  Future<void> _handleWeatherChange(String newWeather, double? temperature) async {
    String alertTitle = 'Weather Change Alert';
    String alertMessage = 'Weather has changed to: $newWeather';
    
    if (newWeather.toLowerCase().contains('rain') || 
        newWeather.toLowerCase().contains('shower') ||
        newWeather.toLowerCase().contains('drizzle')) {
      alertTitle = 'Rain Alert';
      alertMessage = 'Rain detected in your area. Consider protecting sensitive crops and adjusting irrigation.';
    } else if (newWeather.toLowerCase().contains('storm') || 
               newWeather.toLowerCase().contains('thunder')) {
      alertTitle = 'Storm Alert';
      alertMessage = 'Storm conditions detected. Secure equipment and protect crops from potential damage.';
    } else if (newWeather.toLowerCase().contains('snow') || 
               newWeather.toLowerCase().contains('frost')) {
      alertTitle = 'Cold Weather Alert';
      alertMessage = 'Cold weather detected. Protect frost-sensitive crops and consider covering plants.';
    } else if (newWeather.toLowerCase().contains('sunny') || 
               newWeather.toLowerCase().contains('clear')) {
      alertTitle = 'Clear Weather Alert';
      alertMessage = 'Clear weather conditions. Good time for outdoor farming activities and crop monitoring.';
    } else if (newWeather.toLowerCase().contains('cloudy') || 
               newWeather.toLowerCase().contains('overcast')) {
      alertTitle = 'Cloudy Weather Alert';
      alertMessage = 'Cloudy conditions detected. Monitor light-sensitive crops and adjust watering schedules.';
    }

    // Add temperature information if available
    if (temperature != null) {
      alertMessage += ' Temperature: ${temperature.toStringAsFixed(1)}°C';
    }

    // Send real-time notification
    await _notificationService.showImmediateNotification(alertTitle, alertMessage, 'weather_alert');
  }

  Widget _buildLoadingWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Fetching weather...', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error, size: 40, color: Colors.red),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(_error!, style: const TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              if (_error!.contains('settings'))
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text('Open App Settings'),
                    onPressed: () => openAppSettings(),
                  ),
                ),
              if (_error!.contains('denied'))
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Request Permission Again'),
                    onPressed: _fetchWeather,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (_icon != null)
                Image.network(
                  _icon!.startsWith('//') ? 'https:$_icon' : _icon!,
                  width: 50,
                  height: 50,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.cloud, size: 50),
                ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_locationName != null)
                    Text(
                      _locationName!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Text(
                    '${_temperature?.toStringAsFixed(1) ?? '--'}°C',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _weatherDesc ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchWeather,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoadingWidget();
    }
    if (_error != null) {
      return _buildErrorWidget();
    }
    return _buildWeatherWidget();
  }
}
