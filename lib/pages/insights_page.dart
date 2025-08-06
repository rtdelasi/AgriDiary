import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import '../services/crop_info_service.dart';
import '../services/notification_service.dart';
import '../services/rainfall_service.dart';
import '../services/market_service.dart';
import '../services/harvest_planner_service.dart';
import '../services/ai_harvest_planner_service.dart';
import '../models/harvest_plan.dart';
import '../models/rainfall_data.dart';
import '../models/market_data.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  int _selectedCropIndex = 0;
  final List<String> _crops = [
    'Corn',
    'Wheat',
    'Soybeans',
    'Rice',
    'Cotton',
    'Tomato',
    'Potato',
    'Maize',
  ];
  final CropInfoService _cropInfoService = CropInfoService();
  final NotificationService _notificationService = NotificationService();
  final RainfallService _rainfallService = RainfallService();
  final MarketService _marketService = MarketService();
  final HarvestPlannerService _harvestPlannerService = HarvestPlannerService();
  final AIHarvestPlannerService _aiHarvestPlannerService = AIHarvestPlannerService();
  final Logger _logger = Logger();

  Map<String, String> _currentCropInfo = {};
  bool _isLoadingCropInfo = false;
  bool _isLoadingRainfall = false;
  bool _isLoadingMarket = false;
  bool _isLoadingHarvest = false;

  RainfallAnalysis? _rainfallAnalysis;
  MarketTrends? _marketTrends;
  List<HarvestPlan> _harvestPlans = [];
  Map<String, dynamic> _harvestInsights = {};
  Map<String, dynamic> _harvestStatistics = {};
  Map<String, dynamic> _aiInsights = {};
  bool _isLoadingAI = false;

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadCropInfo(_crops[_selectedCropIndex]),
      _loadRainfallData(),
      _loadMarketData(),
      _loadHarvestData(),
      _loadAIData(),
    ]);
  }

  Future<void> _loadCropInfo(String cropName) async {
    if (!mounted) return;
    setState(() {
      _isLoadingCropInfo = true;
    });

    try {
      final cropInfo = await _cropInfoService.getCropInfo(cropName);
      if (!mounted) return;
      setState(() {
        _currentCropInfo = cropInfo;
        _isLoadingCropInfo = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCropInfo = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading crop information: $e')),
        );
      }
    }
  }

  Future<void> _loadRainfallData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingRainfall = true;
    });

    try {
      final rainfallData = await _rainfallService.getRainfallData(
        'Farm Location',
      );
      if (!mounted) return;
      setState(() {
        _rainfallAnalysis = rainfallData;
        _isLoadingRainfall = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingRainfall = false;
      });
      _logger.e('Error loading rainfall data: $e');
    }
  }

  Future<void> _loadMarketData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMarket = true;
    });

    try {
      final marketData = await _marketService.getMarketData(_crops);
      if (!mounted) return;
      setState(() {
        _marketTrends = marketData;
        _isLoadingMarket = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMarket = false;
      });
      _logger.e('Error loading market data: $e');
    }
  }

  Future<void> _loadHarvestData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingHarvest = true;
    });

    try {
      final plans = await _harvestPlannerService.loadHarvestPlans();
      final insights = await _harvestPlannerService.getHarvestInsights();
      final statistics = await _harvestPlannerService.getHarvestStatistics();

      if (!mounted) return;
      setState(() {
        _harvestPlans = plans;
        _harvestInsights = insights;
        _harvestStatistics = statistics;
        _isLoadingHarvest = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingHarvest = false;
      });
      _logger.e('Error loading harvest data: $e');
    }
  }

  Future<void> _loadAIData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingAI = true;
    });

    try {
      final aiInsights = await _aiHarvestPlannerService.getAIInsights();
      if (!mounted) return;
      setState(() {
        _aiInsights = aiInsights;
        _isLoadingAI = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingAI = false;
      });
      _logger.e('Error loading AI data: $e');
    }
  }

  Future<void> _sendPestAlert() async {
    try {
      final cropName = _crops[_selectedCropIndex];
      await _notificationService.showImmediateNotification(
        'Pest Alert: $cropName',
        'Potential pest activity detected in your $cropName field. Please inspect your crops and consider preventive measures.',
        'pest_alert',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pest alert notification sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending pest alert: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Farm Insights',
                style: GoogleFonts.lato(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),
              _buildHarvestPlannerCard(cardColor, textColor),
              const SizedBox(height: 24),
              _buildHarvestInsightsCard(cardColor, textColor),
              const SizedBox(height: 24),
              _buildRainfallAnalysisCard(cardColor, textColor),
              const SizedBox(height: 24),
              _buildMarketTrendsCard(cardColor, textColor),
              const SizedBox(height: 24),
              _buildCropRecommendationsCard(cardColor, textColor),
              const SizedBox(height: 24),
              _buildPestAlertCard(cardColor, textColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHarvestPlannerCard(Color cardColor, Color textColor) {
    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text(
                  'AI Harvest Planner',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Icon(Icons.psychology, color: Colors.purple, size: 20),
                if (_isLoadingHarvest || _isLoadingAI)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHarvestStatistics(textColor),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddHarvestPlanDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAIHarvestPlanDialog,
                    icon: const Icon(Icons.psychology),
                    label: const Text('AI Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_aiInsights.isNotEmpty) ...[
              _buildAIInsightsCard(textColor),
              const SizedBox(height: 16),
            ],
            if (_harvestPlans.isNotEmpty) ...[
              Text(
                'Recent Plans',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              ..._harvestPlans
                  .take(3)
                  .map((plan) => _buildHarvestPlanItem(plan, textColor)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHarvestStatistics(Color textColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Total Plans',
            '${_harvestStatistics['totalPlanted'] ?? 0}',
            Icons.list,
            Colors.blue,
            textColor,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Success Rate',
            '${(_harvestStatistics['successRate'] ?? 0.0).toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.green,
            textColor,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Completed',
            '${_harvestInsights['completedPlans'] ?? 0}',
            Icons.check_circle,
            Colors.orange,
            textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    Color textColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildHarvestPlanItem(HarvestPlan plan, Color textColor) {
    final daysUntilHarvest =
        plan.expectedHarvestDate.difference(DateTime.now()).inDays;
    final isOverdue = daysUntilHarvest < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isOverdue
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isOverdue
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.schedule,
            color: isOverdue ? Colors.red : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.cropName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  '${plan.plantedSeedlings} seedlings • Expected: ${plan.totalExpectedYield.toStringAsFixed(1)}kg',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            isOverdue ? 'Overdue' : '${daysUntilHarvest}d left',
            style: TextStyle(
              color: isOverdue ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsCard(Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: Colors.purple, size: 16),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: TextStyle(
                  color: Colors.purple[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildAIStatItem(
                  'Accuracy',
                  '${(_aiInsights['aiAccuracy'] as double? ?? 0.0).toStringAsFixed(1)}%',
                  Colors.purple,
                ),
              ),
              Expanded(
                child: _buildAIStatItem(
                  'Confidence',
                  '${(_aiInsights['predictionConfidence'] as double? ?? 0.0).toStringAsFixed(1)}%',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildAIStatItem(
                  'Trend',
                  _aiInsights['performanceTrend'] as String? ?? 'N/A',
                  Colors.green,
                ),
              ),
            ],
          ),
          if (_aiInsights['recommendations'] != null) ...[
            const SizedBox(height: 8),
            ...((_aiInsights['recommendations'] as List<dynamic>?) ?? []).take(2).map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber, size: 12),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        rec.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: textColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAIStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildHarvestInsightsCard(Color cardColor, Color textColor) {
    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Harvest Insights',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_harvestInsights['recommendations'] != null) ...[
              Text(
                'Recommendations',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              ...(_harvestInsights['recommendations'] as List<dynamic>).map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_harvestInsights['bestPerformingCrop'] != null &&
                _harvestInsights['bestPerformingCrop'] != 'No data') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Best performing crop: ${_harvestInsights['bestPerformingCrop']}',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRainfallAnalysisCard(Color cardColor, Color textColor) {
    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Rainfall Analysis',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                if (_isLoadingRainfall)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (_rainfallAnalysis != null) ...[
              SizedBox(height: 200, child: LineChart(_rainfallChartData())),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildRainfallMetric(
                      'This Week',
                      '${_rainfallAnalysis!.totalWeeklyRainfall.toStringAsFixed(1)}mm',
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildRainfallMetric(
                      'This Month',
                      '${_rainfallAnalysis!.totalMonthlyRainfall.toStringAsFixed(1)}mm',
                      Colors.lightBlue,
                    ),
                  ),
                  Expanded(
                    child: _buildRainfallMetric(
                      'Daily Avg',
                      '${_rainfallAnalysis!.averageDailyRainfall.toStringAsFixed(1)}mm',
                      Colors.cyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _rainfallAnalysis!.farmingRecommendation,
                        style: TextStyle(color: Colors.blue[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Center(child: Text('Loading rainfall data...')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMarketTrendsCard(Color cardColor, Color textColor) {
    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Market Trends',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                if (_isLoadingMarket)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_marketTrends != null) ...[
              Text(
                'Overall Trend: ${_marketTrends!.overallTrend}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              ..._marketTrends!.marketData
                  .take(5)
                  .map((data) => _buildMarketDataItem(data, textColor)),
              const SizedBox(height: 16),
              if (_marketTrends!.marketData.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Best performing: ${_marketTrends!.bestPerformingCrop}',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              const Center(child: Text('Loading market data...')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMarketDataItem(MarketData data, Color textColor) {
    final isPositive = data.priceChangePercentage > 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.cropName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  '\$${data.currentPrice.toStringAsFixed(2)}/kg',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${data.priceChangePercentage.toStringAsFixed(1)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              Text(
                data.priceTrend,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCropRecommendationsCard(Color cardColor, Color textColor) {
    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Crop Recommendations',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                if (_isLoadingCropInfo)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _crops[_selectedCropIndex],
              decoration: InputDecoration(
                labelText: 'Select Crop',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items:
                  _crops
                      .map(
                        (crop) =>
                            DropdownMenuItem(value: crop, child: Text(crop)),
                      )
                      .toList(),
              onChanged: (value) {
                if (!mounted) return;
                setState(() {
                  _selectedCropIndex = _crops.indexOf(value!);
                });
                _loadCropInfo(value!);
              },
            ),
            const SizedBox(height: 16),
            _buildCropInsight(
              'Optimal Planting Time',
              _currentCropInfo['planting_time'] ?? 'Loading...',
              Icons.calendar_today,
              Colors.blue,
            ),
            _buildCropInsight(
              'Water Requirements',
              _currentCropInfo['water_requirements'] ?? 'Loading...',
              Icons.water_drop,
              Colors.cyan,
            ),
            _buildCropInsight(
              'Fertilizer Needs',
              _currentCropInfo['fertilizer_needs'] ?? 'Loading...',
              Icons.grass,
              Colors.green,
            ),
            _buildCropInsight(
              'Pest Risk',
              _currentCropInfo['pest_risk'] ?? 'Loading...',
              Icons.bug_report,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Information sourced from agricultural databases and farming resources',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
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

  Widget _buildCropInsight(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPestAlertCard(Color cardColor, Color textColor) {
    return Card(
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Pest Management',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Pest Alert System',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Monitor your crops regularly for signs of pest activity. Use the button below to send a pest alert notification.',
                    style: TextStyle(color: Colors.red[700], fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _sendPestAlert,
                    icon: const Icon(Icons.notification_important),
                    label: const Text('Send Pest Alert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildRainfallMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  LineChartData _rainfallChartData() {
    if (_rainfallAnalysis == null) {
      return LineChartData();
    }

    final spots =
        _rainfallAnalysis!.weeklyData.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.amount);
        }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine:
            (value) => FlLine(color: Colors.grey.withValues(alpha: 0.3)),
        getDrawingVerticalLine:
            (value) => FlLine(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(fontSize: 12);
              switch (value.toInt()) {
                case 0:
                  return const Text('Mon', style: style);
                case 1:
                  return const Text('Tue', style: style);
                case 2:
                  return const Text('Wed', style: style);
                case 3:
                  return const Text('Thu', style: style);
                case 4:
                  return const Text('Fri', style: style);
                case 5:
                  return const Text('Sat', style: style);
                case 6:
                  return const Text('Sun', style: style);
                default:
                  return const Text('', style: style);
              }
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}mm',
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (_rainfallAnalysis!.weeklyData.length - 1).toDouble(),
      minY: 0,
      maxY:
          _rainfallAnalysis!.weeklyData.fold(
            0.0,
            (max, data) => data.amount > max ? data.amount : max,
          ) +
          5,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.lightBlue],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true, getDotPainter: _getDotPainter),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withAlpha(50),
                Colors.lightBlue.withAlpha(0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  static FlDotPainter _getDotPainter(spot, percent, barData, index) {
    return FlDotCirclePainter(
      radius: 4,
      color: Colors.blue,
      strokeWidth: 2,
      strokeColor: Colors.white,
    );
  }

  void _showAddHarvestPlanDialog() {
    final TextEditingController seedlingsController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String selectedCrop = _crops[0];
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Harvest Plan'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    DropdownButtonFormField<String>(
                      value: selectedCrop,
                      decoration: const InputDecoration(labelText: 'Crop'),
                      items:
                          _crops
                              .map(
                                (crop) => DropdownMenuItem(
                                  value: crop,
                                  child: Text(crop),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        selectedCrop = value!;
                        setState(() {}); // Trigger rebuild
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: seedlingsController,
                      decoration: const InputDecoration(
                        labelText: 'Number of Seedlings',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Planting Date'),
                      subtitle: Text(selectedDate.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (seedlingsController.text.isNotEmpty) {
                  final seedlings = int.tryParse(seedlingsController.text);
                  if (seedlings != null && seedlings > 0) {
                    await _harvestPlannerService.createHarvestPlan(
                      cropName: selectedCrop,
                      plantedSeedlings: seedlings,
                      plantingDate: selectedDate,
                      notes: notesController.text,
                    );
                    await _loadHarvestData();
                    if (!mounted) return;
                    // Use try-catch to handle potential context issues
                    try {
                      Navigator.of(dialogContext).pop();
                      // Show snackbar after dialog is closed
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Harvest plan created successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      });
                    } catch (e) {
                      // Dialog was already closed or context is invalid
                      debugPrint('Dialog context is no longer valid: $e');
                    }
                  }
                }
              },
              child: const Text('Create Plan'),
            ),
          ],
        );
          },
        );
      },
    );
  }

  void _showAIHarvestPlanDialog() {
    final TextEditingController seedlingsController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String selectedCrop = _crops[0];
    DateTime selectedDate = DateTime.now();
    bool isLoading = false;
    Map<String, dynamic>? aiPredictions;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.psychology, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text('AI Harvest Plan'),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    DropdownButtonFormField<String>(
                      value: selectedCrop,
                      decoration: const InputDecoration(labelText: 'Crop'),
                      items: _crops
                          .map((crop) => DropdownMenuItem(
                                value: crop,
                                child: Text(crop),
                              ))
                          .toList(),
                      onChanged: (value) {
                        selectedCrop = value!;
                        setState(() {}); // Trigger rebuild
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: seedlingsController,
                      decoration: const InputDecoration(
                        labelText: 'Number of Seedlings',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (for weather analysis)',
                        hintText: 'e.g., New York, NY',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Target Harvest Date'),
                      subtitle: Text(selectedDate.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().add(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    if (isLoading) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 8),
                      const Text('Analyzing optimal planting conditions...'),
                    ],
                    if (aiPredictions != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.psychology, color: Colors.purple, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'AI Predictions',
                                  style: TextStyle(
                                    color: Colors.purple[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Optimal Planting: ${(aiPredictions?['optimalPlantingDate'] as DateTime?)?.toString().split(' ')[0] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Predicted Yield: ${(aiPredictions?['predictedYield'] as double?)?.toStringAsFixed(2) ?? 'N/A'}kg per plant',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Confidence: ${(((aiPredictions?['confidence'] as double?) ?? 0.0) * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (aiPredictions?['riskFactors'] != null && 
                                (aiPredictions!['riskFactors'] as Map).isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Risk Factors: ${(aiPredictions!['riskFactors'] as Map).keys.join(', ')}',
                                style: TextStyle(fontSize: 11, color: Colors.orange[700]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (seedlingsController.text.isNotEmpty && locationController.text.isNotEmpty) {
                      setState(() {
                        isLoading = true;
                      });
                      
                      try {
                        // Get AI predictions
                        final predictions = await _aiHarvestPlannerService.predictOptimalPlantingTime(
                          cropName: selectedCrop,
                          location: locationController.text,
                          targetHarvestDate: selectedDate,
                        );
                        
                        setState(() {
                          aiPredictions = predictions;
                          isLoading = false;
                        });
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error getting AI predictions: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Analyze'),
                ),
                if (aiPredictions != null)
                  ElevatedButton(
                    onPressed: () async {
                      final seedlings = int.tryParse(seedlingsController.text);
                      if (seedlings != null && seedlings > 0) {
                        await _aiHarvestPlannerService.createAIHarvestPlan(
                          cropName: selectedCrop,
                          plantedSeedlings: seedlings,
                          plantingDate: aiPredictions?['optimalPlantingDate'] as DateTime? ?? DateTime.now(),
                          location: locationController.text,
                          notes: notesController.text,
                        );
                        await _loadHarvestData();
                        await _loadAIData();
                        if (!mounted) return;
                        try {
                          Navigator.of(dialogContext).pop();
                          // Show snackbar after dialog is closed
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('AI-powered harvest plan created successfully!'),
                                  backgroundColor: Colors.purple,
                                ),
                              );
                            }
                          });
                        } catch (e) {
                          debugPrint('Dialog context is no longer valid: $e');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    child: const Text('Create AI Plan'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
