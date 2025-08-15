import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final NotesService _notesService = NotesService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String? _currentlyPlayingPath;
  Duration _currentPosition = Duration.zero;
  Duration _currentDuration = Duration.zero;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  final Set<String> _selectedNoteIds = <String>{};
  bool _selectionMode = false;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _applySearch();
    });
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredNotes = _notes;
    } else {
      _filteredNotes =
          _notes.where((note) {
            final query = _searchQuery;
            final inTitle = note.title.toLowerCase().contains(query);
            final inImages = note.images.any(
              (img) => img.name.toLowerCase().contains(query),
            );
            final inRecordings = note.recordings.any(
              (rec) => rec.name.toLowerCase().contains(query),
            );
            return inTitle || inImages || inRecordings;
          }).toList();
    }
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _notesService.getNotes();
      setState(() {
        _notes = notes;
        _applySearch();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading notes: $e')));
      }
    }
  }

  // Play audio by file path (used for individual recordings)
  Future<void> _playAudioPath(String path) async {
    try {
      if (_currentlyPlayingPath == path) {
        await _audioPlayer.stop();
        // stop and clear playback state
        _positionSubscription?.cancel();
        _durationSubscription?.cancel();
        setState(() {
          _currentlyPlayingPath = null;
          _currentPosition = Duration.zero;
          _currentDuration = Duration.zero;
        });
        return;
      }

      // stop any existing playback
      await _audioPlayer.stop();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      setState(() {
        _currentPosition = Duration.zero;
        _currentDuration = Duration.zero;
      });

      final fileExists = await File(path).exists();
      if (!fileExists) {
        throw Exception('Audio file not found');
      }

      await _audioPlayer.play(DeviceFileSource(path));
      setState(() => _currentlyPlayingPath = path);

      // listen for duration updates
      _durationSubscription = _audioPlayer.onDurationChanged.listen((dur) {
        if (mounted) setState(() => _currentDuration = dur);
      });

      // listen for position updates
      _positionSubscription = _audioPlayer.onPositionChanged.listen((pos) {
        if (mounted) setState(() => _currentPosition = pos);
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        _positionSubscription?.cancel();
        _durationSubscription?.cancel();
        if (mounted) {
          setState(() {
            _currentlyPlayingPath = null;
            _currentPosition = Duration.zero;
            _currentDuration = Duration.zero;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
      }
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) {
      return n.toString().padLeft(2, '0');
    }

    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _showImagePreview(String path) async {
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return Dialog(
            backgroundColor: Colors.transparent,
            child: InteractiveViewer(
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.image_not_supported,
                        color: theme.colorScheme.outline,
                      ),
                    ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening image: $e')));
      }
    }
  }

  Future<void> _deleteNote(Note note) async {
    try {
      await _notesService.deleteNote(note.id);
      await _loadNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting note: $e')));
      }
    }
  }

  Future<void> _showRenameNoteDialog(Note note) async {
    final newTitle = await showDialog<String?>(
      context: context,
      builder: (dialogCtx) {
        final controller = TextEditingController(text: note.title);
        return AlertDialog(
          title: const Text('Rename note'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter new title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed:
                  () => Navigator.of(dialogCtx).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      await _notesService.updateNoteTitle(note.id, newTitle);
      await _loadNotes();
    }
  }

  Future<void> _confirmAndRunMigration() async {
    final confirmed = await showDialog<bool?>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Migrate file names'),
          content: const Text(
            'This will fill empty image/recording names with their file basenames. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Run'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _notesService.migrateFillNamesFromBasename();
      await _loadNotes();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Migration completed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Notes',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          if (_selectionMode) ...[
                            IconButton(
                              onPressed: () {
                                // toggle select all
                                _toggleSelectAll();
                              },
                              icon: Icon(
                                _selectedNoteIds.length ==
                                            _filteredNotes.length &&
                                        _filteredNotes.isNotEmpty
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              tooltip: 'Select all',
                            ),
                            IconButton(
                              onPressed:
                                  _selectedNoteIds.isEmpty
                                      ? null
                                      : () => _confirmAndDeleteSelected(),
                              icon: Icon(
                                Icons.delete_outline,
                                color:
                                    _selectedNoteIds.isEmpty
                                        ? theme.colorScheme.onSurface
                                            .withValues(alpha: 0.3)
                                        : theme.colorScheme.error,
                                size: 24,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectionMode = false;
                                  _selectedNoteIds.clear();
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ] else ...[
                            IconButton(
                              onPressed: _loadNotes,
                              icon: Icon(
                                Icons.refresh,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            IconButton(
                              onPressed: _confirmAndRunMigration,
                              tooltip: 'Migrate note file names',
                              icon: Icon(
                                Icons.sync,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectionMode = true;
                                });
                              },
                              tooltip: 'Select notes',
                              icon: Icon(
                                Icons.select_all,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                                size: 24,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search notes...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Notes List
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      )
                      : _filteredNotes.isEmpty
                      ? _buildEmptyState(theme)
                      : RefreshIndicator(
                        onRefresh: _loadNotes,
                        color: theme.colorScheme.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredNotes.length,
                          itemBuilder: (context, index) {
                            return _buildNoteCard(_filteredNotes[index], theme);
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notes yet',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first note using the camera or microphone',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note, ThemeData theme) {
    final hasImages = note.images.isNotEmpty;
    final hasRecordings = note.recordings.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Note Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteNote(note);
                        } else if (value == 'rename') {
                          _showRenameNoteDialog(note);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rename',
                                    style: GoogleFonts.inter(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: GoogleFonts.inter(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(note.date),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Images Section
          if (hasImages) ...[
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: note.images.length,
                itemBuilder: (context, index) {
                  final image = note.images[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            onTap: () => _showImagePreview(image.path),
                            child: Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Material(
                              color: theme.colorScheme.surface.withValues(
                                alpha: 0.6,
                              ),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () async {
                                  final newName = await showDialog<String?>(
                                    context: context,
                                    builder: (dialogCtx) {
                                      final controller = TextEditingController(
                                        text: image.name,
                                      );
                                      return AlertDialog(
                                        title: const Text('Rename image'),
                                        content: TextField(
                                          controller: controller,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter name',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  dialogCtx,
                                                ).pop(null),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  dialogCtx,
                                                ).pop(controller.text.trim()),
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (newName != null && newName.isNotEmpty) {
                                    await _notesService.updateNamedFileName(
                                      note.id,
                                      image.path,
                                      newName,
                                    );
                                    await _loadNotes();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Recordings Section
          if (hasRecordings) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children:
                    note.recordings.map((recording) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => _playAudioPath(recording.path),
                              icon: Icon(
                                _currentlyPlayingPath == recording.path
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          recording.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          final newName = await showDialog<
                                            String?
                                          >(
                                            context: context,
                                            builder: (dialogCtx) {
                                              final controller =
                                                  TextEditingController(
                                                    text: recording.name,
                                                  );
                                              return AlertDialog(
                                                title: const Text(
                                                  'Rename recording',
                                                ),
                                                content: TextField(
                                                  controller: controller,
                                                  decoration:
                                                      const InputDecoration(
                                                        hintText: 'Enter name',
                                                      ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          dialogCtx,
                                                        ).pop(null),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          dialogCtx,
                                                        ).pop(
                                                          controller.text
                                                              .trim(),
                                                        ),
                                                    child: const Text('Save'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (newName != null &&
                                              newName.isNotEmpty) {
                                            await _notesService
                                                .updateNamedFileName(
                                                  note.id,
                                                  recording.path,
                                                  newName,
                                                );
                                            await _loadNotes();
                                          }
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Audio recording',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  if (_currentlyPlayingPath == recording.path)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        children: [
                                          LinearProgressIndicator(
                                            value:
                                                _currentDuration > Duration.zero
                                                    ? (_currentPosition
                                                                .inMilliseconds /
                                                            _currentDuration
                                                                .inMilliseconds)
                                                        .clamp(0.0, 1.0)
                                                    : null,
                                            color: theme.colorScheme.primary,
                                            backgroundColor: theme
                                                .colorScheme
                                                .surface
                                                .withValues(alpha: 0.04),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _formatDuration(
                                                  _currentPosition,
                                                ),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                              Text(
                                                _formatDuration(
                                                  _currentDuration,
                                                ),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_currentlyPlayingPath == recording.path)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
