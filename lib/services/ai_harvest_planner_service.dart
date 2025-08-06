import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/harvest_plan.dart';

class AIHarvestPlannerService {
  static final AIHarvestPlannerService _instance = AIHarvestPlannerService._internal();
  factory AIHarvestPlannerService() => _instance;
  AIHarvestPlannerService._internal();

  final Logger _logger = Logger();
  static const String _storageKey = 'ai_harvest_plans';

  // AI-enhanced crop data with dynamic factors
  static const Map<String, Map<String, dynamic>> _aiCropData = {
    'Corn': {
      'baseYield': 0.25,
      'growthPeriod': 90,
      'optimalTemp': {'min': 10, 'max': 30},
      'optimalRainfall': {'min': 500, 'max': 800},
      'marketVolatility': 0.15,
    },
    'Wheat': {
      'baseYield': 0.15,
      'growthPeriod': 120,
      'optimalTemp': {'min': 15, 'max': 25},
      'optimalRainfall': {'min': 400, 'max': 600},
      'marketVolatility': 0.12,
    },
    'Soybeans': {
      'baseYield': 0.20,
      'growthPeriod': 100,
      'optimalTemp': {'min': 20, 'max': 35},
      'optimalRainfall': {'min': 450, 'max': 700},
      'marketVolatility': 0.18,
    },
    'Rice': {
      'baseYield': 0.30,
      'growthPeriod': 110,
      'optimalTemp': {'min': 20, 'max': 35},
      'optimalRainfall': {'min': 1000, 'max': 1500},
      'marketVolatility': 0.20,
    },
    'Tomato': {
      'baseYield': 2.5,
      'growthPeriod': 70,
      'optimalTemp': {'min': 18, 'max': 30},
      'optimalRainfall': {'min': 300, 'max': 500},
      'marketVolatility': 0.25,
    },
    'Potato': {
      'baseYield': 0.8,
      'growthPeriod': 100,
      'optimalTemp': {'min': 15, 'max': 25},
      'optimalRainfall': {'min': 400, 'max': 600},
      'marketVolatility': 0.16,
    },
    'Maize': {
      'baseYield': 0.25,
      'growthPeriod': 90,
      'optimalTemp': {'min': 10, 'max': 30},
      'optimalRainfall': {'min': 500, 'max': 800},
      'marketVolatility': 0.15,
    },
  };

  // AI Prediction Model
  Future<Map<String, dynamic>> predictOptimalPlantingTime({
    required String cropName,
    required String location,
    required DateTime targetHarvestDate,
  }) async {
    try {
      // Get weather forecast
      final weatherData = await _getWeatherForecast(location);
      
      // Get historical performance data
      final historicalData = await _getHistoricalPerformance(cropName);
      
      // Calculate optimal planting window
      final optimalWindow = _calculateOptimalPlantingWindow(
        cropName,
        weatherData,
        targetHarvestDate,
      );
      
      // Predict yield based on conditions
      final predictedYield = await _predictYield(
        cropName,
        weatherData,
        historicalData,
      );
      
      // Calculate risk factors
      final riskFactors = _calculateRiskFactors(
        cropName,
        weatherData,
        historicalData,
      );
      
      return {
        'optimalPlantingDate': optimalWindow['optimalDate'],
        'plantingWindow': optimalWindow['window'],
        'predictedYield': predictedYield,
        'confidence': optimalWindow['confidence'],
        'riskFactors': riskFactors,
        'recommendations': _generateRecommendations(
          cropName,
          weatherData,
          riskFactors,
        ),
      };
    } catch (e) {
      _logger.e('Error predicting optimal planting time: $e');
      return _getFallbackPrediction(cropName, targetHarvestDate);
    }
  }

