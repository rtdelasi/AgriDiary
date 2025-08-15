import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

class NotesService {
  static const String _notesKey = 'notes';
  static const Uuid _uuid = Uuid();

  // Get all notes
  Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_notesKey) ?? [];

    return notesJson.map((json) => Note.fromJson(jsonDecode(json))).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_notesKey) ?? [];

    notesJson.add(jsonEncode(note.toJson()));
    await prefs.setStringList(_notesKey, notesJson);
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_notesKey) ?? [];

    final notes =
        notesJson
            .map((json) => Note.fromJson(jsonDecode(json)))
            .where((note) => note.id != noteId)
            .map((note) => jsonEncode(note.toJson()))
            .toList();

    await prefs.setStringList(_notesKey, notes);
  }

  // Update a note's title
  Future<void> updateNoteTitle(String noteId, String newTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_notesKey) ?? [];
    final notes =
        notesJson
            .map((json) => Note.fromJson(jsonDecode(json)))
            .map((note) {
              if (note.id == noteId) {
                // Preserve images and recordings when updating title
                return Note(
                  id: note.id,
                  title: newTitle,
                  filePath: note.filePath,
                  date: note.date,
                  duration: note.duration,
                  type: note.type,
                  images: note.images,
                  recordings: note.recordings,
                );
              }
              return note;
            })
            .map((note) => jsonEncode(note.toJson()))
            .toList();

    await prefs.setStringList(_notesKey, notes);
  }

  // Update a NamedFile's name (either in images or recordings) identified by its file path
  Future<void> updateNamedFileName(
    String noteId,
    String filePath,
    String newName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_notesKey) ?? [];

    final notes =
        notesJson
            .map((json) => Note.fromJson(jsonDecode(json)))
            .map((note) {
              if (note.id == noteId) {
                final updatedImages =
                    note.images.map((img) {
                      if (img.path == filePath) {
                        return NamedFile(name: newName, path: img.path);
                      }
                      return img;
                    }).toList();

                final updatedRecordings =
                    note.recordings.map((rec) {
                      if (rec.path == filePath) {
                        return NamedFile(name: newName, path: rec.path);
                      }
                      return rec;
                    }).toList();

                return Note(
                  id: note.id,
                  title: note.title,
                  filePath: note.filePath,
                  date: note.date,
                  duration: note.duration,
                  type: note.type,
                  images: updatedImages,
                  recordings: updatedRecordings,
                );
              }
              return note;
            })
            .map((note) => jsonEncode(note.toJson()))
            .toList();

    await prefs.setStringList(_notesKey, notes);
  }

  // Migration helper: fill missing NamedFile.name values from the file basename
  Future<void> migrateFillNamesFromBasename() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_notesKey) ?? [];

    bool changed = false;

    final migrated =
        notesJson
            .map((json) => Note.fromJson(jsonDecode(json)))
            .map((note) {
              final updatedImages =
                  note.images.map((img) {
                    if (img.name.trim().isEmpty) {
                      changed = true;
                      final base =
                          Uri.file(img.path).pathSegments.isNotEmpty
                              ? Uri.file(img.path).pathSegments.last
                              : img.path;
                      return NamedFile(name: base, path: img.path);
                    }
                    return img;
                  }).toList();

              final updatedRecordings =
                  note.recordings.map((rec) {
                    if (rec.name.trim().isEmpty) {
                      changed = true;
                      final base =
                          Uri.file(rec.path).pathSegments.isNotEmpty
                              ? Uri.file(rec.path).pathSegments.last
                              : rec.path;
                      return NamedFile(name: base, path: rec.path);
                    }
                    return rec;
                  }).toList();

              if (identical(updatedImages, note.images) &&
                  identical(updatedRecordings, note.recordings)) {
                return note;
              }

              return Note(
                id: note.id,
                title: note.title,
                filePath: note.filePath,
                date: note.date,
                duration: note.duration,
                type: note.type,
                images: updatedImages,
                recordings: updatedRecordings,
              );
            })
            .map((note) => jsonEncode(note.toJson()))
            .toList();

    if (changed) {
      await prefs.setStringList(_notesKey, migrated);
    }
  }

  // Save audio file to app documents directory
  Future<String> saveAudioFile(String tempPath) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${documentsDir.path}/audio_notes');

    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final newPath = '${audioDir.path}/$fileName';

    final tempFile = File(tempPath);
    if (await tempFile.exists()) {
      await tempFile.copy(newPath);
      await tempFile.delete(); // Clean up temp file
    }

    return newPath;
  }

  // Save photo file to app documents directory
  Future<String> savePhotoFile(String tempPath) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${documentsDir.path}/photo_notes');

    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${photoDir.path}/$fileName';

    final tempFile = File(tempPath);
    if (await tempFile.exists()) {
      await tempFile.copy(newPath);
      await tempFile.delete(); // Clean up temp file
    }

    return newPath;
  }

  // Create a new audio note
  Future<Note> createAudioNote(
    String tempAudioPath,
    Duration duration, {
    String? displayName,
  }) async {
    final audioPath = await saveAudioFile(tempAudioPath);
    final now = DateTime.now();

    final title =
        (displayName != null && displayName.trim().isNotEmpty)
            ? displayName.trim()
            : 'Audio Note - ${_formatDateTime(now)}';

    final fileName =
        (displayName != null && displayName.trim().isNotEmpty)
            ? displayName.trim()
            : File(audioPath).uri.pathSegments.last;

    final note = Note(
      id: _uuid.v4(),
      title: title,
      filePath: audioPath,
      date: now,
      duration: duration,
      type: 'audio',
      recordings: [NamedFile(name: fileName, path: audioPath)],
    );

    await addNote(note);
    return note;
  }

  // Create a new photo note
  Future<Note> createPhotoNote(
    String tempPhotoPath, {
    String? displayName,
  }) async {
    final photoPath = await savePhotoFile(tempPhotoPath);
    final now = DateTime.now();

    final title =
        (displayName != null && displayName.trim().isNotEmpty)
            ? displayName.trim()
            : 'Photo Note - ${_formatDateTime(now)}';

    final fileName =
        (displayName != null && displayName.trim().isNotEmpty)
            ? displayName.trim()
            : File(photoPath).uri.pathSegments.last;

    final note = Note(
      id: _uuid.v4(),
      title: title,
      filePath: photoPath,
      date: now,
      duration: null,
      type: 'photo',
      images: [NamedFile(name: fileName, path: photoPath)],
    );

    await addNote(note);
    return note;
  }

  // Format date and time for note title
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Check if audio file exists
  Future<bool> audioFileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  // Check if photo file exists
  Future<bool> photoFileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }
}
