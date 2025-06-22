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
    
    return notesJson
        .map((json) => Note.fromJson(jsonDecode(json)))
        .toList()
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
    
    final notes = notesJson
        .map((json) => Note.fromJson(jsonDecode(json)))
        .where((note) => note.id != noteId)
        .map((note) => jsonEncode(note.toJson()))
        .toList();
    
    await prefs.setStringList(_notesKey, notes);
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
  Future<Note> createAudioNote(String tempAudioPath, Duration duration) async {
    final audioPath = await saveAudioFile(tempAudioPath);
    final now = DateTime.now();
    
    final note = Note(
      id: _uuid.v4(),
      title: 'Audio Note - ${_formatDateTime(now)}',
      filePath: audioPath,
      date: now,
      duration: duration,
      type: 'audio',
    );
    
    await addNote(note);
    return note;
  }

  // Create a new photo note
  Future<Note> createPhotoNote(String tempPhotoPath) async {
    final photoPath = await savePhotoFile(tempPhotoPath);
    final now = DateTime.now();
    
    final note = Note(
      id: _uuid.v4(),
      title: 'Photo Note - ${_formatDateTime(now)}',
      filePath: photoPath,
      date: now,
      duration: null,
      type: 'photo',
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