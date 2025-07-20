import 'package:agridiary/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agridiary/providers/theme_provider.dart';
import 'dart:io';

class AppDrawer extends StatelessWidget {
  final Function(int) onNavigation;

  const AppDrawer({super.key, required this.onNavigation});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildDrawerHeader(context, userProfileProvider),
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  text: 'Home',
                  onTap: () => onNavigation(0),
                ),
                _buildDrawerItem(
                  icon: Icons.note_outlined,
                  text: 'Notes',
                  onTap: () => onNavigation(1),
                ),
                _buildDrawerItem(
                  icon: Icons.insights_outlined,
                  text: 'Insights',
                  onTap: () => onNavigation(2),
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  text: 'Profile',
                  onTap: () => onNavigation(3),
                ),
                _buildDrawerItem(
                  icon: Icons.group_outlined,
                  text: 'Add Farmers',
                  onTap: () {},
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: _buildDrawerItem(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () {
                // Implement logout functionality
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    UserProfileProvider userProfileProvider,
  ) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        userProfileProvider.name,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(userProfileProvider.email),
      currentAccountPicture: CircleAvatar(
        backgroundImage:
            userProfileProvider.photoPath != null
                ? FileImage(File(userProfileProvider.photoPath!))
                : const NetworkImage(
                      'https://i.pravatar.cc/150?u=a042581f4e29026704d',
                    )
                    as ImageProvider,
      ),
      decoration: const BoxDecoration(color: Colors.green),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(leading: Icon(icon), title: Text(text), onTap: onTap);
  }
}
