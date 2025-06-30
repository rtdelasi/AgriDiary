import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/theme_provider.dart';
import '../providers/user_profile_provider.dart';
import 'edit_profile_page.dart';
import 'image_preview_page.dart';
import 'permission_settings_page.dart';
import 'notification_settings_page.dart';
import 'help_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _navigateToEditProfile(UserProfileProvider userProfileProvider) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          currentName: userProfileProvider.name,
          currentEmail: userProfileProvider.email,
        ),
      ),
    );

    if (result != null && result is Map) {
      userProfileProvider.updateProfile(result['name'], result['email']);
    }
  }

  Future<void> _pickImageFromGallery(UserProfileProvider userProfileProvider) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImagePreviewPage(
              imagePath: image.path,
              onImageSelected: (String croppedImagePath) {
                userProfileProvider.updateProfilePhoto(croppedImagePath);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile photo updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerDialog(UserProfileProvider userProfileProvider) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can preview your image before setting it as profile picture',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Preview before setting'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery(userProfileProvider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Current Photo'),
                onTap: () {
                  Navigator.pop(context);
                  userProfileProvider.updateProfilePhoto('');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile photo removed'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 24),
          _buildProfileHeader(userProfileProvider),
          const SizedBox(height: 32),
          _buildProfileMenu(context, themeProvider, userProfileProvider),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileProvider userProfileProvider) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => _showImagePickerDialog(userProfileProvider),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: userProfileProvider.photoPath != null && userProfileProvider.photoPath!.isNotEmpty
                    ? FileImage(File(userProfileProvider.photoPath!))
                    : const NetworkImage(
                            'https://i.pravatar.cc/150?u=a042581f4e29026704d')
                        as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userProfileProvider.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          userProfileProvider.email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the photo to change it',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context, ThemeProvider themeProvider, UserProfileProvider userProfileProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          _buildMenuItem(
            context,
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () => _navigateToEditProfile(userProfileProvider),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            secondary: const Icon(Icons.dark_mode_outlined),
          ),
          const Divider(),
          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          _buildMenuItem(
            context,
            icon: Icons.security_outlined,
            title: 'Privacy & Security',
            onTap: () {},
          ),
          const Divider(),
          _buildMenuItem(
            context,
            icon: Icons.perm_device_info,
            title: 'Permission Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PermissionSettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpPage(),
                ),
              );
            },
          ),
          const Divider(),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  ListTile _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
