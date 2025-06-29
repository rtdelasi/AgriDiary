import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider with ChangeNotifier {
  String _name = 'Wilson Daniels';
  String _email = 'wilsondaniels@email.com';
  String? _photoPath;

  static const String _nameKey = 'userName';
  static const String _emailKey = 'userEmail';
  static const String _photoPathKey = 'userPhotoPath';

  String get name => _name;
  String get email => _email;
  String? get photoPath => _photoPath;

  UserProfileProvider() {
    // Defer loading to prevent blocking initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void updateProfile(String newName, String newEmail) {
    _name = newName;
    _email = newEmail;
    _saveProfile();
    notifyListeners();
  }

  void updateProfilePhoto(String newPhotoPath) {
    _photoPath = newPhotoPath.isEmpty ? null : newPhotoPath;
    _saveProfile();
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey) ?? 'Wilson Daniels';
    _email = prefs.getString(_emailKey) ?? 'wilsondaniels@email.com';
    _photoPath = prefs.getString(_photoPathKey);
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _name);
    await prefs.setString(_emailKey, _email);
    if (_photoPath != null) {
      await prefs.setString(_photoPathKey, _photoPath!);
    } else {
      await prefs.remove(_photoPathKey);
    }
  }
} 