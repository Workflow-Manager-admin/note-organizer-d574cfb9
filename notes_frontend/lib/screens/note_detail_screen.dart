import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import 'note_edit_screen.dart';

/// Shows details for a single note, allows deleting and editing.
class NoteDetailScreen extends StatefulWidget {
  final String noteId;
  const NoteDetailScreen({super.key, required this.noteId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final NotesService _notesService = NotesService();
  Note? _note;
  bool _isLoading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    setState(() => _isLoading = true);
    try {
      final note = await _notesService.getNote(widget.noteId);
      setState(() => _note = note);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onEdit() async {
    if (_note == null) return;
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NoteEditScreen(note: _note!)),
    );
    if (changed == true) {
      _loadNote();
    }
  }

  void _onDelete() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text(
            "Are you sure you want to delete this note? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isDeleting = true);
    try {
      await _notesService.deleteNote(widget.noteId);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = _note;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _isDeleting ? null : _onDelete,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: _onEdit,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : note == null
              ? const Center(child: Text("Note not found."))
              : Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 23,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        note.content,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Text(
                        "Last edited: ${note.updatedAt.toLocal()}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
