import 'package:flutter/material.dart';
import '../../services/eco_stats_service.dart';

class EcoStatsProvider extends ChangeNotifier {
  final EcoStatsService _service = EcoStatsService();

  int _dayStreak = 0;
  int _totalItemsLogged = 0;
  bool _smartNotificationsEnabled = true;
  bool _isInitialized = false;

  // Getters
  int get dayStreak => _dayStreak;
  int get totalItemsLogged => _totalItemsLogged;
  bool get smartNotificationsEnabled => _smartNotificationsEnabled;
  bool get isInitialized => _isInitialized;

  /// Initialize the eco-stats service
  Future<void> init() async {
    await _service.init();
    await _loadStats();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load stats from local storage
  Future<void> _loadStats() async {
    _dayStreak = _service.getDayStreak();
    _totalItemsLogged = _service.getTotalItemsLogged();
    _smartNotificationsEnabled = _service.isSmartNotificationsEnabled();
    notifyListeners();
  }

  /// Add one logged item after a waste item is created
  Future<void> incrementItemsLogged() async {
    _totalItemsLogged = await _service.incrementItemsLogged();
    _dayStreak = _service.getDayStreak();
    notifyListeners();
  }

  /// Remove one logged item after a waste item is deleted
  Future<void> decrementItemsLogged() async {
    _totalItemsLogged = await _service.decrementItemsLogged();
    notifyListeners();
  }

  /// Toggle smart weather reminders
  Future<void> toggleSmartNotifications() async {
    await _service.toggleSmartNotifications();
    _smartNotificationsEnabled = _service.isSmartNotificationsEnabled();
    notifyListeners();
  }

  /// Reset day streak
  Future<void> resetDayStreak() async {
    await _service.resetDayStreak();
    _dayStreak = 0;
    notifyListeners();
  }

  /// Get formatted day streak display
  String getFormattedDayStreak() {
    return '$_dayStreak day${_dayStreak != 1 ? 's' : ''}';
  }

  /// Get formatted items logged display
  String getFormattedItemsLogged() {
    return '$_totalItemsLogged item${_totalItemsLogged != 1 ? 's' : ''}';
  }
}
