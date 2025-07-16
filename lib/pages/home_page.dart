import 'package:agridiary/pages/camera_capture_page.dart';
import 'package:agridiary/pages/explore_page.dart';
import 'package:agridiary/pages/insights_page.dart';
import 'package:agridiary/pages/notes_page.dart';
import 'package:agridiary/pages/profile_page.dart';
import 'package:agridiary/pages/notifications_page.dart';
import 'package:agridiary/pages/audio_recorder_page.dart';
import 'package:agridiary/providers/user_profile_provider.dart';
import 'package:agridiary/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/notification.dart';
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

    return Scaffold(
      drawer: AppDrawer(onNavigation: _onDrawerNavigation),
      appBar:
          _selectedIndex == 0
              ? AppBar(
                centerTitle: false,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi ${userProfileProvider.name.split(' ').first} 👋',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      _getGreeting(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, child) {
                        return IconButton.filledTonal(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsPage(),
                              ),
                            );
                          },
                          icon: badges.Badge(
                            badgeContent: Text(
                              notificationProvider.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            badgeStyle: const badges.BadgeStyle(
                              badgeColor: Colors.green,
                            ),
                            position: badges.BadgePosition.topEnd(
                              top: -15,
                              end: -12,
                            ),
                            showBadge: notificationProvider.unreadCount > 0,
                            child: const Icon(IconlyLight.notification),
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
        animatedIconTheme: const IconThemeData(size: 22.0),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        openCloseDial: isDialOpen,
        spacing: 10,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.mic),
            label: 'Record',
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
            child: const Icon(Icons.camera_alt),
            backgroundColor: Colors.purple,
            label: 'Capture',
            labelStyle: const TextStyle(fontSize: 16.0),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            activeIcon: Icon(Icons.note_alt),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
