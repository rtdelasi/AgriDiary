import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final NotificationService _notificationService = NotificationService();
  Map<String, bool> _settings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _notificationService.getNotificationSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    try {
      setState(() {
        _settings[key] = value;
      });
      
      await _notificationService.updateNotificationSettings(_settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getSettingTitle(key)} ${value ? 'enabled' : 'disabled'}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert the change if there was an error
      setState(() {
        _settings[key] = !value;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating setting: $e')),
        );
      }
    }
  }

  String _getSettingTitle(String key) {
    switch (key) {
      case 'weather_alerts':
        return 'Weather Alerts';
      case 'pest_alerts':
        return 'Pest Alerts';
      case 'crop_reminders':
        return 'Crop Reminders';
      case 'general_notifications':
        return 'General Notifications';
      default:
        return 'Notification';
    }
  }

  String _getSettingDescription(String key) {
    switch (key) {
      case 'weather_alerts':
        return 'Get notified about weather changes, storms, and extreme conditions that may affect your crops';
      case 'pest_alerts':
        return 'Receive alerts about pest outbreaks, diseases, and recommended treatment actions';
      case 'crop_reminders':
        return 'Daily reminders to check your crops for growth progress, water needs, and general monitoring';
      case 'general_notifications':
        return 'General app updates, tips, and farming advice notifications';
      default:
        return 'Notification setting';
    }
  }

  IconData _getSettingIcon(String key) {
    switch (key) {
      case 'weather_alerts':
        return Icons.cloud;
      case 'pest_alerts':
        return Icons.bug_report;
      case 'crop_reminders':
        return Icons.eco;
      case 'general_notifications':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  Color _getSettingColor(String key) {
    switch (key) {
      case 'weather_alerts':
        return Colors.blue;
      case 'pest_alerts':
        return Colors.orange;
      case 'crop_reminders':
        return Colors.green;
      case 'general_notifications':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _testNotification(String type) async {
    try {
      switch (type) {
        case 'weather_alerts':
          await _notificationService.showWeatherAlert(
            'Weather Alert Test',
            'This is a test weather alert notification.',
            'test',
          );
          break;
        case 'pest_alerts':
          await _notificationService.showPestAlert(
            'Pest Alert Test',
            'This is a test pest alert notification.',
            'test',
          );
          break;
        case 'crop_reminders':
          await _notificationService.showCropReminder(
            'Crop Reminder Test',
            'This is a test crop reminder notification.',
          );
          break;
        case 'general_notifications':
          await _notificationService.showGeneralNotification(
            'General Notification Test',
            'This is a test general notification.',
          );
          break;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending test notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: Colors.blue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Notification Preferences',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Customize which notifications you want to receive for your farming activities.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Notification Settings
                  ..._settings.entries.map((entry) => _buildNotificationSetting(
                    key: entry.key,
                    value: entry.value,
                    cardColor: cardColor,
                    textColor: textColor,
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // Test Notifications Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.science,
                              color: Colors.purple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Test Notifications',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send test notifications to verify your settings are working correctly.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _settings.entries.map((entry) => 
                            ElevatedButton.icon(
                              onPressed: () => _testNotification(entry.key),
                              icon: Icon(_getSettingIcon(entry.key), size: 16),
                              label: Text(_getSettingTitle(entry.key)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getSettingColor(entry.key).withValues(alpha: 0.1),
                                foregroundColor: _getSettingColor(entry.key),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationSetting({
    required String key,
    required bool value,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(
              _getSettingIcon(key),
              color: _getSettingColor(key),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getSettingTitle(key),
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Text(
            _getSettingDescription(key),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        value: value,
        onChanged: (newValue) => _updateSetting(key, newValue),
        activeColor: _getSettingColor(key),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
} 