import 'package:agridiary/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agridiary/providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class AppDrawer extends StatelessWidget {
  final Function(int) onNavigation;

  const AppDrawer({super.key, required this.onNavigation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
                         colors: [
               theme.colorScheme.primary.withValues(alpha: 0.1),
               theme.colorScheme.surface,
             ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildDrawerHeader(context, userProfileProvider, theme),
                  const SizedBox(height: 20),
                  _buildDrawerItem(
                    icon: Icons.home_outlined,
                    text: 'Home',
                    onTap: () => onNavigation(0),
                    theme: theme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.note_outlined,
                    text: 'Notes',
                    onTap: () => onNavigation(1),
                    theme: theme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.insights_outlined,
                    text: 'Insights',
                    onTap: () => onNavigation(2),
                    theme: theme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    text: 'Profile',
                    onTap: () => onNavigation(3),
                    theme: theme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.group_outlined,
                    text: 'Add Farmers',
                    onTap: () {},
                    theme: theme,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          themeProvider.themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Theme',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                themeProvider.themeMode == ThemeMode.dark
                                    ? 'Dark Mode'
                                    : 'Light Mode',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: themeProvider.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: _buildDrawerItem(
                icon: Icons.logout,
                text: 'Logout',
                onTap: () {
                  // Implement logout functionality
                  Navigator.of(context).pop();
                },
                theme: theme,
                isLogout: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    UserProfileProvider userProfileProvider,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
                     colors: [
             theme.colorScheme.primary,
             theme.colorScheme.primary.withValues(alpha: 0.8),
           ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: userProfileProvider.photoPath != null
                      ? FileImage(File(userProfileProvider.photoPath!))
                      : null,
                  child: userProfileProvider.photoPath == null
                      ? Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfileProvider.name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProfileProvider.email,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.agriculture,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Active Farmer',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
    required ThemeData theme,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isLogout 
            ? theme.colorScheme.error.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
                     color: isLogout
             ? theme.colorScheme.error.withValues(alpha: 0.1)
             : theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isLogout
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isLogout
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
