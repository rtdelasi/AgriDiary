import 'package:http/http.dart' as http;
import 'dart:convert';

class CropInfoService {
  static final CropInfoService _instance = CropInfoService._internal();
  factory CropInfoService() => _instance;
  CropInfoService._internal();

  // Cache for crop information to avoid repeated API calls
  final Map<String, Map<String, String>> _cropCache = {};

  // Comprehensive fallback data for when internet is not available
  final Map<String, Map<String, String>> _fallbackData = {
    'Corn': {
      'planting_time': 'Spring (April-May) when soil temperature reaches 50°F (10°C). Plant 1-2 weeks after last frost date.',
      'water_requirements': '1-1.5 inches per week during growing season. Critical during silking and tasseling stages.',
      'fertilizer_needs': 'Nitrogen-rich fertilizer (NPK 20-10-10). Apply 150-200 lbs N per acre. Side-dress when plants are 12-18 inches tall.',
      'pest_risk': 'Medium - Watch for corn borers, aphids, armyworms, and corn earworms. Monitor for European corn borer and fall armyworm.',
    },
    'Wheat': {
      'planting_time': 'Fall (September-October) for winter wheat, Spring (March-April) for spring wheat. Plant when soil temperature is 50-60°F.',
      'water_requirements': '0.5-1 inch per week, drought tolerant. Critical during heading and flowering stages.',
      'fertilizer_needs': 'Balanced fertilizer (NPK 10-10-10). Apply 60-90 lbs N per acre. Top-dress in early spring for winter wheat.',
      'pest_risk': 'Low - Monitor for rust diseases, aphids, Hessian fly, and armyworms. Check for stripe rust and leaf rust.',
    },
    'Soybeans': {
      'planting_time': 'Late spring (May-June) when soil is warm (55-60°F). Plant after last frost date.',
      'water_requirements': '1-1.25 inches per week during flowering and pod development. Critical during R1-R6 growth stages.',
      'fertilizer_needs': 'Phosphorus and potassium (NPK 0-20-20). Apply 40-60 lbs P2O5 and 80-120 lbs K2O per acre.',
      'pest_risk': 'Medium - Watch for soybean cyst nematode, aphids, bean leaf beetles, and stink bugs.',
    },
    'Rice': {
      'planting_time': 'Spring (March-April) in flooded fields. Plant when water temperature is 70-80°F.',
      'water_requirements': 'Flooded conditions, maintain 4-6 inches of water. Critical during tillering and flowering stages.',
      'fertilizer_needs': 'Nitrogen fertilizer (NPK 15-15-15). Apply 120-150 lbs N per acre. Split application recommended.',
      'pest_risk': 'High - Monitor for rice water weevil, stem borers, rice leaf folder, and bacterial blight.',
    },
    'Cotton': {
      'planting_time': 'Spring (April-May) when soil temperature is 60°F (15°C). Plant 2-3 weeks after last frost.',
      'water_requirements': '1-2 inches per week, drought sensitive. Critical during flowering and boll development.',
      'fertilizer_needs': 'Nitrogen and potassium (NPK 20-0-20). Apply 80-120 lbs N per acre. Side-dress at first square.',
      'pest_risk': 'High - Watch for bollworms, aphids, spider mites, and plant bugs. Monitor for pink bollworm and cotton leafworm.',
    },
  };

  Future<Map<String, String>> getCropInfo(String cropName) async {
    // Check cache first
    if (_cropCache.containsKey(cropName)) {
      return _cropCache[cropName]!;
    }

    try {
      // Try to fetch from agricultural databases
      final info = await _fetchCropInfoFromAgriculturalSources(cropName);
      if (info.isNotEmpty) {
        _cropCache[cropName] = info;
        return info;
      }
    } catch (e) {
      print('Error fetching crop info from agricultural sources: $e');
    }

    // Fallback to comprehensive local data
    final fallbackInfo = _fallbackData[cropName] ?? _getDefaultCropInfo();
    _cropCache[cropName] = fallbackInfo;
    return fallbackInfo;
  }

