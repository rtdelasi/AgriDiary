import 'package:flutter/material.dart';
import 'package:agridiary/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  static const String _storageKey = 'tasks';

  List<Task> get tasks => _tasks;

  TaskProvider() {
    _loadTasks();
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    try {
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