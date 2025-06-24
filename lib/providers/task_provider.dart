import 'package:flutter/material.dart';
import 'package:agridiary/models/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [
    Task(title: 'Check for pests', description: 'Inspect the north field'),
    Task(title: 'Water the crops', description: 'Use the new irrigation system'),
    Task(title: 'Harvest tomatoes', description: 'Morning harvest'),
    Task(title: 'Buy new seeds', description: 'Visit the local store'),
  ];

  List<Task> get tasks => _tasks;

  void addTask(String title) {
    _tasks.add(Task(title: title, description: ''));
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }

  void toggleTaskCompletion(int index) {
    _tasks[index] = Task(
      title: _tasks[index].title,
      description: _tasks[index].description,
      isCompleted: !_tasks[index].isCompleted,
    );
    notifyListeners();
  }
} 