  Future<Map<String, String>> _fetchCropInfoFromAgriculturalSources(String cropName) async {
    final Map<String, String> cropInfo = {};
    
    try {
      // Try multiple agricultural information sources
      final sources = [
        'https://extension.umn.edu/crop-production',
        'https://extension.iastate.edu/crop-production',
        'https://extension.psu.edu/crop-production',
      ];

      for (String source in sources) {
        try {
          final response = await http.get(
            Uri.parse('$source/$cropName'),
            headers: {
              'User-Agent': 'AgriDiary/1.0 (Agricultural Information App)',
              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final content = response.body.toLowerCase();
            
            // Extract planting information
            if (cropInfo['planting_time'] == null) {
              cropInfo['planting_time'] = _extractPlantingTimeFromContent(content, cropName);
            }
            
            // Extract water requirements
            if (cropInfo['water_requirements'] == null) {
              cropInfo['water_requirements'] = _extractWaterRequirementsFromContent(content, cropName);
            }
            
            // Extract fertilizer information
            if (cropInfo['fertilizer_needs'] == null) {
              cropInfo['fertilizer_needs'] = _extractFertilizerInfoFromContent(content, cropName);
            }
            
            // Extract pest information
            if (cropInfo['pest_risk'] == null) {
              cropInfo['pest_risk'] = _extractPestInfoFromContent(content, cropName);
            }

            // If we got all the information we need, break
            if (cropInfo.length == 4) break;
          }
        } catch (e) {
          print('Error fetching from $source: $e');
          continue;
        }
      }

      // If we didn't get complete information, try a general agricultural search
      if (cropInfo.length < 4) {
        await _fetchFromGeneralAgriculturalSearch(cropName, cropInfo);
      }

    } catch (e) {
      print('Error in agricultural sources search: $e');
    }

    return cropInfo;
  }

  Future<void> _fetchFromGeneralAgriculturalSearch(String cropName, Map<String, String> cropInfo) async {
    try {
      // Try to get information from agricultural extension services
      final searchTerms = [
        '$cropName planting guide agricultural extension',
        '$cropName water requirements farming',
        '$cropName fertilizer recommendations agriculture',
        '$cropName pest management farming',
      ];

      for (int i = 0; i < searchTerms.length; i++) {
        if (cropInfo.length >= 4) break;

        try {
          final response = await http.get(
            Uri.parse('https://api.duckduckgo.com/?q=${Uri.encodeComponent(searchTerms[i])}&format=json'),
            headers: {'User-Agent': 'AgriDiary/1.0'},
          ).timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['Abstract'] != null) {
              final abstract = data['Abstract'];
              
              switch (i) {
                case 0:
                  if (cropInfo['planting_time'] == null) {
                    cropInfo['planting_time'] = _extractPlantingTime(abstract, cropName);
                  }
                  break;
                case 1:
                  if (cropInfo['water_requirements'] == null) {
                    cropInfo['water_requirements'] = _extractWaterRequirements(abstract, cropName);
                  }
                  break;
                case 2:
                  if (cropInfo['fertilizer_needs'] == null) {
                    cropInfo['fertilizer_needs'] = _extractFertilizerInfo(abstract, cropName);
                  }
                  break;
                case 3:
                  if (cropInfo['pest_risk'] == null) {
                    cropInfo['pest_risk'] = _extractPestInfo(abstract, cropName);
                  }
                  break;
              }
            }
          }
        } catch (e) {
          print('Error in search term $i: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error in general agricultural search: $e');
    }
  }

  String _extractPlantingTimeFromContent(String content, String cropName) {
    if (content.contains('spring') && content.contains('plant')) {
      return 'Spring planting recommended when soil temperature reaches optimal levels for $cropName';
    } else if (content.contains('fall') && content.contains('plant')) {
      return 'Fall planting recommended for overwintering $cropName';
    } else if (content.contains('temperature') && content.contains('°f')) {
      return 'Plant when soil temperature reaches optimal levels for $cropName growth';
    } else {
      return _fallbackData[cropName]?['planting_time'] ?? 'Check local agricultural extension for optimal timing';
    }
  }

  String _extractWaterRequirementsFromContent(String content, String cropName) {
    if (content.contains('inch') && content.contains('week')) {
      return 'Water requirements vary by growth stage - monitor soil moisture regularly';
    } else if (content.contains('drought')) {
      return 'Drought tolerant crop - moderate watering needed during critical growth stages';
    } else if (content.contains('flood') || content.contains('irrigation')) {
      return 'Requires consistent moisture - irrigation management important';
    } else {
      return _fallbackData[cropName]?['water_requirements'] ?? 'Regular irrigation recommended';
    }
  }

  String _extractFertilizerInfoFromContent(String content, String cropName) {
    if (content.contains('nitrogen') && content.contains('npk')) {
      return 'Nitrogen-rich fertilizer recommended with balanced NPK ratio';
    } else if (content.contains('phosphorus') || content.contains('potassium')) {
      return 'Phosphorus and potassium important for $cropName growth and development';
    } else if (content.contains('fertilizer') || content.contains('nutrient')) {
      return 'Soil test recommended for specific fertilizer needs';
    } else {
      return _fallbackData[cropName]?['fertilizer_needs'] ?? 'Soil test recommended for specific needs';
    }
  }

  String _extractPestInfoFromContent(String content, String cropName) {
    if (content.contains('high') || content.contains('severe') || content.contains('major')) {
      return 'High pest pressure - regular monitoring and integrated pest management required';
    } else if (content.contains('medium') || content.contains('moderate')) {
      return 'Medium pest risk - monitor regularly and scout for common pests';
    } else if (content.contains('low') || content.contains('minimal')) {
      return 'Low pest risk - occasional monitoring sufficient for $cropName';
    } else {
      return _fallbackData[cropName]?['pest_risk'] ?? 'Monitor for common pests and diseases';
    }
  }

  String _extractPlantingTime(String text, String cropName) {
    if (text.toLowerCase().contains('spring')) {
      return 'Spring planting recommended when soil temperature reaches optimal levels';
    } else if (text.toLowerCase().contains('fall') || text.toLowerCase().contains('autumn')) {
      return 'Fall planting recommended for overwintering';
    } else if (text.toLowerCase().contains('summer')) {
      return 'Summer planting possible in some regions';
    } else {
      return _fallbackData[cropName]?['planting_time'] ?? 'Check local agricultural extension for optimal timing';
    }
  }

  String _extractWaterRequirements(String text, String cropName) {
    if (text.toLowerCase().contains('inch')) {
      return 'Water requirements vary by growth stage - monitor soil moisture';
    } else if (text.toLowerCase().contains('drought')) {
      return 'Drought tolerant crop - moderate watering needed';
    } else if (text.toLowerCase().contains('flood')) {
      return 'Requires flooded conditions or high moisture';
    } else {
      return _fallbackData[cropName]?['water_requirements'] ?? 'Regular irrigation recommended';
    }
  }

  String _extractFertilizerInfo(String text, String cropName) {
    if (text.toLowerCase().contains('nitrogen')) {
      return 'Nitrogen-rich fertilizer recommended';
    } else if (text.toLowerCase().contains('phosphorus')) {
      return 'Phosphorus and potassium important for growth';
    } else if (text.toLowerCase().contains('npk')) {
      return 'Balanced NPK fertilizer recommended';
    } else {
      return _fallbackData[cropName]?['fertilizer_needs'] ?? 'Soil test recommended for specific needs';
    }
  }

  String _extractPestInfo(String text, String cropName) {
    if (text.toLowerCase().contains('high') || text.toLowerCase().contains('severe')) {
      return 'High pest pressure - regular monitoring required';
    } else if (text.toLowerCase().contains('medium') || text.toLowerCase().contains('moderate')) {
      return 'Medium pest risk - monitor regularly';
    } else if (text.toLowerCase().contains('low')) {
      return 'Low pest risk - occasional monitoring sufficient';
    } else {
      return _fallbackData[cropName]?['pest_risk'] ?? 'Monitor for common pests and diseases';
    }
  }

  Map<String, String> _getDefaultCropInfo() {
    return {
      'planting_time': 'Check local agricultural extension for optimal timing',
      'water_requirements': 'Regular irrigation recommended',
      'fertilizer_needs': 'Soil test recommended for specific needs',
      'pest_risk': 'Monitor for common pests and diseases',
    };
  }

  // Clear cache (useful for testing or when you want fresh data)
  void clearCache() {
    _cropCache.clear();
  }

  // Get all available crops
  List<String> getAvailableCrops() {
    return _fallbackData.keys.toList();
  }

  // Get detailed information about a specific crop
  Map<String, String> getDetailedCropInfo(String cropName) {
    return _fallbackData[cropName] ?? _getDefaultCropInfo();
  }
} 