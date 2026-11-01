import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

/// DatabaseHelper mengelola koneksi dan operasi CRUD ke database SQLite.
///
/// Menggunakan Singleton pattern agar hanya ada satu instance database.
class DatabaseHelper {
  // ─── Singleton Setup ───────────────────────────────────────────────────────
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // ─── Konstanta Schema ──────────────────────────────────────────────────────
  static const String _dbName = 'notes_app.db';
  static const int _dbVersion = 1;
  static const String tableNotes = 'notes';

  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colContent = 'content';
  static const String colCategory = 'category';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // ─── Getter Database ───────────────────────────────────────────────────────

  /// Mendapatkan instance database, membuat jika belum ada.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ─── Inisialisasi ─────────────────────────────────────────────────────────

  /// Membuka atau membuat database di path yang sesuai.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Dipanggil pertama kali saat database dibuat – mendefinisikan skema tabel.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableNotes (
        $colId       INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTitle    TEXT    NOT NULL,
        $colContent  TEXT    NOT NULL,
        $colCategory TEXT    NOT NULL DEFAULT 'Umum',
        $colCreatedAt TEXT   NOT NULL,
        $colUpdatedAt TEXT   NOT NULL
      )
    ''');
  }

  /// Dipanggil saat versi database diperbarui.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Untuk praktikum: drop & recreate (production: pakai ALTER TABLE)
    await db.execute('DROP TABLE IF EXISTS $tableNotes');
    await _onCreate(db, newVersion);
  }

  // ─── CREATE ───────────────────────────────────────────────────────────────

  /// Menyisipkan catatan baru dan mengembalikan id yang dibuat.
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert(
      tableNotes,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── READ ─────────────────────────────────────────────────────────────────

  /// Mengambil semua catatan, diurutkan dari terbaru.
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query(
      tableNotes,
      orderBy: '$colCreatedAt DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  /// Mengambil satu catatan berdasarkan id.
  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final maps = await db.query(
      tableNotes,
      where: '$colId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  /// Mencari catatan berdasarkan kata kunci di title atau content.
  Future<List<Note>> searchNotes(String keyword) async {
    final db = await database;
    final maps = await db.query(
      tableNotes,
      where: '$colTitle LIKE ? OR $colContent LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: '$colCreatedAt DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  /// Mengambil catatan berdasarkan kategori.
  Future<List<Note>> getNotesByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      tableNotes,
      where: '$colCategory = ?',
      whereArgs: [category],
      orderBy: '$colCreatedAt DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────

  /// Memperbarui catatan yang sudah ada, mengembalikan jumlah baris terpengaruh.
  Future<int> updateNote(Note note) async {
    final db = await database;
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    return await db.update(
      tableNotes,
      updatedNote.toMap(),
      where: '$colId = ?',
      whereArgs: [note.id],
    );
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  /// Menghapus satu catatan berdasarkan id.
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      tableNotes,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  /// Menghapus semua catatan (untuk keperluan demo/reset).
  Future<int> deleteAllNotes() async {
    final db = await database;
    return await db.delete(tableNotes);
  }

  // ─── Utility ──────────────────────────────────────────────────────────────

  /// Menghitung total catatan yang tersimpan.
  Future<int> countNotes() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableNotes',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Menutup koneksi database.
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
