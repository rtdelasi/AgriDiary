class RainfallData {
  final DateTime date;
  final double amount; // in mm
  final String location;
  final String? description;
  final double? temperature;
  final double? humidity;

  RainfallData({
    required this.date,
    required this.amount,
    required this.location,
    this.description,
    this.temperature,
    this.humidity,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'location': location,
      'description': description,
      'temperature': temperature,
      'humidity': humidity,
    };
  }

  // Create from JSON
  factory RainfallData.fromJson(Map<String, dynamic> json) {
    return RainfallData(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      description: json['description'],
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
      humidity: json['humidity'] != null ? (json['humidity'] as num).toDouble() : null,
    );
  }
}

class RainfallAnalysis {
  final List<RainfallData> weeklyData;
  final List<RainfallData> monthlyData;
  final double totalWeeklyRainfall;
  final double totalMonthlyRainfall;
  final double averageDailyRainfall;
  final String recommendation;

  RainfallAnalysis({
    required this.weeklyData,
    required this.monthlyData,
    required this.totalWeeklyRainfall,
    required this.totalMonthlyRainfall,
    required this.averageDailyRainfall,
    required this.recommendation,
  });

  // Get rainfall intensity level
  String get intensityLevel {
    if (averageDailyRainfall > 10) return 'Heavy';
    if (averageDailyRainfall > 5) return 'Moderate';
    if (averageDailyRainfall > 2) return 'Light';
    return 'Minimal';
  }

  // Get farming recommendation based on rainfall
  String get farmingRecommendation {
    if (averageDailyRainfall > 15) {
      return 'Heavy rainfall detected. Consider drainage improvements and protect crops from waterlogging.';
    } else if (averageDailyRainfall > 8) {
      return 'Good rainfall for crop growth. Monitor for optimal irrigation timing.';
    } else if (averageDailyRainfall > 3) {
      return 'Moderate rainfall. Consider supplementary irrigation for optimal growth.';
    } else {
      return 'Low rainfall. Implement irrigation systems to maintain crop health.';
    }
  }
} 