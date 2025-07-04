import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // List of all permissions the app needs
  final List<Permission> _requiredPermissions = [
    Permission.microphone,
    Permission.storage,
    Permission.location,
    Permission.notification,
  ];

  // Check if all permissions are granted
  Future<bool> areAllPermissionsGranted() async {
    for (Permission permission in _requiredPermissions) {
      if (await permission.status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  // Request all permissions
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = {};
    
    for (Permission permission in _requiredPermissions) {
      statuses[permission] = await permission.request();
    }
    
    return statuses;
  }

  // Check location permission specifically (using geolocator)
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  // Check notification permission
  Future<bool> checkNotificationPermission() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    
    return true; // For iOS, assume granted if not Android
  }

  // Get permission status for a specific permission
  Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  // Check if permissions have been requested before
  Future<bool> havePermissionsBeenRequested() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('permissions_requested') ?? false;
  }

  // Mark permissions as requested
  Future<void> markPermissionsRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_requested', true);
  }

  // Reset permission request flag (useful for testing)
  Future<void> resetPermissionRequestFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_requested', false);
  }

  // Get permission description for UI
  String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.microphone:
        return 'Microphone access is needed to record audio notes for your diary entries.';
      case Permission.storage:
        return 'Storage access is needed to save your photos, audio recordings, and app data.';
      case Permission.location:
        return 'Location access is needed to provide weather information and location-based features.';
      case Permission.notification:
        return 'Notification access is needed to send you reminders and updates about your farming activities.';
      default:
        return 'This permission is needed for app functionality.';
    }
  }

  // Get permission title for UI
  String getPermissionTitle(Permission permission) {
    switch (permission) {
      case Permission.microphone:
        return 'Microphone Permission';
      case Permission.storage:
        return 'Storage Permission';
      case Permission.location:
        return 'Location Permission';
      case Permission.notification:
        return 'Notification Permission';
      default:
        return 'Permission';
    }
  }

  // Get permission icon for UI
  IconData getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.microphone:
        return Icons.mic;
      case Permission.storage:
        return Icons.storage;
      case Permission.location:
        return Icons.location_on;
      case Permission.notification:
        return Icons.notifications;
      default:
        return Icons.security;
    }
  }
} 