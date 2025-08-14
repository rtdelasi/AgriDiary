import 'package:flutter/material.dart';

class CropYieldChart extends StatelessWidget {
  final String cropName;
  final List<Map<String, double>> yieldData;
  final VoidCallback onTap;

  const CropYieldChart({
    super.key,
    required this.cropName,
    required this.yieldData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Chart for $cropName (sample only)'),
        ),
      ),
    );
  }
}

class WeatherChart extends StatelessWidget {
  final String location;
  final List<Map<String, double>> weatherData;
  final String metric;
  final VoidCallback onTap;

  const WeatherChart({
    super.key,
    required this.location,
    required this.weatherData,
    required this.metric,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Weather chart for $location ($metric)'),
        ),
      ),
    );
  }
}
