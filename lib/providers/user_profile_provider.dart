import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider with ChangeNotifier {
  String _name = 'Wilson Daniels';
  String _email = 'wilsondaniels@email.com';

  static const String _nameKey = 'userName';
  static const String _emailKey = 'userEmail';

  String get name => _name;
  String get email => _email;

  UserProfileProvider() {
    _loadProfile();
  }

  void updateProfile(String newName, String newEmail) {
    _name = newName;
    _email = newEmail;
    _saveProfile();
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey) ?? 'Wilson Daniels';
    _email = prefs.getString(_emailKey) ?? 'wilsondaniels@email.com';
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _name);
    await prefs.setString(_emailKey, _email);
  }
} 