  // AI-powered yield prediction
  Future<double> _predictYield(
    String cropName,
    Map<String, dynamic> weatherData,
    Map<String, dynamic> historicalData,
  ) async {
    final cropData = _aiCropData[cropName];
    if (cropData == null) return 0.5;

    // Base yield from crop data
    double baseYield = cropData['baseYield'];
    
    // Weather factor (0.7 to 1.3)
    double weatherFactor = _calculateWeatherFactor(weatherData, cropData);
    
    // Historical performance factor (0.8 to 1.2)
    double historicalFactor = _calculateHistoricalFactor(historicalData);
    
    // Seasonal factor (0.9 to 1.1)
    double seasonalFactor = _calculateSeasonalFactor();
    
    // Market factor (0.95 to 1.05)
    double marketFactor = _calculateMarketFactor(cropName);
    
    // Calculate final predicted yield
    double predictedYield = baseYield * weatherFactor * historicalFactor * 
                           seasonalFactor * marketFactor;
    
    // Add some randomness for realistic predictions
    final random = Random();
    double noise = 0.9 + (random.nextDouble() * 0.2); // ±10% noise
    
    return predictedYield * noise;
  }

  // Calculate weather factor based on optimal conditions
  double _calculateWeatherFactor(
    Map<String, dynamic> weatherData,
    Map<String, dynamic> cropData,
  ) {
    final optimalTemp = cropData['optimalTemp'];
    final optimalRainfall = cropData['optimalRainfall'];
    
    double tempFactor = 1.0;
    double rainfallFactor = 1.0;
    
    if (weatherData['temperature'] != null) {
      final temp = weatherData['temperature'];
      if (temp >= optimalTemp['min'] && temp <= optimalTemp['max']) {
        tempFactor = 1.0;
      } else if (temp < optimalTemp['min']) {
        tempFactor = 0.7 + (temp / optimalTemp['min']) * 0.3;
      } else {
        tempFactor = 1.0 - ((temp - optimalTemp['max']) / optimalTemp['max']) * 0.3;
      }
    }
    
    if (weatherData['rainfall'] != null) {
      final rainfall = weatherData['rainfall'];
      if (rainfall >= optimalRainfall['min'] && rainfall <= optimalRainfall['max']) {
        rainfallFactor = 1.0;
      } else if (rainfall < optimalRainfall['min']) {
        rainfallFactor = 0.7 + (rainfall / optimalRainfall['min']) * 0.3;
      } else {
        rainfallFactor = 1.0 - ((rainfall - optimalRainfall['max']) / optimalRainfall['max']) * 0.3;
      }
    }
    
    return (tempFactor + rainfallFactor) / 2;
  }

  // Calculate historical performance factor
  double _calculateHistoricalFactor(Map<String, dynamic> historicalData) {
    if (historicalData.isEmpty) return 1.0;
    
    final avgEfficiency = historicalData['averageEfficiency'] ?? 80.0;
    return (avgEfficiency / 100.0) * 0.4 + 0.8; // Scale to 0.8-1.2 range
  }

  // Calculate seasonal factor
  double _calculateSeasonalFactor() {
    final now = DateTime.now();
    final month = now.month;
    
    // Spring (Mar-May) and Fall (Sep-Nov) are generally better
    if (month >= 3 && month <= 5) return 1.1; // Spring
    if (month >= 9 && month <= 11) return 1.05; // Fall
    if (month >= 6 && month <= 8) return 0.95; // Summer
    return 0.9; // Winter
  }

  // Calculate market factor
  double _calculateMarketFactor(String cropName) {
    final cropData = _aiCropData[cropName];
    if (cropData == null) return 1.0;
    
    final volatility = cropData['marketVolatility'];
    final random = Random();
    
    // Simulate market fluctuations
    double marketFactor = 1.0 + (random.nextDouble() - 0.5) * volatility;
    return marketFactor.clamp(0.95, 1.05);
  }

