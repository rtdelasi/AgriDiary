import 'package:agridiary/models/notification.dart';
import 'package:agridiary/pages/audio_recorder_page.dart';
import 'package:agridiary/pages/camera_capture_page.dart';
import 'package:agridiary/pages/explore_page.dart';
import 'package:agridiary/pages/insights_page.dart';
import 'package:agridiary/pages/notes_page.dart';
import 'package:agridiary/pages/notifications_page.dart';
import 'package:agridiary/pages/profile_page.dart';
import 'package:agridiary/providers/notification_provider.dart';
import 'package:agridiary/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ExplorePage(),
    const NotesPage(),
    const InsightsPage(),
    const ProfilePage(),
  ];

  final ValueNotifier<bool> isDialOpen = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // Load notifications when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
      _addSampleNotifications();
    });
  }

  void _addSampleNotifications() {
    final notificationProvider = context.read<NotificationProvider>();

    // Add some sample notifications if none exist
    if (notificationProvider.notifications.isEmpty) {
      final sampleNotifications = [
        AppNotification(
          id: '1',
          title: 'Daily Planning Reminder',
          message:
              'Good morning! Time to plan your day. Add tasks and organize your farming activities.',
          type: 'daily_planning_reminder',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AppNotification(
          id: '2',
          title: 'Weather Alert',
          message:
              'Heavy rain expected in the next 24 hours. Consider protecting your crops.',
          type: 'weather_alert',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        AppNotification(
          id: '3',
          title: 'Crop Check Reminder',
          message:
              'Time to check your crops! Monitor for pests, water needs, and growth progress.',
          type: 'crop_reminder',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      for (final notification in sampleNotifications) {
        notificationProvider.addNotification(notification);
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void _onDrawerNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  // Handle saved audio note
  void _handleAudioSaved(Note note) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Audio note saved: ${note.title}')));
    // Switch to notes page to show the new note
    setState(() {
      _selectedIndex = 1; // Switch to notes page
    });
  }

  // Handle captured photo note
  void _handleImageCaptured(Note note) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Photo note saved: ${note.title}')));
    // Switch to notes page to show the new note
    setState(() {
      _selectedIndex = 1; // Switch to notes page
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: AppDrawer(
        onNavigation: _onDrawerNavigation,
      ),
      appBar: _selectedIndex == 0
          ? AppBar(
              centerTitle: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi ${userProfileProvider.name.split(' ').first} 👋',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _getGreeting(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: badges.Badge(
                              badgeContent: Text(
                                notificationProvider.unreadCount.toString(),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              badgeStyle: badges.BadgeStyle(
                                badgeColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.all(4),
                              ),
                              position: badges.BadgePosition.topEnd(
                                top: -8,
                                end: -8,
                              ),
                              showBadge: notificationProvider.unreadCount > 0,
                              child: Icon(
                                IconlyLight.notification,
                                color: theme.colorScheme.onSurface,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : null,
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(
          size: 22.0,
          color: theme.colorScheme.onPrimary,
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        openCloseDial: isDialOpen,
        spacing: 16,
        spaceBetweenChildren: 16,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.mic, color: Colors.white),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            label: 'Record Audio',
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AudioRecorderPage(onSave: _handleAudioSaved),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.camera_alt, color: Colors.white),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.white,
            label: 'Capture Photo',
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CameraCapturePage(
                        onImageCaptured: _handleImageCaptured,
                      ),
                ),
              );
            },
          ),
        ],
        onOpen: () => isDialOpen.value = true,
        onClose: () => isDialOpen.value = false,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.colorScheme.surface,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedIndex == 0
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                    size: 24,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedIndex == 1
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _selectedIndex == 1 ? Icons.note_alt : Icons.note_alt_outlined,
                    size: 24,
                  ),
                ),
                label: 'Notes',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedIndex == 2
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _selectedIndex == 2 ? Icons.insights : Icons.insights_outlined,
                    size: 24,
                  ),
                ),
                label: 'Insights',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedIndex == 3
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _selectedIndex == 3 ? Icons.person : Icons.person_outline,
                    size: 24,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
