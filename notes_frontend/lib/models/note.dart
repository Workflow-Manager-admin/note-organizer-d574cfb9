/// Representation of a single note fetched from or sent to Supabase.
class Note {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // PUBLIC_INTERFACE
  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as int,
        title: map['title'] as String,
        content: map['content'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  // PUBLIC_INTERFACE
  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = {
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (includeId) map['id'] = id;
    return map;
  }
}
