/// Model untuk tabel `notes` di database SQLite.
class Note {
  final int? id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Konversi dari Map (hasil query SQLite) ke objek Note.
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Konversi dari objek Note ke Map untuk disimpan ke SQLite.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Membuat salinan Note dengan field yang diperbarui.
  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Note(id: $id, title: $title, category: $category)';
}
