class MarketData {
  final String cropName;
  final double currentPrice; // per kg
  final double previousPrice; // per kg
  final DateTime date;
  final String market;
  final String? unit; // kg, ton, etc.
  final double? volume; // trading volume
  final String? trend; // up, down, stable

  MarketData({
    required this.cropName,
    required this.currentPrice,
    required this.previousPrice,
    required this.date,
    required this.market,
    this.unit,
    this.volume,
    this.trend,
  });

  // Calculate price change percentage
  double get priceChangePercentage {
    if (previousPrice == 0) return 0.0;
    return ((currentPrice - previousPrice) / previousPrice) * 100;
  }

  // Get price trend
  String get priceTrend {
    if (priceChangePercentage > 5) return 'Strong Up';
    if (priceChangePercentage > 2) return 'Up';
    if (priceChangePercentage < -5) return 'Strong Down';
    if (priceChangePercentage < -2) return 'Down';
    return 'Stable';
  }

  // Get market recommendation
  String get marketRecommendation {
    if (priceChangePercentage > 10) {
      return 'High price increase. Consider selling soon to maximize profits.';
    } else if (priceChangePercentage > 5) {
      return 'Good price trend. Monitor for optimal selling time.';
    } else if (priceChangePercentage < -10) {
      return 'Significant price drop. Consider holding or diversifying.';
    } else if (priceChangePercentage < -5) {
      return 'Price declining. Review market conditions before selling.';
    } else {
      return 'Stable prices. Continue monitoring market trends.';
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'currentPrice': currentPrice,
      'previousPrice': previousPrice,
      'date': date.toIso8601String(),
      'market': market,
      'unit': unit,
      'volume': volume,
      'trend': trend,
    };
  }

  // Create from JSON
  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      cropName: json['cropName'] ?? '',
      currentPrice: (json['currentPrice'] ?? 0.0).toDouble(),
      previousPrice: (json['previousPrice'] ?? 0.0).toDouble(),
      date: DateTime.parse(json['date']),
      market: json['market'] ?? '',
      unit: json['unit'],
      volume: json['volume'] != null ? (json['volume'] as num).toDouble() : null,
      trend: json['trend'],
    );
  }
}

class MarketTrends {
  final List<MarketData> marketData;
  final Map<String, double> averagePrices;
  final Map<String, String> topPerformers;
  final String overallTrend;

  MarketTrends({
    required this.marketData,
    required this.averagePrices,
    required this.topPerformers,
    required this.overallTrend,
  });

  // Get best performing crop
  String get bestPerformingCrop {
    if (marketData.isEmpty) return 'No data available';
    
    var best = marketData.first;
    for (var data in marketData) {
      if (data.priceChangePercentage > best.priceChangePercentage) {
        best = data;
      }
    }
    return best.cropName;
  }

  // Get worst performing crop
  String get worstPerformingCrop {
    if (marketData.isEmpty) return 'No data available';
    
    var worst = marketData.first;
    for (var data in marketData) {
      if (data.priceChangePercentage < worst.priceChangePercentage) {
        worst = data;
      }
    }
    return worst.cropName;
  }
} 