import 'package:flutter/material.dart';
import 'dart:io';

class ImagePreviewPage extends StatefulWidget {
  final String imagePath;
  final Function(String) onImageSelected;

  const ImagePreviewPage({
    super.key,
    required this.imagePath,
    required this.onImageSelected,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  String? _croppedImagePath;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _croppedImagePath = widget.imagePath;
  }

  void _useOriginalImage() {
    setState(() {
      _croppedImagePath = widget.imagePath;
    });
  }

  void _setAsProfilePicture() {
    if (_croppedImagePath != null) {
      widget.onImageSelected(_croppedImagePath!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Preview & Crop'),
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          if (_croppedImagePath != null)
            TextButton(
              onPressed: _setAsProfilePicture,
              child: const Text(
                'Set as Profile',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Preview Section
                          Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child:
                                  _croppedImagePath != null
                                      ? Image.file(
                                        File(_croppedImagePath!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.error,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      )
                                      : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.person,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _useOriginalImage,
                                icon: const Icon(Icons.check),
                                label: const Text('Use Image'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                                label: const Text('Cancel'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Instructions
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: cardColor,
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 24),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Use Image" to set this photo as your profile picture',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use the Crop button to adjust your image before setting it as profile picture',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
