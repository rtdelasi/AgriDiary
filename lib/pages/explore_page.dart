import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agridiary/models/task.dart';
import 'package:provider/provider.dart';
import 'package:agridiary/providers/task_provider.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final int _currentStreak = 7; // Example streak count
  final PageController _cropPageController = PageController();
  final ValueNotifier<int> _currentCropPageNotifier = ValueNotifier<int>(0);

  // Mocked best-selling crops data
  final List<Map<String, String>> _bestSellingCrops = [
    {
      'name': 'Tomato',
      'image': 'assets/images/tomato.jpg',
      'desc': 'High demand in markets, easy to grow in most climates.',
    },
    {
      'name': 'Maize',
      'image': 'assets/images/maize.jpg',
      'desc': 'Staple crop, widely grown and consumed.',
    },
    {
      'name': 'Rice',
      'image': 'assets/images/rice.jpg',
      'desc': 'Essential food crop, best-selling in many regions.',
    },
    {
      'name': 'Wheat',
      'image': 'assets/images/wheat.jpg',
      'desc': 'Popular for bread and flour, high market value.',
    },
    {
      'name': 'Potato',
      'image': 'assets/images/potatoes.jpg',
      'desc': 'Versatile crop, used in many dishes worldwide.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkTodayActivity();
  }

  @override
  void dispose() {
    _cropPageController.dispose();
    _currentCropPageNotifier.dispose();
    super.dispose();
  }

  void _checkTodayActivity() {
    // Check if user has been active today (opened app, completed tasks, etc.)
    // For now, we'll simulate this with a random check
  }

  void _showAddTaskDialog(TaskProvider taskProvider) {
    final TextEditingController taskController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new task'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(hintText: "Enter task title"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  taskProvider.addTask(taskController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildFarmerCard(),
                  const SizedBox(height: 24),
                  _buildMyPlansSection(cardColor, textColor),
                  const SizedBox(height: 24),
                  _buildWeatherSection(),
                  const SizedBox(height: 24),
                  _buildBestSellingCropsCarousel(cardColor, textColor),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset('assets/images/farmer.jpg', fit: BoxFit.cover),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.9),
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
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$_currentStreak days',
                                style: GoogleFonts.lato(
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
                    const SizedBox(height: 12),
                    Text(
                      'Welcome to AgriDiary',
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your digital farming companion',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPlansSection(Color cardColor, Color textColor) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Plans',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      taskProvider.getCurrentDate(),
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.orange,
                        size: 24,
                      ),
                      onPressed:
                          () => _showResetConfirmationDialog(taskProvider),
                      tooltip: 'Reset plans for today',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.green,
                        size: 30,
                      ),
                      onPressed: () => _showAddTaskDialog(taskProvider),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  taskProvider.tasks.isEmpty
                      ? Column(
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No plans for today',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your daily farming tasks to get started!',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                      : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: taskProvider.tasks.length,
                        itemBuilder: (context, index) {
                          final task = taskProvider.tasks[index];
                          return _buildTaskItem(task, index, taskProvider);
                        },
                        separatorBuilder:
                            (context, index) => const Divider(height: 24),
                      ),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmationDialog(TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Reset Plans',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to clear all plans for today? This action cannot be undone.',
            style: GoogleFonts.lato(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Reset'),
              onPressed: () {
                taskProvider.resetTasksForToday();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskItem(Task task, int index, TaskProvider taskProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final completedTextColor = isDarkMode ? Colors.grey[400] : Colors.grey;

    return InkWell(
      onTap: () => taskProvider.toggleTaskCompletion(index),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged:
                (bool? value) => taskProvider.toggleTaskCompletion(index),
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.lato(
                fontSize: 16,
                decoration:
                    task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                color: task.isCompleted ? completedTextColor : textColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => taskProvider.deleteTask(index),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSection() {
    // Implementation of _buildWeatherSection method
    return Container(); // Placeholder, actual implementation needed
  }

  Widget _buildBestSellingCropsCarousel(Color cardColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Best-Selling Crops',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _cropPageController,
            itemCount: _bestSellingCrops.length,
            onPageChanged: (index) => _currentCropPageNotifier.value = index,
            itemBuilder: (context, index) {
              final crop = _bestSellingCrops[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Image.network(
                        crop['image']!,
                        width: 90,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 90,
                              height: 180,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              crop['name']!,
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              crop['desc']!,
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: textColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: CirclePageIndicator(
            itemCount: _bestSellingCrops.length,
            currentPageNotifier: _currentCropPageNotifier,
            selectedDotColor: Colors.green,
            dotColor: Colors.grey.shade400,
            size: 10,
            selectedSize: 12,
          ),
        ),
      ],
    );
  }
}
