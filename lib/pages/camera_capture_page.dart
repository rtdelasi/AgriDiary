// camera_capture_page.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../services/notes_service.dart';
import '../models/note.dart';

class CameraCapturePage extends StatefulWidget {
  final Function(Note) onImageCaptured;

  const CameraCapturePage({super.key, required this.onImageCaptured});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final NotesService _notesService = NotesService();
  bool _isLoading = true;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();

    await _initializeControllerFuture;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    setState(() => _isCapturing = true);
    try {
      await _initializeControllerFuture;

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final image = await _controller.takePicture();
      await image.saveTo(filePath);

      // Prompt for a display name before saving
      String? displayName;
      if (mounted) {
        displayName = await showDialog<String?>(
          context: context,
          builder: (dialogContext) {
            final controller = TextEditingController();
            return AlertDialog(
              title: const Text('Name this photo'),
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

      // Save as note with picked image
      final note = await _notesService.createPhotoNote(
        filePath,
        displayName: displayName,
      );
      widget.onImageCaptured(note);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Photo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              // Toggle flash logic would go here
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(child: CameraPreview(_controller)),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FloatingActionButton(
                      onPressed: _isCapturing ? null : _takePicture,
                      child:
                          _isCapturing
                              ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                              : const Icon(Icons.camera),
                    ),
                  ),
                ],
              ),
    );
  }
}
