import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  
  int get unreadCount => _notifications.where((notification) => !notification.isRead).length;

  // Load notifications from storage
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications');
      
      if (notificationsJson != null) {
        final List<dynamic> notificationsList = json.decode(notificationsJson);
        _notifications = notificationsList
            .map((json) => AppNotification.fromJson(json))
            .toList();
        
        // Sort by timestamp (newest first)
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = json.encode(
        _notifications.map((notification) => notification.toJson()).toList(),
      );
      await prefs.setString('notifications', notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  // Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    await _saveNotifications();
    notifyListeners();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((notification) => 
      notification.copyWith(isRead: true)
    ).toList();
    await _saveNotifications();
    notifyListeners();
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((notification) => notification.id == notificationId);
    await _saveNotifications();
    notifyListeners();
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  // Delete read notifications
  Future<void> deleteReadNotifications() async {
    _notifications.removeWhere((notification) => notification.isRead);
    await _saveNotifications();
    notifyListeners();
  }

  // Get notifications by type
  List<AppNotification> getNotificationsByType(String type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }

  // Get unread notifications
  List<AppNotification> get unreadNotifications {
    return _notifications.where((notification) => !notification.isRead).toList();
  }
} 