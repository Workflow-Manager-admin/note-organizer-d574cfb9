import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

/// Form for creating or editing a note.
class NoteEditScreen extends StatefulWidget {
  final Note? note; // If null, this is a create; else edit.

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final NotesService _notesService = NotesService();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      if (widget.note == null) {
        await _notesService.createNote(
            title: _titleController.text.trim(),
            content: _contentController.text.trim());
      } else {
        await _notesService.updateNote(
            id: widget.note!.id,
            title: _titleController.text.trim(),
            content: _contentController.text.trim());
      }
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Note" : "New Note"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: "Save",
            onPressed: _isSaving ? null : _onSave,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Title required" : null,
                maxLength: 70,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Content",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Content required" : null,
                maxLines: 8,
              ),
              if (_isSaving)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
