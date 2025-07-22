import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';
import '../models/notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  // Notification channels
  static const String weatherChannelId = 'weather_alerts';
  static const String pestChannelId = 'pest_alerts';
  static const String cropChannelId = 'crop_reminders';
  static const String generalChannelId = 'general_notifications';

  // Notification IDs
  static const int weatherAlertId = 1000;
  static const int pestAlertId = 2000;
  static const int cropReminderId = 3000;
  static const int generalNotificationId = 4000;
  static const int dailyPlanningId = 5000;

  // Settings keys
  static const String _settingsKey = 'notification_settings';
  static const String _lastWeatherKey = 'last_weather_alert';
  static const String _lastPestKey = 'last_pest_alert';
  static const String _dailyPlanningKey = 'daily_planning_scheduled';

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();
    await _scheduleDailyPlanningReminder();
    _isInitialized = true;
  }

  Future<void> _createNotificationChannels() async {
    final androidImplementation = AndroidFlutterLocalNotificationsPlugin();

    // Weather alerts channel
    await androidImplementation.createNotificationChannel(
      const AndroidNotificationChannel(
        weatherChannelId,
        'Weather Alerts',
        description: 'Important weather changes and alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Pest alerts channel
    await androidImplementation.createNotificationChannel(
      const AndroidNotificationChannel(
        pestChannelId,
        'Pest Alerts',
        description: 'Pest and disease alerts for your crops',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Crop reminders channel
    await androidImplementation.createNotificationChannel(
      const AndroidNotificationChannel(
        cropChannelId,
        'Crop Reminders',
        description: 'Daily reminders to check your crops',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: false,
      ),
    );

    // General notifications channel
    await androidImplementation.createNotificationChannel(
      const AndroidNotificationChannel(
        generalChannelId,
        'General Notifications',
        description: 'General app notifications and updates',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - you can navigate to specific pages here
    debugPrint('Notification tapped: ${response.payload}');
    
    // Parse the payload and add to notification provider
    try {
      final payload = json.decode(response.payload ?? '{}');
      final notification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: payload['title'] ?? 'Notification',
        message: payload['body'] ?? 'You have a new notification',
        type: payload['type'] ?? 'general_notification',
        timestamp: DateTime.now(),
        payload: payload,
      );
      
      // Add to notification provider if available
      // Note: This would need to be handled through a global key or service locator
      // For now, we'll just log it
      debugPrint('Notification received: ${notification.title}');
      
      // Mark notification as read when tapped
      _markNotificationAsRead(notification.id);
    } catch (e) {
      debugPrint('Error parsing notification payload: $e');
    }
  }

  // Weather alert notification
  Future<void> showWeatherAlert(String title, String message, String weatherType) async {
    if (!_isInitialized) await initialize();
    
    final settings = await getNotificationSettings();
    if (!(settings['weather_alerts'] ?? true)) return;

    // Check if we should show this alert (avoid spam)
    if (!await _shouldShowWeatherAlert(weatherType)) return;

    const androidDetails = AndroidNotificationDetails(
      weatherChannelId,
      'Weather Alerts',
      channelDescription: 'Important weather changes and alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      weatherAlertId,
      title,
      message,
      details,
      payload: json.encode({
        'type': 'weather_alert',
        'weather_type': weatherType,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    await _saveLastWeatherAlert(weatherType);
  }

  // Pest alert notification
  Future<void> showPestAlert(String title, String message, String pestType) async {
    if (!_isInitialized) await initialize();
    
    final settings = await getNotificationSettings();
    if (!(settings['pest_alerts'] ?? true)) return;

    // Check if we should show this alert (avoid spam)
    if (!await _shouldShowPestAlert(pestType)) return;

    const androidDetails = AndroidNotificationDetails(
      pestChannelId,
      'Pest Alerts',
      channelDescription: 'Pest and disease alerts for your crops',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF9800),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      pestAlertId,
      title,
      message,
      details,
      payload: json.encode({
        'type': 'pest_alert',
        'pest_type': pestType,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    await _saveLastPestAlert(pestType);
  }

  // Crop check reminder notification
  Future<void> showCropReminder(String title, String message) async {
    if (!_isInitialized) await initialize();
    
    final settings = await getNotificationSettings();
    if (!(settings['crop_reminders'] ?? true)) return;

    const androidDetails = AndroidNotificationDetails(
      cropChannelId,
      'Crop Reminders',
      channelDescription: 'Daily reminders to check your crops',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2196F3),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      cropReminderId,
      title,
      message,
      details,
      payload: json.encode({
        'type': 'crop_reminder',
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  // General notification
  Future<void> showGeneralNotification(String title, String message) async {
    if (!_isInitialized) await initialize();
    
    final settings = await getNotificationSettings();
    if (!(settings['general_notifications'] ?? true)) return;

    const androidDetails = AndroidNotificationDetails(
      generalChannelId,
      'General Notifications',
      channelDescription: 'General app notifications and updates',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF9E9E9E),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      generalNotificationId,
      title,
      message,
      details,
      payload: json.encode({
        'type': 'general_notification',
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  // Schedule daily crop check reminder
  Future<void> scheduleCropReminder() async {
    if (!_isInitialized) await initialize();
    
    final settings = await getNotificationSettings();
    if (!(settings['crop_reminders'] ?? true)) return;

    const androidDetails = AndroidNotificationDetails(
      cropChannelId,
      'Crop Reminders',
      channelDescription: 'Daily reminders to check your crops',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2196F3),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule for 8:00 AM daily
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8, 0);
    
    // If it's already past 8 AM, schedule for tomorrow
    final targetDate = scheduledDate.isBefore(now) 
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    await _notificationsPlugin.zonedSchedule(
      cropReminderId,
      'Crop Check Reminder',
      'Time to check your crops! Monitor for pests, water needs, and growth progress.',
      targetDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: json.encode({
        'type': 'scheduled_crop_reminder',
        'timestamp': targetDate.toIso8601String(),
      }),
    );
  }

  // Schedule daily planning reminder at 5 AM
  Future<void> _scheduleDailyPlanningReminder() async {
    if (!_isInitialized) await initialize();
    
    final settings = await getNotificationSettings();
    if (!(settings['daily_planning'] ?? true)) return;

    // Check if already scheduled
    final prefs = await SharedPreferences.getInstance();
    final isScheduled = prefs.getBool(_dailyPlanningKey) ?? false;
    if (isScheduled) return;

    const androidDetails = AndroidNotificationDetails(
      generalChannelId,
      'General Notifications',
      channelDescription: 'General app notifications and updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule for 5:00 AM daily
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 5, 0);
    
    // If it's already past 5 AM, schedule for tomorrow
    final targetDate = scheduledDate.isBefore(now) 
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    await _notificationsPlugin.zonedSchedule(
      dailyPlanningId,
      'Daily Planning Reminder',
      'Add and complete tasks. Enjoy farming!',
      targetDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: json.encode({
        'type': 'daily_planning_reminder',
        'timestamp': targetDate.toIso8601String(),
      }),
    );

    // Mark as scheduled
    await prefs.setBool(_dailyPlanningKey, true);
  }

  // Show daily planning reminder
  Future<void> showDailyPlanningReminder() async {
    if (!_isInitialized) await initialize();
    
    final settings = await getNotificationSettings();
    if (!(settings['daily_planning'] ?? true)) return;

    const androidDetails = AndroidNotificationDetails(
      generalChannelId,
      'General Notifications',
      channelDescription: 'General app notifications and updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      dailyPlanningId,
      'Daily Planning Reminder',
      'Add and complete tasks. Enjoy farming!',
      details,
      payload: json.encode({
        'type': 'daily_planning_reminder',
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  // Get notification settings
  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      final Map<String, dynamic> settings = json.decode(settingsJson);
      return Map<String, bool>.from(settings);
    }
    
    // Default settings
    return {
      'weather_alerts': true,
      'pest_alerts': true,
      'crop_reminders': true,
      'general_notifications': true,
      'daily_planning': true,
    };
  }

  // Update notification settings
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, json.encode(settings));
  }

  // Check if we should show weather alert (avoid spam)
  Future<bool> _shouldShowWeatherAlert(String weatherType) async {
    final prefs = await SharedPreferences.getInstance();
    final lastAlertJson = prefs.getString('$_lastWeatherKey$weatherType');
    
    if (lastAlertJson == null) return true;
    
    final lastAlert = DateTime.parse(json.decode(lastAlertJson)['timestamp']);
    final now = DateTime.now();
    
    // Don't show same weather alert within 2 hours
    return now.difference(lastAlert).inHours >= 2;
  }

  // Check if we should show pest alert (avoid spam)
  Future<bool> _shouldShowPestAlert(String pestType) async {
    final prefs = await SharedPreferences.getInstance();
    final lastAlertJson = prefs.getString('$_lastPestKey$pestType');
    
    if (lastAlertJson == null) return true;
    
    final lastAlert = DateTime.parse(json.decode(lastAlertJson)['timestamp']);
    final now = DateTime.now();
    
    // Don't show same pest alert within 6 hours
    return now.difference(lastAlert).inHours >= 6;
  }

  // Save last weather alert timestamp
  Future<void> _saveLastWeatherAlert(String weatherType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_lastWeatherKey$weatherType', json.encode({
      'timestamp': DateTime.now().toIso8601String(),
      'weather_type': weatherType,
    }));
  }

  // Save last pest alert timestamp
  Future<void> _saveLastPestAlert(String pestType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_lastPestKey$pestType', json.encode({
      'timestamp': DateTime.now().toIso8601String(),
      'pest_type': pestType,
    }));
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    await _notificationsPlugin.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) await initialize();
    await _notificationsPlugin.cancel(id);
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) await initialize();
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  // Add notification to provider (to be called from UI)
  static void addNotificationToProvider(AppNotification notification) {
    // This would be called from the UI when a notification is received
    debugPrint('Adding notification to provider: ${notification.title}');
  }

  // Mark notification as read
  void _markNotificationAsRead(String notificationId) {
    // This would mark the notification as read in the provider
    debugPrint('Marking notification as read: $notificationId');
  }

  // Real-time notification methods for immediate display
  Future<void> showImmediateNotification(String title, String message, String type) async {
    if (!_isInitialized) await initialize();
    
    final settings = await getNotificationSettings();
    if (!(settings['general_notifications'] ?? true)) return;

    final androidDetails = AndroidNotificationDetails(
      generalChannelId,
      'General Notifications',
      channelDescription: 'General app notifications and updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50),
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId = DateTime.now().millisecondsSinceEpoch;
    
    await _notificationsPlugin.show(
      notificationId,
      title,
      message,
      details,
      payload: json.encode({
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        'id': notificationId.toString(),
      }),
    );

    // Create notification object for provider
    final notification = AppNotification(
      id: notificationId.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      payload: {
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        'id': notificationId.toString(),
      },
    );

    // Add to provider immediately
    addNotificationToProvider(notification);
  }

  // Show daily planning reminder and add to provider
  Future<void> showDailyPlanningReminderWithProvider() async {
    await showDailyPlanningReminder();
    
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Daily Planning Reminder',
      message: 'Prepare and complete tasks for the day.',
      type: 'daily_planning_reminder',
      timestamp: DateTime.now(),
      payload: {
        'type': 'daily_planning_reminder',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    addNotificationToProvider(notification);
  }
} 