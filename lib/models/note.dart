class Note {
  final String id;
  final String title;
  final String filePath;
  final DateTime date;
  final Duration? duration;
  final String type; // 'audio' or 'text'

  Note({
    required this.id,
    required this.title,
    required this.filePath,
    required this.date,
    this.duration,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'date': date.toIso8601String(),
      'duration': duration?.inSeconds,
      'type': type,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      filePath: json['filePath'],
      date: DateTime.parse(json['date']),
      duration: json['duration'] != null 
          ? Duration(seconds: json['duration']) 
          : null,
      type: json['type'],
    );
  }
} 