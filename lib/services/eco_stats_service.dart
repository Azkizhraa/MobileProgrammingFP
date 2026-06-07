import 'package:shared_preferences/shared_preferences.dart';

class EcoStatsService {
  static const String _dayStreakKey = 'eco_day_streak';
  static const String _totalItemsKey = 'eco_total_items_logged';
  static const String _lastInteractionDateKey = 'eco_last_interaction_date';
  static const String _smartNotificationsEnabledKey =
      'eco_smart_notifications_enabled';
  static const String _hasResetManualItemsLogKey =
      'eco_has_reset_manual_items_log';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _resetManualItemsLogOnce();
  }

  Future<void> _resetManualItemsLogOnce() async {
    final hasResetManualItemsLog =
        _prefs.getBool(_hasResetManualItemsLogKey) ?? false;
    if (hasResetManualItemsLog) return;

    await _prefs.setInt(_totalItemsKey, 0);
    await _prefs.setBool(_hasResetManualItemsLogKey, true);
  }

  /// Get current day streak
  int getDayStreak() {
    return _prefs.getInt(_dayStreakKey) ?? 0;
  }

  /// Get total items logged
  int getTotalItemsLogged() {
    return _prefs.getInt(_totalItemsKey) ?? 0;
  }

  /// Increment total items logged by 1
  Future<int> incrementItemsLogged() async {
    int current = _prefs.getInt(_totalItemsKey) ?? 0;
    current++;
    await _prefs.setInt(_totalItemsKey, current);
    await _updateDayStreak(); // Update streak when logging an item
    return current;
  }

  /// Decrement total items logged by 1, never below 0
  Future<int> decrementItemsLogged() async {
    final current = _prefs.getInt(_totalItemsKey) ?? 0;
    final updated = current > 0 ? current - 1 : 0;
    await _prefs.setInt(_totalItemsKey, updated);
    return updated;
  }

  /// Update day streak based on last interaction date
  Future<void> _updateDayStreak() async {
    final now = DateTime.now();
    final lastInteractionStr = _prefs.getString(_lastInteractionDateKey);

    if (lastInteractionStr == null) {
      // First interaction
      await _prefs.setInt(_dayStreakKey, 1);
      await _prefs.setString(_lastInteractionDateKey, now.toIso8601String());
      return;
    }

    final lastInteraction = DateTime.parse(lastInteractionStr);
    final daysDifference = now.difference(lastInteraction).inDays;

    if (daysDifference == 0) {
      // Same day, no change to streak
      return;
    } else if (daysDifference == 1) {
      // Consecutive day, increment streak
      int currentStreak = _prefs.getInt(_dayStreakKey) ?? 0;
      currentStreak++;
      await _prefs.setInt(_dayStreakKey, currentStreak);
      await _prefs.setString(_lastInteractionDateKey, now.toIso8601String());
    } else {
      // Streak broken, reset to 1
      await _prefs.setInt(_dayStreakKey, 1);
      await _prefs.setString(_lastInteractionDateKey, now.toIso8601String());
    }
  }

  /// Reset day streak (called at start of each day or manually)
  Future<void> resetDayStreak() async {
    await _prefs.setInt(_dayStreakKey, 0);
  }

  /// Get smart notifications enabled status
  bool isSmartNotificationsEnabled() {
    return _prefs.getBool(_smartNotificationsEnabledKey) ?? true;
  }

  /// Toggle smart notifications
  Future<void> toggleSmartNotifications() async {
    final current = isSmartNotificationsEnabled();
    await _prefs.setBool(_smartNotificationsEnabledKey, !current);
  }

  /// Get all eco-stats as a map
  Future<Map<String, dynamic>> getAllStats() async {
    return {
      'dayStreak': getDayStreak(),
      'totalItemsLogged': getTotalItemsLogged(),
      'smartNotificationsEnabled': isSmartNotificationsEnabled(),
      'lastUpdated': DateTime.now(),
    };
  }

  /// Clear all eco-stats (for reset functionality)
  Future<void> clearAllStats() async {
    await _prefs.remove(_dayStreakKey);
    await _prefs.remove(_totalItemsKey);
    await _prefs.remove(_lastInteractionDateKey);
    await _prefs.remove(_hasResetManualItemsLogKey);
  }
}
