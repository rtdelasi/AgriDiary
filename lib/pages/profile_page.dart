import 'package:agridiary/pages/edit_profile_page.dart';
import 'package:agridiary/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agridiary/providers/theme_provider.dart';
import 'dart:io';

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
        CircleAvatar(
          radius: 50,
          backgroundImage: userProfileProvider.photoPath != null
              ? FileImage(File(userProfileProvider.photoPath!))
              : const NetworkImage(
                      'https://i.pravatar.cc/150?u=a042581f4e29026704d')
                  as ImageProvider,
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
            onTap: () {},
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
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
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
