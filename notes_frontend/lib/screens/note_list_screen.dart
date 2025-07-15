import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import 'note_detail_screen.dart';
import 'note_edit_screen.dart';

/// Displays the list of notes, supports search, and navigation to add/view/edit notes.
class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final NotesService _notesService = NotesService();
  List<Note> _notes = [];
  String _searchTerm = '';
  bool _isLoading = false;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes({String? search}) async {
    setState(() => _isLoading = true);
    try {
      final notes = await _notesService.fetchNotes(search: search);
      setState(() => _notes = notes);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() => _searchTerm = _searchController.text.trim());
    _loadNotes(search: _searchTerm);
  }

  void _goToDetail(Note note) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteDetailScreen(noteId: note.id),
        ),
    );
    _loadNotes(search: _searchTerm);
  }

  void _goToCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteEditScreen()),
    );
    _loadNotes(search: _searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    final notes = _notes;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _loadNotes(search: _searchTerm),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreate,
        tooltip: 'Add Note',
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : notes.isEmpty
                    ? const Center(
                        child: Text("No notes found."),
                      )
                    : ListView.separated(
                        itemCount: notes.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                        itemBuilder: (context, i) {
                          final note = notes[i];
                          return ListTile(
                            title: Text(
                              note.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            subtitle: Text(
                              note.content.length > 60
                                  ? '${note.content.substring(0, 60)}...'
                                  : note.content,
                            ),
                            onTap: () => _goToDetail(note),
                            trailing: const Icon(Icons.keyboard_arrow_right),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
