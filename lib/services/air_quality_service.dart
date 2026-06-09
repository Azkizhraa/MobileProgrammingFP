import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_keys.dart';

class AirQualityData {
  final String city;
  final int aqi; // Air Quality Index (0-500 scale)
  final String aqiLevel; // e.g., "Good", "Moderate", "Unhealthy", etc.
  final String pollutant; // Primary pollutant
  final DateTime fetchedAt;

  AirQualityData({
    required this.city,
    required this.aqi,
    required this.aqiLevel,
    required this.pollutant,
    required this.fetchedAt,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      city: json['city'] ?? 'Unknown',
      aqi: json['aqi'] ?? 50,
      aqiLevel: json['aqiLevel'] ?? 'Moderate',
      pollutant: json['pollutant'] ?? 'N/A',
      fetchedAt: DateTime.now(),
    );
  }
}

class AirQualityService {
  // API key is stored in lib/config/api_keys.dart (not committed to version control)
  static const String _apiKey = ApiKeys.waqiApiKey;
  static const String _aqiUrlHere = 'https://api.waqi.info/feed/here';

  /// Convert numeric AQI to level description
  String _getAqiLevel(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  /// Fetch air quality data for current location
  /// Uses IP-based location, so no GPS permission is needed.
  Future<AirQualityData?> fetchAirQualityData() async {
    try {
      print('Fetching air quality using IP-based location...');
      final data = await _fetchAirQualityFromIP();
      if (data == null) {
        print('Failed to fetch air quality data via IP');
      } else {
        print('Successfully fetched air quality data via IP');
      }
      return data;
    } catch (e) {
      print('Error fetching air quality data: $e');
      return null;
    }
  }

  /// Fetch air quality using IP-based location (no permissions needed)
  Future<AirQualityData?> _fetchAirQualityFromIP() async {
    try {
      final response = await http
          .get(Uri.parse('$_aqiUrlHere?token=$_apiKey'))
          .timeout(const Duration(seconds: 10));

      return _parseAirQualityResponse(response);
    } catch (e) {
      print('Error with IP-based location: $e');
      return null;
    }
  }

  /// Parse air quality API response
  AirQualityData? _parseAirQualityResponse(http.Response response) {
    try {
      if (response.statusCode != 200) {
        print('Air Quality API Error: ${response.statusCode}');
        return null;
      }

      final jsonData = jsonDecode(response.body);

      if (jsonData['status'] != 'ok') {
        print('API Error: ${jsonData['data']}');
        return null;
      }

      final data = jsonData['data'];
      final city = data['city']['name'] ?? 'Unknown';
      final aqi = (data['aqi'] ?? 50).toInt();
      final aqiLevel = _getAqiLevel(aqi);

      // Get primary pollutant
      String pollutant = 'N/A';
      if (data['dominentpol'] != null) {
        pollutant = data['dominentpol'].toString().toUpperCase();
      }

      return AirQualityData(
        city: city,
        aqi: aqi,
        aqiLevel: aqiLevel,
        pollutant: pollutant,
        fetchedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error parsing air quality response: $e');
      return null;
    }
  }

  /// Get air quality recommendation based on AQI level
  String getAirQualityRecommendation(AirQualityData data) {
    switch (data.aqiLevel) {
      case 'Good':
        return 'Air quality is excellent! Perfect time to handle your recyclables and visit a drop-off center.';
      case 'Moderate':
        return 'Air quality is acceptable. A good opportunity to manage your sorted recyclables.';
      case 'Unhealthy for Sensitive Groups':
        return 'Air quality is poor for sensitive individuals. Consider postponing outdoor recycling activities.';
      case 'Unhealthy':
        return 'Poor air quality detected. Keep your sorted recyclables stored safely indoors today.';
      case 'Very Unhealthy':
      case 'Hazardous':
        return 'Hazardous air quality. Avoid outdoor activities. Store all recyclables safely inside.';
      default:
        return 'Check local air quality conditions before heading to the drop-off center.';
    }
  }

  /// Get banner background color based on AQI level
  /// Returns a Color in the format suitable for Flutter
  String getBannerColorHex(AirQualityData data) {
    // Green for good/moderate
    if (data.aqi <= 100) {
      return '4CAF50'; // Soft Green
    }
    // Yellow for unhealthy for sensitive groups
    else if (data.aqi <= 150) {
      return 'FFEB3B'; // Soft Yellow
    }
    // Orange for unhealthy
    else if (data.aqi <= 200) {
      return 'FF9800'; // Soft Orange
    }
    // Red for very unhealthy and hazardous
    else {
      return 'F44336'; // Soft Red
    }
  }

  /// Check if air quality is suitable for outdoor recycling drop-off
  bool isGoodAirQualityForDropOff(AirQualityData data) {
    return data.aqi <= 100; // Good or Moderate
  }
}
