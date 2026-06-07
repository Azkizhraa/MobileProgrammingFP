import 'package:flutter/material.dart';
import '../../services/air_quality_service.dart';
import '../../services/notification_service.dart';

class AirQualityProvider extends ChangeNotifier {
  final AirQualityService _airQualityService = AirQualityService();

  AirQualityData? _airQualityData;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastFetchTime;

  // Getters
  AirQualityData? get airQualityData => _airQualityData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastFetchTime => _lastFetchTime;

  /// Fetch air quality data from API
  Future<void> fetchAirQuality() async {
    if (_isLoading) return;

    // Avoid fetching too frequently (less than 5 minutes)
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 5) {
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _airQualityData = await _airQualityService.fetchAirQualityData();

      if (_airQualityData == null) {
        _errorMessage = 'Failed to fetch air quality data';
      } else {
        _lastFetchTime = DateTime.now();
        // Schedule a contextual notification based on air quality
        await NotificationService.scheduleContextualNotification(
          _airQualityData!,
        );
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      print('Air quality fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get banner background color
  Color getBannerColor() {
    if (_airQualityData == null) {
      return const Color(0xFF2196F3); // Default blue
    }

    final colorHex = _airQualityService.getBannerColorHex(_airQualityData!);
    return Color(int.parse('FF$colorHex', radix: 16));
  }

  /// Get air quality recommendation text
  String getAirQualityRecommendation() {
    if (_airQualityData == null) {
      return 'Loading air quality data...';
    }
    return _airQualityService.getAirQualityRecommendation(_airQualityData!);
  }

  /// Check if air quality is suitable for outdoor drop-off
  bool isGoodAirQualityForDropOff() {
    if (_airQualityData == null) return false;
    return _airQualityService.isGoodAirQualityForDropOff(_airQualityData!);
  }

  /// Refresh air quality data
  Future<void> refreshAirQuality() async {
    _lastFetchTime = null; // Force refresh
    await fetchAirQuality();
  }
}
