import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

/// Provides CRUD and search operations for notes using Supabase.
class NotesService {
  final SupabaseClient _client;

  NotesService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  /// PUBLIC_INTERFACE
  /// Fetch all notes, optionally filtering by search term (case-insensitive search on title and content).
  Future<List<Note>> fetchNotes({String? search}) async {
    PostgrestFilterBuilder builder = _client.from('notes').select<List<Map<String, dynamic>>>();
    if (search != null && search.isNotEmpty) {
      builder = builder.ilike('title', '%$search%').or('content.ilike.%$search%');
    }
    builder = builder.order('updated_at', ascending: false);
    final data = await builder;
    return data.map((m) => Note.fromMap(m)).toList();
  }

  /// PUBLIC_INTERFACE
  /// Get details of a single note by ID.
  Future<Note?> getNote(int id) async {
    final data = await _client.from('notes').select().eq('id', id).single();
    return data == null ? null : Note.fromMap(data);
  }

  /// PUBLIC_INTERFACE
  /// Create a new note and return the created note.
  Future<Note> createNote({required String title, required String content}) async {
    final now = DateTime.now().toUtc();
    final maps = await _client.from('notes').insert({
      'title': title,
      'content': content,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    }).select<List<Map<String, dynamic>>>();
    return Note.fromMap(maps.first);
  }

  /// PUBLIC_INTERFACE
  /// Update a note by id.
  Future<Note> updateNote({required int id, required String title, required String content}) async {
    final now = DateTime.now().toUtc();
    final maps = await _client.from('notes').update({
      'title': title,
      'content': content,
      'updated_at': now.toIso8601String(),
    }).eq('id', id).select<List<Map<String, dynamic>>>();
    return Note.fromMap(maps.first);
  }

  /// PUBLIC_INTERFACE
  /// Delete a note by id.
  Future<void> deleteNote(int id) async {
    await _client.from('notes').delete().eq('id', id);
  }
}
