import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String location;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final VoidCallback? onTap;
  final bool isLoading;

  const WeatherCard({
    super.key,
    required this.location,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    this.onTap,
    this.isLoading = false,
  });

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.water_drop;
      case 'stormy':
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snowy':
      case 'snow':
        return Icons.ac_unit;
      case 'foggy':
      case 'mist':
        return Icons.cloud;
      default:
        return Icons.cloud;
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Colors.orange;
      case 'cloudy':
      case 'overcast':
        return Colors.grey;
      case 'rainy':
      case 'rain':
        return Colors.blue;
      case 'stormy':
      case 'thunderstorm':
        return Colors.purple;
      case 'snowy':
      case 'snow':
        return Colors.cyan;
      case 'foggy':
      case 'mist':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.refresh,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _getWeatherColor(condition).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getWeatherIcon(condition),
                      size: 32,
                      color: _getWeatherColor(condition),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${temperature.toInt()}',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '°C',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          condition,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildWeatherDetail(
                      context,
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '$humidity%',
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildWeatherDetail(
                      context,
                      icon: Icons.air,
                      label: 'Wind',
                      value: '${windSpeed.toStringAsFixed(1)} km/h',
                      subtitle: windDirection,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

// Compact weather card for dashboard
class CompactWeatherCard extends StatelessWidget {
  final String location;
  final double temperature;
  final String condition;
  final VoidCallback? onTap;

  const CompactWeatherCard({
    super.key,
    required this.location,
    required this.temperature,
    required this.condition,
    this.onTap,
  });

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.water_drop;
      case 'stormy':
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snowy':
      case 'snow':
        return Icons.ac_unit;
      case 'foggy':
      case 'mist':
        return Icons.cloud;
      default:
        return Icons.cloud;
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Colors.orange;
      case 'cloudy':
      case 'overcast':
        return Colors.grey;
      case 'rainy':
      case 'rain':
        return Colors.blue;
      case 'stormy':
      case 'thunderstorm':
        return Colors.purple;
      case 'snowy':
      case 'snow':
        return Colors.cyan;
      case 'foggy':
      case 'mist':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Weather icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getWeatherColor(condition).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getWeatherIcon(condition),
                  size: 20,
                  color: _getWeatherColor(condition),
                ),
              ),

              const SizedBox(width: 12),

              // Temperature and location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${temperature.toInt()}°C',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
