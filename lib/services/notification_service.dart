import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'air_quality_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize notification service
  static Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tzdata.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification clicked: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  /// Schedule a contextual notification based on air quality
  static Future<void> scheduleContextualNotification(
    AirQualityData airQuality,
  ) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      // Cancel any existing scheduled notifications
      await _flutterLocalNotificationsPlugin.cancelAll();

      final String notificationTitle = 'Eco-Action Reminder';
      final String notificationBody = _getNotificationMessage(airQuality);

      // Schedule notification for 2 hours from now
      final tz.TZDateTime scheduledDateTime = tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(hours: 2));

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'eco_action_channel_id',
            'Eco Action Reminders',
            channelDescription: 'Reminders for eco-friendly actions',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        notificationTitle,
        notificationBody,
        scheduledDateTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'eco_action_${airQuality.city}',
      );

      print('Notification scheduled for $scheduledDateTime');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  /// Get notification message based on air quality conditions
  static String _getNotificationMessage(AirQualityData airQuality) {
    if (airQuality.aqi <= 50) {
      return 'Air quality is great! Perfect time to visit your local recycling drop-off center.';
    } else if (airQuality.aqi <= 100) {
      return 'Air quality is acceptable. A good time to handle your sorted recyclables.';
    } else if (airQuality.aqi <= 150) {
      return 'Moderate air quality. Consider postponing outdoor recycling activities if you are sensitive to air pollution.';
    } else {
      return 'Poor air quality detected. Keep your sorted recyclables stored safely indoors today.';
    }
  }

  /// Show the air quality notification immediately (for testing)
  static Future<void> showImmediateAirQualityNotification(
    AirQualityData airQuality,
  ) async {
    await showImmediateNotification(
      'Eco-Action Reminder',
      _getNotificationMessage(airQuality),
      payload: 'eco_action_${airQuality.city}',
    );
  }

  /// Show immediate notification (for testing)
  static Future<void> showImmediateNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'immediate_notification_channel_id',
          'Immediate Notifications',
          channelDescription: 'Immediate notification for eco-actions',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      1,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Request notification permissions (Android 13+)
  static Future<bool> requestNotificationPermissions() async {
    final androidPlatform = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlatform != null) {
      final result = await androidPlatform.requestNotificationsPermission();
      return result ?? false;
    }

    final iosPlatform = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosPlatform != null) {
      final result = await iosPlatform.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    return true;
  }
}
