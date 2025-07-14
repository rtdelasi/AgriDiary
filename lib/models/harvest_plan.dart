class HarvestPlan {
  final String id;
  final String cropName;
  final int plantedSeedlings;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final double expectedYieldPerPlant; // in kg
  final double totalExpectedYield; // in kg
  final double? actualYield; // in kg
  final DateTime? actualHarvestDate;
  final String notes;
  final bool isCompleted;

  HarvestPlan({
    required this.id,
    required this.cropName,
    required this.plantedSeedlings,
    required this.plantingDate,
    required this.expectedHarvestDate,
    required this.expectedYieldPerPlant,
    required this.totalExpectedYield,
    this.actualYield,
    this.actualHarvestDate,
    this.notes = '',
    this.isCompleted = false,
  });

  // Calculate yield efficiency
  double get yieldEfficiency {
    if (actualYield == null) return 0.0;
    return (actualYield! / totalExpectedYield) * 100;
  }

  // Check if target was reached
  bool get targetReached {
    if (actualYield == null) return false;
    return actualYield! >= totalExpectedYield;
  }

  // Get insights based on performance
  String get performanceInsight {
    if (actualYield == null) return 'Harvest not completed yet';
    
    if (targetReached) {
      return 'Excellent! Target yield achieved. Consider expanding this crop.';
    } else if (yieldEfficiency >= 80) {
      return 'Good performance. Slight improvements in irrigation or fertilization could help reach target.';
    } else if (yieldEfficiency >= 60) {
      return 'Moderate performance. Review soil conditions and pest management.';
    } else {
      return 'Below target. Consider soil testing, pest control, and irrigation improvements.';
    }
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'plantedSeedlings': plantedSeedlings,
      'plantingDate': plantingDate.toIso8601String(),
      'expectedHarvestDate': expectedHarvestDate.toIso8601String(),
      'expectedYieldPerPlant': expectedYieldPerPlant,
      'totalExpectedYield': totalExpectedYield,
      'actualYield': actualYield,
      'actualHarvestDate': actualHarvestDate?.toIso8601String(),
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  // Create from JSON
  factory HarvestPlan.fromJson(Map<String, dynamic> json) {
    return HarvestPlan(
      id: json['id'] ?? '',
      cropName: json['cropName'] ?? '',
      plantedSeedlings: json['plantedSeedlings'] ?? 0,
      plantingDate: DateTime.parse(json['plantingDate']),
      expectedHarvestDate: DateTime.parse(json['expectedHarvestDate']),
      expectedYieldPerPlant: (json['expectedYieldPerPlant'] ?? 0.0).toDouble(),
      totalExpectedYield: (json['totalExpectedYield'] ?? 0.0).toDouble(),
      actualYield: json['actualYield'] != null ? (json['actualYield'] as num).toDouble() : null,
      actualHarvestDate: json['actualHarvestDate'] != null ? DateTime.parse(json['actualHarvestDate']) : null,
      notes: json['notes'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  // Create a copy with updated values
  HarvestPlan copyWith({
    String? id,
    String? cropName,
    int? plantedSeedlings,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    double? expectedYieldPerPlant,
    double? totalExpectedYield,
    double? actualYield,
    DateTime? actualHarvestDate,
    String? notes,
    bool? isCompleted,
  }) {
    return HarvestPlan(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      plantedSeedlings: plantedSeedlings ?? this.plantedSeedlings,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      expectedYieldPerPlant: expectedYieldPerPlant ?? this.expectedYieldPerPlant,
      totalExpectedYield: totalExpectedYield ?? this.totalExpectedYield,
      actualYield: actualYield ?? this.actualYield,
      actualHarvestDate: actualHarvestDate ?? this.actualHarvestDate,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
} 