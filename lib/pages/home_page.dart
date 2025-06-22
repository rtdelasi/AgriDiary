import 'package:agridiary/pages/explore_page.dart';
import 'package:agridiary/pages/insights_page.dart';
import 'package:agridiary/pages/notes_page.dart';
import 'package:agridiary/pages/profile_page.dart';
import 'package:agridiary/pages/audio_recorder_page.dart';
import 'package:agridiary/pages/camera_capture_page.dart'; // New import
import 'package:agridiary/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final pages = [
    const ExplorePage(),
    const NotesPage(),
    const InsightsPage(),
    const ProfilePage(),
  ];
  int currentIndex = 0;
  final ValueNotifier<bool> isDialOpen = ValueNotifier<bool>(false);

  void _onDrawerNavigation(int index) {
    setState(() {
      currentIndex = index;
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
      currentIndex = 1; // Switch to notes page
    });
  }

  // Handle captured photo note
  void _handleImageCaptured(Note note) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Photo note saved: ${note.title}')));
    // Switch to notes page to show the new note
    setState(() {
      currentIndex = 1; // Switch to notes page
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      drawer: AppDrawer(onNavigation: _onDrawerNavigation),
      appBar: currentIndex == 0
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
                    'Enjoy our services',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: IconButton.filledTonal(
                    onPressed: () {},
                    icon: badges.Badge(
                      badgeContent: const Text(
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      badgeStyle: const badges.BadgeStyle(badgeColor: Colors.green),
                      position: badges.BadgePosition.topEnd(top: -15, end: -12),
                      child: const Icon(IconlyLight.notification),
                    ),
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
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.home),
            activeIcon: Icon(IconlyBold.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.category),
            activeIcon: Icon(IconlyBold.category),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.show),
            activeIcon: Icon(IconlyBold.show),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.profile),
            activeIcon: Icon(IconlyBold.profile),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