  // Calculate optimal planting window
  Map<String, dynamic> _calculateOptimalPlantingWindow(
    String cropName,
    Map<String, dynamic> weatherData,
    DateTime targetHarvestDate,
  ) {
    final cropData = _aiCropData[cropName];
    if (cropData == null) {
      return {
        'optimalDate': DateTime.now(),
        'window': [DateTime.now(), DateTime.now().add(Duration(days: 7))],
        'confidence': 0.5,
      };
    }
    
    final growthPeriod = cropData['growthPeriod'];
    final optimalPlantingDate = targetHarvestDate.subtract(Duration(days: growthPeriod));
    
    // Adjust based on weather conditions
    DateTime adjustedDate = optimalPlantingDate;
    double confidence = 0.8;
    
    if (weatherData['temperature'] != null) {
      final temp = weatherData['temperature'];
      final optimalTemp = cropData['optimalTemp'];
      
      if (temp < optimalTemp['min']) {
        adjustedDate = adjustedDate.add(Duration(days: 7));
        confidence -= 0.1;
      } else if (temp > optimalTemp['max']) {
        adjustedDate = adjustedDate.subtract(Duration(days: 3));
        confidence -= 0.05;
      }
    }
    
    // Create planting window (±5 days)
    final windowStart = adjustedDate.subtract(Duration(days: 5));
    final windowEnd = adjustedDate.add(Duration(days: 5));
    
    return {
      'optimalDate': adjustedDate,
      'window': [windowStart, windowEnd],
      'confidence': confidence.clamp(0.3, 0.95),
    };
  }

  // Calculate risk factors
  Map<String, dynamic> _calculateRiskFactors(
    String cropName,
    Map<String, dynamic> weatherData,
    Map<String, dynamic> historicalData,
  ) {
    final risks = <String, double>{};
    
    // Weather risks
    if (weatherData['temperature'] != null) {
      final temp = weatherData['temperature'];
      final cropData = _aiCropData[cropName];
      if (cropData != null) {
        final optimalTemp = cropData['optimalTemp'];
        if (temp < optimalTemp['min'] || temp > optimalTemp['max']) {
          risks['temperature'] = 0.3;
        }
      }
    }
    
    // Rainfall risks
    if (weatherData['rainfall'] != null) {
      final rainfall = weatherData['rainfall'];
      final cropData = _aiCropData[cropName];
      if (cropData != null) {
        final optimalRainfall = cropData['optimalRainfall'];
        if (rainfall < optimalRainfall['min'] || rainfall > optimalRainfall['max']) {
          risks['rainfall'] = 0.4;
        }
      }
    }
    
    // Historical performance risks
    if (historicalData.isNotEmpty) {
      final avgEfficiency = historicalData['averageEfficiency'] ?? 80.0;
      if (avgEfficiency < 70.0) {
        risks['historical_performance'] = 0.5;
      }
    }
    
    return risks;
  }

  // Generate AI recommendations
  List<String> _generateRecommendations(
    String cropName,
    Map<String, dynamic> weatherData,
    Map<String, dynamic> riskFactors,
  ) {
    final recommendations = <String>[];
    final cropData = _aiCropData[cropName];
    
    if (cropData == null) {
      recommendations.add('Consider soil testing before planting.');
      return recommendations;
    }
    
    // Weather-based recommendations
    if (weatherData['temperature'] != null) {
      final temp = weatherData['temperature'];
      final optimalTemp = cropData['optimalTemp'];
      
      if (temp < optimalTemp['min']) {
        recommendations.add('Consider using cold-resistant varieties or delaying planting.');
      } else if (temp > optimalTemp['max']) {
        recommendations.add('Ensure adequate irrigation and consider shade structures.');
      }
    }
    
    if (weatherData['rainfall'] != null) {
      final rainfall = weatherData['rainfall'];
      final optimalRainfall = cropData['optimalRainfall'];
      
      if (rainfall < optimalRainfall['min']) {
        recommendations.add('Implement irrigation systems to supplement rainfall.');
      } else if (rainfall > optimalRainfall['max']) {
        recommendations.add('Ensure proper drainage to prevent waterlogging.');
      }
    }
    
    // Risk-based recommendations
    if (riskFactors['temperature'] != null) {
      recommendations.add('Monitor temperature fluctuations and adjust planting schedule.');
    }
    
    if (riskFactors['rainfall'] != null) {
      recommendations.add('Implement water management strategies.');
    }
    
    if (riskFactors['historical_performance'] != null) {
      recommendations.add('Review previous harvest data and consider soil improvement.');
    }
    
    // General recommendations
    recommendations.add('Monitor crop health regularly and adjust care accordingly.');
    recommendations.add('Keep detailed records for future AI predictions.');
    
    return recommendations;
  }

