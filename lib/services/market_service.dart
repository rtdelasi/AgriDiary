import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/market_data.dart';

class MarketService {
  static final MarketService _instance = MarketService._internal();
  factory MarketService() => _instance;
  MarketService._internal();

  final Logger _logger = Logger();
  
  // API Keys (you'll need to get these from the respective services)
  static const String _alphaVantageApiKey = 'YOUR_ALPHA_VANTAGE_API_KEY'; // Get from alphavantage.co
  static const String _quandlApiKey = 'YOUR_QUANDL_API_KEY'; // Get from quandl.com
  
  // Cache for market data
  final Map<String, MarketTrends> _marketCache = {};
  final Map<String, DateTime> _lastFetchTime = {};

  // Get market data for crops
  Future<MarketTrends> getMarketData(List<String> crops) async {
    // Check cache first (cache for 30 minutes)
    final now = DateTime.now();
    final cacheKey = crops.join(',');
    final lastFetch = _lastFetchTime[cacheKey];
    if (lastFetch != null && now.difference(lastFetch).inMinutes < 30) {
      return _marketCache[cacheKey] ?? _getMockMarketData(crops);
    }

    try {
      // Try to fetch from multiple sources
      final marketData = await _fetchMarketData(crops);
      if (marketData.isNotEmpty) {
        final trends = _createMarketTrends(marketData);
        _marketCache[cacheKey] = trends;
        _lastFetchTime[cacheKey] = now;
        return trends;
      }

      // If APIs fail, return mock data
      return _getMockMarketData(crops);
    } catch (e) {
      _logger.e('Error fetching market data: $e');
      return _getMockMarketData(crops);
    }
  }

  // Fetch market data from multiple sources
  Future<List<MarketData>> _fetchMarketData(List<String> crops) async {
    final List<MarketData> marketData = [];

    for (final crop in crops) {
      try {
        // Try Alpha Vantage API
        final alphaData = await _fetchFromAlphaVantage(crop);
        if (alphaData != null) {
          marketData.add(alphaData);
          continue;
        }

        // Try Quandl API
        final quandlData = await _fetchFromQuandl(crop);
        if (quandlData != null) {
          marketData.add(quandlData);
          continue;
        }

        // Add mock data for this crop
        marketData.add(_createMockMarketData(crop));
      } catch (e) {
        _logger.e('Error fetching data for $crop: $e');
        marketData.add(_createMockMarketData(crop));
      }
    }

    return marketData;
  }

