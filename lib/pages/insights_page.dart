import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/crop_info_service.dart';
import '../services/notification_service.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  int _selectedCropIndex = 0;
  final List<String> _crops = ['Corn', 'Wheat', 'Soybeans', 'Rice', 'Cotton'];
  final CropInfoService _cropInfoService = CropInfoService();
  final NotificationService _notificationService = NotificationService();
  
  Map<String, String> _currentCropInfo = {};
  bool _isLoadingCropInfo = false;

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    _loadCropInfo(_crops[_selectedCropIndex]);
    _scheduleCropReminder();
  }

  Future<void> _loadCropInfo(String cropName) async {
    setState(() {
      _isLoadingCropInfo = true;
    });

    try {
      final cropInfo = await _cropInfoService.getCropInfo(cropName);
      setState(() {
        _currentCropInfo = cropInfo;
        _isLoadingCropInfo = false;
      });
    } catch (e) {
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

  Future<void> _scheduleCropReminder() async {
    try {
      await _notificationService.scheduleCropReminder();
    } catch (e) {
      print('Error scheduling crop reminder: $e');
    }
  }

  Future<void> _sendPestAlert() async {
    try {
      final cropName = _crops[_selectedCropIndex];
      await _notificationService.showPestAlert(
        'Pest Alert: $cropName',
        'Potential pest activity detected in your $cropName field. Please inspect your crops and consider preventive measures.',
        cropName.toLowerCase(),
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
              _buildWeatherSummaryCard(cardColor, textColor),
              const SizedBox(height: 24),
              _buildRainfallAnalysisCard(cardColor, textColor),
              const SizedBox(height: 24),
              _buildCropRecommendationsCard(cardColor, textColor),
              const SizedBox(height: 24),
              _buildSoilMoistureCard(cardColor, textColor),
              const SizedBox(height: 24),
              _buildPestAlertCard(cardColor, textColor),
              const SizedBox(height: 24),
              _buildMarketTrendsCard(cardColor, textColor),
              const SizedBox(height: 24),
              _buildFarmingTools(context, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherSummaryCard(Color cardColor, Color textColor) {
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
                Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Weather Summary',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWeatherMetric('Temperature', '24°C', Icons.thermostat, Colors.red),
                ),
                Expanded(
                  child: _buildWeatherMetric('Humidity', '65%', Icons.water_drop, Colors.blue),
                ),
                Expanded(
                  child: _buildWeatherMetric('Wind', '12 km/h', Icons.air, Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ideal conditions for outdoor farming activities',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
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

  Widget _buildWeatherMetric(String label, String value, IconData icon, Color color) {
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
            color: Colors.grey[600],
          ),
        ),
      ],
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
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                _rainfallChartData(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRainfallMetric('This Week', '45mm', Colors.blue),
                ),
                Expanded(
                  child: _buildRainfallMetric('This Month', '180mm', Colors.lightBlue),
                ),
                Expanded(
                  child: _buildRainfallMetric('Forecast', '25mm', Colors.cyan),
                ),
              ],
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  LineChartData _rainfallChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.3)),
        getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(fontSize: 12);
              switch (value.toInt()) {
                case 0: return const Text('Mon', style: style);
                case 1: return const Text('Tue', style: style);
                case 2: return const Text('Wed', style: style);
                case 3: return const Text('Thu', style: style);
                case 4: return const Text('Fri', style: style);
                case 5: return const Text('Sat', style: style);
                case 6: return const Text('Sun', style: style);
                default: return const Text('', style: style);
              }
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}mm', style: const TextStyle(fontSize: 12));
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 20,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 8),
            FlSpot(1, 12),
            FlSpot(2, 15),
            FlSpot(3, 6),
            FlSpot(4, 18),
            FlSpot(5, 10),
            FlSpot(6, 14),
          ],
          isCurved: true,
          gradient: const LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true, getDotPainter: _getDotPainter),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.blue.withAlpha(50), Colors.lightBlue.withAlpha(0)],
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _crops.map((crop) => DropdownMenuItem(value: crop, child: Text(crop))).toList(),
              onChanged: (value) {
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
              Colors.blue
            ),
            _buildCropInsight(
              'Water Requirements', 
              _currentCropInfo['water_requirements'] ?? 'Loading...', 
              Icons.water_drop, 
              Colors.cyan
            ),
            _buildCropInsight(
              'Fertilizer Needs', 
              _currentCropInfo['fertilizer_needs'] ?? 'Loading...', 
              Icons.grass, 
              Colors.green
            ),
            _buildCropInsight(
              'Pest Risk', 
              _currentCropInfo['pest_risk'] ?? 'Loading...', 
              Icons.bug_report, 
              Colors.orange
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

  Widget _buildCropInsight(String title, String value, IconData icon, Color color) {
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

  Widget _buildSoilMoistureCard(Color cardColor, Color textColor) {
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
                Icon(Icons.terrain, color: Colors.brown, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Soil Moisture',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: BarChart(
                _soilMoistureChartData(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSoilMetric('Surface', '65%', Colors.lightGreen),
                ),
                Expanded(
                  child: _buildSoilMetric('Root Zone', '78%', Colors.green),
                ),
                Expanded(
                  child: _buildSoilMetric('Deep Soil', '45%', Colors.brown),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilMetric(String label, String value, Color color) {
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  BarChartData _soilMoistureChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 100,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(fontSize: 12);
              switch (value.toInt()) {
                case 0: return const Text('Surface', style: style);
                case 1: return const Text('Root Zone', style: style);
                case 2: return const Text('Deep Soil', style: style);
                default: return const Text('', style: style);
              }
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}%', style: const TextStyle(fontSize: 12));
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 65, color: Colors.lightGreen, width: 20)]),
        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 78, color: Colors.green, width: 20)]),
        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 45, color: Colors.brown, width: 20)]),
      ],
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
                Icon(Icons.warning, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Pest Alerts',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _sendPestAlert,
                  icon: const Icon(Icons.notifications, size: 16),
                  label: const Text('Send Alert'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bug_report, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Aphid Activity Detected',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor corn fields for aphid infestation. Consider preventive treatment if population exceeds threshold.',
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap "Send Alert" to notify about pest activity',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                Icon(Icons.trending_up, color: Colors.purple, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Market Trends',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMarketItem('Corn', '\$4.25/bushel', '+2.3%', Colors.green),
            _buildMarketItem('Wheat', '\$5.80/bushel', '-1.1%', Colors.red),
            _buildMarketItem('Soybeans', '\$12.40/bushel', '+0.8%', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketItem(String crop, String price, String change, Color changeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            crop,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmingTools(BuildContext context, bool isDarkMode) {
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farming Tools',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            children: [
              _buildHorizontalToolCard(context, isDarkMode, 'Pest Identifier', Icons.bug_report, Colors.orange, cardColor),
              const SizedBox(width: 12),
              _buildHorizontalToolCard(context, isDarkMode, 'Fertilizer Calculator', Icons.eco, Colors.blue, cardColor),
              const SizedBox(width: 12),
              _buildHorizontalToolCard(context, isDarkMode, 'Weather Forecast', Icons.cloud, Colors.lightBlue, cardColor),
              const SizedBox(width: 12),
              _buildHorizontalToolCard(context, isDarkMode, 'Crop Wiki', Icons.book, Colors.teal, cardColor),
              const SizedBox(width: 12),
              _buildHorizontalToolCard(context, isDarkMode, 'Soil Analyzer', Icons.terrain, Colors.brown, cardColor),
              const SizedBox(width: 12),
              _buildHorizontalToolCard(context, isDarkMode, 'Harvest Planner', Icons.calendar_month, Colors.green, cardColor),
              const SizedBox(width: 12),
              _buildHorizontalToolCard(context, isDarkMode, 'Irrigation Guide', Icons.water_drop, Colors.cyan, cardColor),
              const SizedBox(width: 12),
              _buildHorizontalToolCard(context, isDarkMode, 'Market Prices', Icons.trending_up, Colors.purple, cardColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalToolCard(BuildContext context, bool isDarkMode, String title, IconData icon, Color color, Color cardColor) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      child: InkWell(
        onTap: () {
          // Handle tool selection
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $title...'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withAlpha(50),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
