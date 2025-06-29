import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';

class PermissionProvider extends ChangeNotifier {
  final PermissionService _permissionService = PermissionService();
  Map<Permission, PermissionStatus> _permissionStatuses = {};
  bool _isLoading = false;

  Map<Permission, PermissionStatus> get permissionStatuses => _permissionStatuses;
  bool get isLoading => _isLoading;

  // Check all permissions
  Future<void> checkAllPermissions() async {
    _isLoading = true;
    notifyListeners();

    final permissions = [
      Permission.microphone,
      Permission.storage,
      Permission.location,
      Permission.notification,
    ];

    Map<Permission, PermissionStatus> statuses = {};
    for (Permission permission in permissions) {
      statuses[permission] = await permission.status;
    }

    _permissionStatuses = statuses;
    _isLoading = false;
    notifyListeners();
  }

  // Request all permissions
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final statuses = await _permissionService.requestAllPermissions();
      _permissionStatuses = statuses;
      
      // Also request location and notification permissions
      await _permissionService.requestLocationPermission();
      await _permissionService.checkNotificationPermission();
      
      _isLoading = false;
      notifyListeners();
      return statuses;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Request specific permission
  Future<PermissionStatus> requestSpecificPermission(Permission permission) async {
    final status = await permission.request();
    _permissionStatuses[permission] = status;
    notifyListeners();
    return status;
  }

  // Check if all permissions are granted
  Future<bool> areAllPermissionsGranted() async {
    return await _permissionService.areAllPermissionsGranted();
  }

  // Get status of specific permission
  PermissionStatus? getPermissionStatus(Permission permission) {
    return _permissionStatuses[permission];
  }

  // Check if specific permission is granted
  bool isPermissionGranted(Permission permission) {
    return _permissionStatuses[permission] == PermissionStatus.granted;
  }

  // Get permission description
  String getPermissionDescription(Permission permission) {
    return _permissionService.getPermissionDescription(permission);
  }

  // Get permission title
  String getPermissionTitle(Permission permission) {
    return _permissionService.getPermissionTitle(permission);
  }

  // Get permission icon
  IconData getPermissionIcon(Permission permission) {
    return _permissionService.getPermissionIcon(permission);
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    return await _permissionService.openAppSettings();
  }
} 