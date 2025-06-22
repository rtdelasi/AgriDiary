import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
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
              _buildRainfallChart(context, isDarkMode),
              const SizedBox(height: 24),
              _buildSectionTitle('Market Events', textColor),
              const SizedBox(height: 16),
              _buildMarketEvents(context, isDarkMode),
              const SizedBox(height: 24),
              _buildSectionTitle('Farming Tools', textColor),
              const SizedBox(height: 16),
              _buildFarmingTools(context, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Text _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildRainfallChart(BuildContext context, bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Rainfall (mm)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: LineChart(
                _rainfallChartData(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _rainfallChartData(bool isDarkMode) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => const FlLine(color: Colors.transparent),
        getDrawingVerticalLine: (value) => const FlLine(color: Colors.transparent),
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
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(1, 2),
            FlSpot(2, 5),
            FlSpot(3, 3.1),
            FlSpot(4, 4),
            FlSpot(5, 3),
            FlSpot(6, 4),
          ],
          isCurved: true,
          gradient: const LinearGradient(colors: [Colors.green, Colors.lightGreen]),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.green.withOpacity(0.3), Colors.lightGreen.withOpacity(0.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketEvents(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        _buildEventCard(
          context,
          isDarkMode,
          '6-Month Bill Auction',
          '21:14',
          Icons.trending_up,
          '3.254%',
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildEventCard(
          context,
          isDarkMode,
          'Durable Goods Orders',
          '21:56',
          Icons.trending_down,
          '4.478%',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, bool isDarkMode, String title, String time, IconData trendIcon, String value, Color trendColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: isDarkMode ? Colors.white70 : Colors.black54),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(time),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(trendIcon, color: trendColor, size: 20),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmingTools(BuildContext context, bool isDarkMode) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildToolCard(context, isDarkMode, 'Pest Identifier', Icons.bug_report, Colors.orange),
        _buildToolCard(context, isDarkMode, 'Fertilizer Calculator', Icons.eco, Colors.blue),
        _buildToolCard(context, isDarkMode, 'Weather Forecast', Icons.cloud, Colors.lightBlue),
        _buildToolCard(context, isDarkMode, 'Crop Wiki', Icons.book, Colors.teal),
      ],
    );
  }

  Widget _buildToolCard(BuildContext context, bool isDarkMode, String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
