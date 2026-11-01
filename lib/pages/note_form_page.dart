import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/note.dart';

/// Halaman form untuk CREATE dan UPDATE catatan.
class NoteFormPage extends StatefulWidget {
  /// Jika [note] null → mode CREATE, jika ada → mode UPDATE.
  final Note? note;

  const NoteFormPage({super.key, this.note});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper.instance;

  bool get _isEditing => widget.note != null;
  bool _isSaving = false;
  String _selectedCategory = 'Umum';

  final List<String> _categories = [
    'Umum', 'Pekerjaan', 'Pribadi', 'Ide', 'Penting'
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedCategory = widget.note!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Pekerjaan': return const Color(0xFF3B82F6);
      case 'Pribadi': return const Color(0xFF8B5CF6);
      case 'Ide': return const Color(0xFFF59E0B);
      case 'Penting': return const Color(0xFFEF4444);
      default: return const Color(0xFF10B981);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        // ── UPDATE ────────────────────────────────────────────────────────
        final updated = widget.note!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          updatedAt: DateTime.now(),
        );
        await _db.updateNote(updated);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Catatan berhasil diperbarui ✓'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        // ── CREATE ────────────────────────────────────────────────────────
        final newNote = Note(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
        );
        await _db.insertNote(newNote);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Catatan berhasil ditambahkan ✓'),
              backgroundColor: const Color(0xFF3B82F6),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _categoryColor(_selectedCategory);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          _isEditing ? 'Edit Catatan' : 'Catatan Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded, color: Color(0xFF3B82F6)),
                label: Text(
                  _isEditing ? 'Simpan' : 'Tambah',
                  style: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Category Selector ─────────────────────────────────────
              const Text(
                'Kategori',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  final catColor = _categoryColor(cat);
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: catColor.withOpacity(0.25),
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(
                      color: isSelected ? catColor : Colors.white54,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? catColor : Colors.white12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ─── Title Field ───────────────────────────────────────────
              const Text(
                'Judul',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan judul catatan...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  if (v.trim().length > 100) {
                    return 'Judul maksimal 100 karakter';
                  }
                  return null;
                },
                maxLength: 100,
              ),

              const SizedBox(height: 16),

              // ─── Content Field ─────────────────────────────────────────
              const Text(
                'Isi Catatan',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: 'Tulis isi catatan di sini...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  alignLabelWithHint: true,
                ),
                minLines: 8,
                maxLines: 20,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Isi catatan tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // ─── Save Button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    _isEditing
                        ? Icons.save_rounded
                        : Icons.add_circle_outline_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isEditing ? 'Simpan Perubahan' : 'Tambah Catatan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
