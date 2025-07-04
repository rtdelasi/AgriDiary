import 'package:flutter/material.dart';
import 'package:agridiary/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  static const String _storageKey = 'tasks';
  static const String _lastResetDateKey = 'last_reset_date';

  List<Task> get tasks => _tasks;

  TaskProvider() {
    _loadTasks();
  }

  // Check if it's a new day and reset tasks if needed
  Future<void> _checkAndResetDaily() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastResetDate = prefs.getString(_lastResetDateKey);
      final today = DateTime.now().toIso8601String().split('T')[0]; // Get YYYY-MM-DD format
      
      // If no last reset date or it's a different day, reset tasks
      if (lastResetDate == null || lastResetDate != today) {
        _tasks.clear();
        await prefs.setString(_lastResetDateKey, today);
        await _saveTasks();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking daily reset: $e');
    }
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    try {
      // First check if we need to reset for a new day
      await _checkAndResetDaily();
      
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_storageKey) ?? [];
      
      _tasks = tasksJson
          .map((taskJson) => Task.fromJson(json.decode(taskJson)))
          .toList();
      
      // If no tasks are saved, add default tasks
      if (_tasks.isEmpty) {
        _tasks = [
          Task(title: 'Check for pests', description: 'Inspect the north field'),
          Task(title: 'Water the crops', description: 'Use the new irrigation system'),
          Task(title: 'Harvest tomatoes', description: 'Morning harvest'),
          Task(title: 'Buy new seeds', description: 'Visit the local store'),
        ];
        await _saveTasks();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      // Fallback to default tasks if loading fails
      _tasks = [
        Task(title: 'Check for pests', description: 'Inspect the north field'),
        Task(title: 'Water the crops', description: 'Use the new irrigation system'),
        Task(title: 'Harvest tomatoes', description: 'Morning harvest'),
        Task(title: 'Buy new seeds', description: 'Visit the local store'),
      ];
      notifyListeners();
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = _tasks
          .map((task) => json.encode(task.toJson()))
          .toList();
      await prefs.setStringList(_storageKey, tasksJson);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  // Manually reset tasks for the current day
  Future<void> resetTasksForToday() async {
    _tasks.clear();
    await _saveTasks();
    notifyListeners();
  }

  // Get the current date for display
  String getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  void addTask(String title) {
    _tasks.add(Task(title: title, description: ''));
    _saveTasks();
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(int index) {
    _tasks[index] = Task(
      title: _tasks[index].title,
      description: _tasks[index].description,
      isCompleted: !_tasks[index].isCompleted,
    );
    _saveTasks();
    notifyListeners();
  }
} 