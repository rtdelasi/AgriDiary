import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../services/notes_service.dart';
import '../models/note.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioRecorderPage extends StatefulWidget {
  final Function(Note) onSave;

  const AudioRecorderPage({super.key, required this.onSave});

  @override
  State<AudioRecorderPage> createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final NotesService _notesService = NotesService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _audioPath;
  Duration _recordDuration = Duration.zero;
  Timer? _timer;
  bool _isSaving = false;
  bool _isPlayback = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    final micStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();

    if (micStatus != PermissionStatus.granted ||
        storageStatus != PermissionStatus.granted) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('Permissions not granted')));
    }
  }

  void _startTimer() {
    _timer?.cancel();

    // Reset duration when starting a new recording
    setState(() => _recordDuration = Duration.zero);

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _recordDuration += const Duration(seconds: 1);
      });
    });
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = Directory.systemTemp;
        final filePath =
            '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: filePath);
        setState(() {
          _isRecording = true;
          _audioPath = filePath;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error starting recording: $e')));
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        if (path != null) _audioPath = path;
        _isPlayback = _audioPath != null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error stopping recording: $e')));
      }
    }
  }

  Future<void> _playAudio() async {
    if (_audioPath == null) return;
    setState(() => _isPlaying = true);
    await _audioPlayer.play(DeviceFileSource(_audioPath!));
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  void _resetRecording() {
    setState(() {
      _audioPath = null;
      _recordDuration = Duration.zero;
      _isPlayback = false;
      _isPlaying = false;
    });
  }

  Future<void> _saveRecording() async {
    if (_audioPath == null) return;

    setState(() => _isSaving = true);

    try {
      // Prompt for a display name before saving
      String? displayName;
      if (mounted) {
        displayName = await showDialog<String?>(
          context: context,
          builder: (dialogContext) {
            final controller = TextEditingController();
            return AlertDialog(
              title: const Text('Name this recording'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter a name (optional)',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  onPressed:
                      () => Navigator.of(
                        dialogContext,
                      ).pop(controller.text.trim()),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      }

      final note = await _notesService.createAudioNote(
        _audioPath!,
        _recordDuration,
        displayName: displayName,
      );
      widget.onSave(note);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio note saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Audio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording
                  ? Icons.mic
                  : (_isPlayback ? Icons.play_circle : Icons.mic_none),
              size: 80,
              color:
                  _isRecording
                      ? Colors.red
                      : (_isPlayback ? Colors.green : Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              _isRecording
                  ? 'Recording...'
                  : _isPlayback
                  ? 'Playback'
                  : 'Ready to record',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              '${_recordDuration.inMinutes.toString().padLeft(2, '0')}:'
              '${(_recordDuration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            if (_isSaving)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving note...'),
                ],
              )
            else if (_isPlayback && _audioPath != null)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.stop : Icons.play_arrow,
                          size: 40,
                        ),
                        onPressed: _isPlaying ? _stopAudio : _playAudio,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        onPressed: _saveRecording,
                      ),
                      const SizedBox(width: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.replay),
                        label: const Text('Record Again'),
                        onPressed: _resetRecording,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: _isRecording ? _stopRecording : _startRecording,
                child: Icon(_isRecording ? Icons.stop : Icons.mic, size: 40),
              ),
          ],
        ),
      ),
    );
  }
}
