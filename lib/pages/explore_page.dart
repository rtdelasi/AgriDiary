import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agridiary/models/task.dart';
import 'package:provider/provider.dart';
import 'package:agridiary/providers/task_provider.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final int _currentStreak = 7; // Example streak count
  final int _longestStreak = 12; // Example longest streak
  bool _todayCompleted = false; // Track if user has been active today

  @override
  void initState() {
    super.initState();
    _checkTodayActivity();
  }

  void _checkTodayActivity() {
    // Check if user has been active today (opened app, completed tasks, etc.)
    // For now, we'll simulate this with a random check
    _todayCompleted = DateTime.now().hour > 12; // Simulate afternoon activity
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

  String _getStreakMessage() {
    if (_currentStreak == 0) {
      return 'Start your farming journey today!';
    } else if (_currentStreak == 1) {
      return 'Great start! Keep it going!';
    } else if (_currentStreak < 7) {
      return 'Building momentum! ${7 - _currentStreak} more days to a week!';
    } else if (_currentStreak < 30) {
      return 'Amazing consistency! You\'re on fire! 🔥';
    } else {
      return 'Legendary farmer! You\'re unstoppable! 💪';
    }
  }

  Color _getStreakColor() {
    if (_currentStreak == 0) return Colors.grey.shade600;
    if (_currentStreak < 3) return Colors.orange.shade600;
    if (_currentStreak < 7) return Colors.blue.shade600;
    if (_currentStreak < 30) return Colors.purple.shade600;
    return Colors.red.shade600; // Legendary streak
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDailyChallengeCard(),
                const SizedBox(height: 24),
                _buildMyPlansSection(cardColor, textColor),
                const SizedBox(height: 24),
                _buildFeaturesCard(),
                const SizedBox(
                  height: 24,
                ), // Add bottom padding for better scrolling
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallengeCard() {
    final streakColor = _getStreakColor();
    final streakMessage = _getStreakMessage();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [streakColor, streakColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: streakColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _todayCompleted
                              ? Icons.local_fire_department
                              : Icons.local_fire_department_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Activity Streak',
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      streakMessage,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '$_currentStreak',
                    style: GoogleFonts.lato(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'days',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Longest Streak',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '$_longestStreak days',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      _todayCompleted
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _todayCompleted ? Icons.check_circle : Icons.schedule,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _todayCompleted ? 'Completed' : 'Pending',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                Text(
                  'My Plans',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  taskProvider.tasks.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Text('No tasks yet. Add one!'),
                        ),
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

  Widget _buildFeaturesCard() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? Colors.purple.shade900 : Colors.purple.shade700;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Features',
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.mic, 'Record Audio Notes'),
          _buildFeatureItem(Icons.camera_alt, 'Capture Photo Notes'),
          _buildFeatureItem(Icons.bar_chart, 'View Insights'),
          _buildFeatureItem(Icons.check_circle_outline, 'Manage Tasks'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Text(
            text,
            style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
