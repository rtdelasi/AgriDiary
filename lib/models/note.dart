class NamedFile {
  final String name;
  final String path;

  NamedFile({required this.name, required this.path});

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
  };

  factory NamedFile.fromJson(Map<String, dynamic> json) => NamedFile(
    name: json['name'] ?? '',
    path: json['path'] ?? '',
  );
}

class Note {
  final String id;
  final String title;
  final String filePath;
  final DateTime date;
  final Duration? duration;
  final String type; // 'audio' or 'text'
  final List<NamedFile> images;
  final List<NamedFile> recordings;

  Note({
    required this.id,
    required this.title,
    required this.filePath,
    required this.date,
    this.duration,
    required this.type,
    List<NamedFile>? images,
    List<NamedFile>? recordings,
  })  : images = images ?? [],
        recordings = recordings ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'date': date.toIso8601String(),
      'duration': duration?.inSeconds,
      'type': type,
      'images': images.map((e) => e.toJson()).toList(),
      'recordings': recordings.map((e) => e.toJson()).toList(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    List<NamedFile> parseNamedFileList(dynamic list) {
      if (list == null) return [];
      if (list is List) {
        if (list.isNotEmpty && list.first is String) {
          // Backward compatibility: List<String>
          return list.map((e) => NamedFile(name: '', path: e)).toList();
        } else {
          return list.map((e) => NamedFile.fromJson(e)).toList();
        }
      }
      return [];
    }
    return Note(
      id: json['id'],
      title: json['title'],
      filePath: json['filePath'],
      date: DateTime.parse(json['date']),
      duration: json['duration'] != null 
          ? Duration(seconds: json['duration']) 
          : null,
      type: json['type'],
      images: parseNamedFileList(json['images']),
      recordings: parseNamedFileList(json['recordings']),
    );
  }
} 