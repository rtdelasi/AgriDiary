import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/harvest_plan.dart';

class HarvestPlannerService {
  static final HarvestPlannerService _instance = HarvestPlannerService._internal();
  factory HarvestPlannerService() => _instance;
  HarvestPlannerService._internal();

  final Logger _logger = Logger();
  static const String _storageKey = 'harvest_plans';

  // Crop yield expectations (kg per plant) - based on agricultural research
  static const Map<String, double> _cropYieldExpectations = {
    'Corn': 0.25, // 250g per plant
    'Wheat': 0.15, // 150g per plant
    'Soybeans': 0.20, // 200g per plant
    'Rice': 0.30, // 300g per plant
    'Cotton': 0.10, // 100g per plant
    'Tomato': 2.5, // 2.5kg per plant
    'Potato': 0.8, // 800g per plant
    'Maize': 0.25, // 250g per plant
  };

  // Growth periods (days from planting to harvest)
  static const Map<String, int> _growthPeriods = {
    'Corn': 90,
    'Wheat': 120,
    'Soybeans': 100,
    'Rice': 110,
    'Cotton': 150,
    'Tomato': 70,
    'Potato': 100,
    'Maize': 90,
  };

  // Load all harvest plans
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

  // Create a new harvest plan
  Future<HarvestPlan> createHarvestPlan({
    required String cropName,
    required int plantedSeedlings,
    required DateTime plantingDate,
    String notes = '',
  }) async {
    final expectedYieldPerPlant = _cropYieldExpectations[cropName] ?? 0.5;
    final totalExpectedYield = plantedSeedlings * expectedYieldPerPlant;
    final growthPeriod = _growthPeriods[cropName] ?? 90;
    final expectedHarvestDate = plantingDate.add(Duration(days: growthPeriod));

    final plan = HarvestPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cropName: cropName,
      plantedSeedlings: plantedSeedlings,
      plantingDate: plantingDate,
      expectedHarvestDate: expectedHarvestDate,
      expectedYieldPerPlant: expectedYieldPerPlant,
      totalExpectedYield: totalExpectedYield,
      notes: notes,
    );

    final plans = await loadHarvestPlans();
    plans.add(plan);
    await saveHarvestPlans(plans);

    return plan;
  }

  // Update harvest plan with actual yield
  Future<void> updateHarvestPlan(String planId, {
    double? actualYield,
    DateTime? actualHarvestDate,
    String? notes,
    bool? isCompleted,
  }) async {
    final plans = await loadHarvestPlans();
    final planIndex = plans.indexWhere((plan) => plan.id == planId);
    
    if (planIndex != -1) {
      final updatedPlan = plans[planIndex].copyWith(
        actualYield: actualYield,
        actualHarvestDate: actualHarvestDate,
        notes: notes,
        isCompleted: isCompleted,
      );
      plans[planIndex] = updatedPlan;
      await saveHarvestPlans(plans);
    }
  }

  // Delete harvest plan
  Future<void> deleteHarvestPlan(String planId) async {
    final plans = await loadHarvestPlans();
    plans.removeWhere((plan) => plan.id == planId);
    await saveHarvestPlans(plans);
  }

  // Get insights from harvest plans
  Future<Map<String, dynamic>> getHarvestInsights() async {
    final plans = await loadHarvestPlans();
    final completedPlans = plans.where((plan) => plan.isCompleted).toList();
    
    if (completedPlans.isEmpty) {
      return {
        'totalPlans': plans.length,
        'completedPlans': 0,
        'averageEfficiency': 0.0,
        'bestPerformingCrop': 'No data',
        'recommendations': ['Start tracking your harvests to get insights'],
      };
    }

    // Calculate insights
    final totalEfficiency = completedPlans.fold(0.0, (sum, plan) => sum + plan.yieldEfficiency);
    final averageEfficiency = totalEfficiency / completedPlans.length;

    // Find best performing crop
    final cropPerformance = <String, List<double>>{};
    for (final plan in completedPlans) {
      cropPerformance.putIfAbsent(plan.cropName, () => []).add(plan.yieldEfficiency);
    }

    String bestPerformingCrop = 'No data';
    double bestAverage = 0.0;
    for (final entry in cropPerformance.entries) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (average > bestAverage) {
        bestAverage = average;
        bestPerformingCrop = entry.key;
      }
    }

    // Generate recommendations
    final recommendations = <String>[];
    if (averageEfficiency < 60) {
      recommendations.add('Overall yield efficiency is low. Consider soil testing and improved irrigation.');
    } else if (averageEfficiency < 80) {
      recommendations.add('Good performance. Focus on pest management and fertilization timing.');
    } else {
      recommendations.add('Excellent performance! Consider expanding successful crops.');
    }

    if (cropPerformance.length > 1) {
      recommendations.add('Diversify crops based on performance data.');
    }

    return {
      'totalPlans': plans.length,
      'completedPlans': completedPlans.length,
      'averageEfficiency': averageEfficiency,
      'bestPerformingCrop': bestPerformingCrop,
      'recommendations': recommendations,
    };
  }

  // Get crop yield expectations
  double getCropYieldExpectation(String cropName) {
    return _cropYieldExpectations[cropName] ?? 0.5;
  }

  // Get crop growth period
  int getCropGrowthPeriod(String cropName) {
    return _growthPeriods[cropName] ?? 90;
  }

  // Get available crops
  List<String> getAvailableCrops() {
    return _cropYieldExpectations.keys.toList();
  }

  // Get upcoming harvests
  Future<List<HarvestPlan>> getUpcomingHarvests() async {
    final plans = await loadHarvestPlans();
    final now = DateTime.now();
    
    return plans
        .where((plan) => !plan.isCompleted && plan.expectedHarvestDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.expectedHarvestDate.compareTo(b.expectedHarvestDate));
  }

  // Get overdue harvests
  Future<List<HarvestPlan>> getOverdueHarvests() async {
    final plans = await loadHarvestPlans();
    final now = DateTime.now();
    
    return plans
        .where((plan) => !plan.isCompleted && plan.expectedHarvestDate.isBefore(now))
        .toList()
      ..sort((a, b) => a.expectedHarvestDate.compareTo(b.expectedHarvestDate));
  }

  // Get harvest plans by crop
  Future<List<HarvestPlan>> getHarvestPlansByCrop(String cropName) async {
    final plans = await loadHarvestPlans();
    return plans.where((plan) => plan.cropName == cropName).toList();
  }

  // Get harvest statistics
  Future<Map<String, dynamic>> getHarvestStatistics() async {
    final plans = await loadHarvestPlans();
    final completedPlans = plans.where((plan) => plan.isCompleted).toList();
    
    if (completedPlans.isEmpty) {
      return {
        'totalPlanted': 0,
        'totalHarvested': 0.0,
        'totalExpected': 0.0,
        'successRate': 0.0,
      };
    }

    final totalPlanted = completedPlans.fold(0, (sum, plan) => sum + plan.plantedSeedlings);
    final totalHarvested = completedPlans.fold(0.0, (sum, plan) => sum + (plan.actualYield ?? 0));
    final totalExpected = completedPlans.fold(0.0, (sum, plan) => sum + plan.totalExpectedYield);
    final successRate = (totalHarvested / totalExpected) * 100;

    return {
      'totalPlanted': totalPlanted,
      'totalHarvested': totalHarvested,
      'totalExpected': totalExpected,
      'successRate': successRate,
    };
  }
} 