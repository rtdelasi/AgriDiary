class Task {
  final String title;
  final String description;
  final bool isCompleted;

  Task({required this.title, required this.description, this.isCompleted = false});

  // Convert Task to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
} 