  // Fetch from Alpha Vantage API
  Future<MarketData?> _fetchFromAlphaVantage(String crop) async {
    try {
      // Alpha Vantage provides commodity data
      final response = await http.get(
        Uri.parse(
          'https://www.alphavantage.co/query?function=COMMODITY&symbol=${crop.toUpperCase()}&apikey=$_alphaVantageApiKey'
        ),
        headers: {'User-Agent': 'AgriDiary/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseAlphaVantageData(data, crop);
      }
    } catch (e) {
      _logger.e('Error fetching from Alpha Vantage: $e');
    }
    return null;
  }

  // Fetch from Quandl API
  Future<MarketData?> _fetchFromQuandl(String crop) async {
    try {
      // Quandl provides agricultural commodity data
      final response = await http.get(
        Uri.parse(
          'https://www.quandl.com/api/v3/datasets/ODA/${crop.toUpperCase()}_PRICE.json?api_key=$_quandlApiKey&limit=2'
        ),
        headers: {'User-Agent': 'AgriDiary/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseQuandlData(data, crop);
      }
    } catch (e) {
      _logger.e('Error fetching from Quandl: $e');
    }
    return null;
  }

  // Parse Alpha Vantage data
  MarketData? _parseAlphaVantageData(Map<String, dynamic> data, String crop) {
    try {
      final timeSeries = data['Time Series (Daily)'];
      if (timeSeries != null) {
        final dates = timeSeries.keys.toList()..sort();
        if (dates.length >= 2) {
          final currentDate = dates[0];
          final previousDate = dates[1];
          
          final currentPrice = double.tryParse(timeSeries[currentDate]['4. close'] ?? '0') ?? 0.0;
          final previousPrice = double.tryParse(timeSeries[previousDate]['4. close'] ?? '0') ?? 0.0;

          return MarketData(
            cropName: crop,
            currentPrice: currentPrice,
            previousPrice: previousPrice,
            date: DateTime.parse(currentDate),
            market: 'Global Commodity Market',
            unit: 'USD/kg',
          );
        }
      }
    } catch (e) {
      _logger.e('Error parsing Alpha Vantage data: $e');
    }
    return null;
  }

  // Parse Quandl data
  MarketData? _parseQuandlData(Map<String, dynamic> data, String crop) {
    try {
      final dataset = data['dataset'];
      if (dataset != null) {
        final dataList = dataset['data'] as List?;
        if (dataList != null && dataList.length >= 2) {
          final currentData = dataList[0];
          final previousData = dataList[1];
          
          final currentPrice = (currentData[1] as num?)?.toDouble() ?? 0.0;
          final previousPrice = (previousData[1] as num?)?.toDouble() ?? 0.0;
          final currentDate = DateTime.parse(currentData[0]);

          return MarketData(
            cropName: crop,
            currentPrice: currentPrice,
            previousPrice: previousPrice,
            date: currentDate,
            market: 'Agricultural Commodity Market',
            unit: 'USD/kg',
          );
        }
      }
    } catch (e) {
      _logger.e('Error parsing Quandl data: $e');
    }
    return null;
  }

  // Create market trends from market data
  MarketTrends _createMarketTrends(List<MarketData> marketData) {
    final Map<String, double> averagePrices = {};
    final Map<String, String> topPerformers = {};
    
    for (final data in marketData) {
      averagePrices[data.cropName] = data.currentPrice;
      topPerformers[data.cropName] = data.priceTrend;
    }

    // Calculate overall trend
    final totalChange = marketData.fold(0.0, (sum, data) => sum + data.priceChangePercentage);
    final averageChange = marketData.isNotEmpty ? totalChange / marketData.length : 0.0;
    
    String overallTrend;
    if (averageChange > 5) {
      overallTrend = 'Strong Upward Trend';
    } else if (averageChange > 2) {
      overallTrend = 'Upward Trend';
    } else if (averageChange < -5) {
      overallTrend = 'Strong Downward Trend';
    } else if (averageChange < -2) {
      overallTrend = 'Downward Trend';
    } else {
      overallTrend = 'Stable Market';
    }

    return MarketTrends(
      marketData: marketData,
      averagePrices: averagePrices,
      topPerformers: topPerformers,
      overallTrend: overallTrend,
    );
  }

  // Create mock market data for a crop
  MarketData _createMockMarketData(String crop) {
    final basePrices = {
      'Corn': 0.25,
      'Wheat': 0.30,
      'Soybeans': 0.45,
      'Rice': 0.40,
      'Cotton': 0.85,
      'Tomato': 1.20,
      'Potato': 0.35,
    };

    final basePrice = basePrices[crop] ?? 0.50;
    final randomFactor = 0.8 + (DateTime.now().millisecond % 40) / 100.0; // Simulate price variation
    final currentPrice = basePrice * randomFactor;
    final previousPrice = basePrice * (randomFactor - 0.05);

    return MarketData(
      cropName: crop,
      currentPrice: currentPrice,
      previousPrice: previousPrice,
      date: DateTime.now(),
      market: 'Local Agricultural Market',
      unit: 'USD/kg',
    );
  }

  // Get mock market data for development/testing
  MarketTrends _getMockMarketData(List<String> crops) {
    final List<MarketData> marketData = [];
    
    for (final crop in crops) {
      marketData.add(_createMockMarketData(crop));
    }

    return _createMarketTrends(marketData);
  }

  // Clear cache
  void clearCache() {
    _marketCache.clear();
    _lastFetchTime.clear();
  }
} 