  // Get weather forecast from API
  Future<Map<String, dynamic>> _getWeatherForecast(String location) async {
    try {
      // For demo purposes, return simulated weather data
      // In production, integrate with actual weather API
      return {
        'temperature': 22.0 + (Random().nextDouble() - 0.5) * 10,
        'rainfall': 500.0 + (Random().nextDouble() - 0.5) * 200,
        'humidity': 60.0 + (Random().nextDouble() - 0.5) * 20,
        'windSpeed': 5.0 + Random().nextDouble() * 10,
      };
    } catch (e) {
      _logger.e('Error getting weather forecast: $e');
      return {};
    }
  }

  // Get historical performance data
  Future<Map<String, dynamic>> _getHistoricalPerformance(String cropName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getStringList(_storageKey) ?? [];
      
      final plans = plansJson
          .map((planJson) => HarvestPlan.fromJson(json.decode(planJson)))
          .where((plan) => plan.cropName == cropName && plan.isCompleted)
          .toList();
      
      if (plans.isEmpty) return {};
      
      final totalEfficiency = plans.fold(0.0, (sum, plan) => sum + plan.yieldEfficiency);
      final averageEfficiency = totalEfficiency / plans.length;
      
      return {
        'totalPlans': plans.length,
        'averageEfficiency': averageEfficiency,
        'bestYield': plans.fold(0.0, (max, plan) => 
          plan.actualYield != null && plan.actualYield! > max ? plan.actualYield! : max),
        'worstYield': plans.fold(double.infinity, (min, plan) => 
          plan.actualYield != null && plan.actualYield! < min ? plan.actualYield! : min),
      };
    } catch (e) {
      _logger.e('Error getting historical performance: $e');
      return {};
    }
  }

  // Fallback prediction when AI fails
  Map<String, dynamic> _getFallbackPrediction(String cropName, DateTime targetHarvestDate) {
    final cropData = _aiCropData[cropName];
    if (cropData == null) {
      return {
        'optimalPlantingDate': DateTime.now(),
        'plantingWindow': [DateTime.now(), DateTime.now().add(Duration(days: 7))],
        'predictedYield': 0.5,
        'confidence': 0.3,
        'riskFactors': {},
        'recommendations': ['Use traditional farming methods as fallback.'],
      };
    }
    
    final growthPeriod = cropData['growthPeriod'];
    final optimalDate = targetHarvestDate.subtract(Duration(days: growthPeriod));
    
    return {
      'optimalPlantingDate': optimalDate,
      'plantingWindow': [optimalDate.subtract(Duration(days: 7)), optimalDate.add(Duration(days: 7))],
      'predictedYield': cropData['baseYield'],
      'confidence': 0.5,
      'riskFactors': {'fallback_mode': 0.5},
      'recommendations': ['AI prediction unavailable. Using standard crop data.'],
    };
  }

  // Create AI-enhanced harvest plan
  Future<HarvestPlan> createAIHarvestPlan({
    required String cropName,
    required int plantedSeedlings,
    required DateTime plantingDate,
    required String location,
    String notes = '',
  }) async {
    // Get AI predictions
    final predictions = await predictOptimalPlantingTime(
      cropName: cropName,
      location: location,
      targetHarvestDate: plantingDate.add(Duration(days: _aiCropData[cropName]?['growthPeriod'] ?? 90)),
    );
    
    // Use AI-predicted yield instead of hard-coded values
    final predictedYieldPerPlant = (predictions['predictedYield'] as num?)?.toDouble() ?? 0.5;
    final totalExpectedYield = plantedSeedlings * predictedYieldPerPlant;
    
    // Calculate expected harvest date with AI adjustments
    final growthPeriod = _aiCropData[cropName]?['growthPeriod'] ?? 90;
    final expectedHarvestDate = plantingDate.add(Duration(days: growthPeriod));
    
    final plan = HarvestPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cropName: cropName,
      plantedSeedlings: plantedSeedlings,
      plantingDate: plantingDate,
      expectedHarvestDate: expectedHarvestDate,
      expectedYieldPerPlant: predictedYieldPerPlant,
      totalExpectedYield: totalExpectedYield,
      notes: '$notes\n\nAI Predictions:\n- Confidence: ${(predictions['confidence'] * 100).toStringAsFixed(1)}%\n- Risk Factors: ${predictions['riskFactors'].keys.join(', ')}\n- Recommendations: ${predictions['recommendations'].join('; ')}',
    );

    // Save the plan
    final plans = await loadHarvestPlans();
    plans.add(plan);
    await saveHarvestPlans(plans);

    return plan;
  }

  // Load harvest plans
  Future<List<HarvestPlan>> loadHarvestPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getStringList(_storageKey) ?? [];
      
      return plansJson
          .map((planJson) => HarvestPlan.fromJson(json.decode(planJson)))
          .toList();
    } catch (e) {
      _logger.e('Error loading harvest plans: $e');
      return [];
    }
  }

  // Save harvest plans
  Future<void> saveHarvestPlans(List<HarvestPlan> plans) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = plans
          .map((plan) => json.encode(plan.toJson()))
          .toList();
      await prefs.setStringList(_storageKey, plansJson);
    } catch (e) {
      _logger.e('Error saving harvest plans: $e');
    }
  }

  // Get AI insights
  Future<Map<String, dynamic>> getAIInsights() async {
    final plans = await loadHarvestPlans();
    final completedPlans = plans.where((plan) => plan.isCompleted).toList();
    
    if (completedPlans.isEmpty) {
      return {
        'aiAccuracy': 0.0,
        'predictionConfidence': 0.0,
        'recommendations': ['Start using AI predictions to get insights'],
        'performanceTrend': 'No data',
      };
    }

    // Calculate AI prediction accuracy
    double totalAccuracy = 0.0;
    int validPredictions = 0;
    
    for (final plan in completedPlans) {
      if (plan.actualYield != null && plan.totalExpectedYield > 0) {
        final accuracy = (plan.actualYield! / plan.totalExpectedYield).clamp(0.0, 2.0);
        totalAccuracy += accuracy;
        validPredictions++;
      }
    }
    
    final averageAccuracy = validPredictions > 0 ? totalAccuracy / validPredictions : 0.0;
    
    // Generate AI-specific recommendations
    final recommendations = <String>[];
    if (averageAccuracy < 0.8) {
      recommendations.add('AI predictions need improvement. Consider providing more detailed input data.');
    } else if (averageAccuracy < 0.9) {
      recommendations.add('Good AI accuracy. Fine-tune predictions with local weather data.');
    } else {
      recommendations.add('Excellent AI accuracy! Consider expanding AI predictions to other crops.');
    }
    
    return {
      'aiAccuracy': averageAccuracy * 100,
      'predictionConfidence': 85.0, // Simulated confidence
      'recommendations': recommendations,
      'performanceTrend': averageAccuracy > 0.9 ? 'Improving' : 'Stable',
    };
  }
} 