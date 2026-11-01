import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/note.dart';
import '../services/shared_prefs_helper.dart';
import 'note_form_page.dart';
import 'note_detail_page.dart';
import 'prefs_demo_page.dart';

/// Halaman utama yang menampilkan daftar catatan dari SQLite.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SharedPreferencesHelper _prefs = SharedPreferencesHelper();

  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _username = 'Pengguna';
  // ignore: unused_field
  int _totalCreated = 0;

  final List<String> _categories = [
    'Semua', 'Umum', 'Pekerjaan', 'Pribadi', 'Ide', 'Penting'
  ];

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _prefs.updateLastVisit();
    final notes = await _db.getAllNotes();
    final username = await _prefs.getUsername();
    final totalCreated = await _prefs.getNoteCount();

    setState(() {
      _notes = notes;
      _filteredNotes = notes;
      _username = username;
      _totalCreated = totalCreated;
      _isLoading = false;
    });
    _fabController.forward();
    _applyFilter();
  }

  void _applyFilter() {
    List<Note> result = List.from(_notes);

    if (_selectedCategory != 'Semua') {
      result = result.where((n) => n.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.content.toLowerCase().contains(q))
          .toList();
    }

    setState(() => _filteredNotes = result);
  }

  Future<void> _deleteNote(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Catatan'),
        content: Text('Yakin ingin menghapus "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteNote(note.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Catatan "${note.title}" dihapus'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      await _loadData();
    }
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

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Pekerjaan': return Icons.work_rounded;
      case 'Pribadi': return Icons.person_rounded;
      case 'Ide': return Icons.lightbulb_rounded;
      case 'Penting': return Icons.star_rounded;
      default: return Icons.note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // theme accessed via Theme.of(context) in child widgets
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, $_username 👋',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Catatan Saya',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _StatChip(
                                  label: '${_notes.length}',
                                  subtitle: 'Catatan',
                                  icon: Icons.notes_rounded,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PrefsDemoPage(),
                                      ),
                                    );
                                    _loadData();
                                  },
                                  icon: const Icon(Icons.settings_rounded,
                                      color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search bar
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Cari catatan...',
                              hintStyle: TextStyle(color: Colors.white38),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: Colors.white38, size: 20),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (v) {
                              _searchQuery = v;
                              _applyFilter();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Category Filter ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        _applyFilter();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : Colors.white12,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ─── Note List ─────────────────────────────────────────────────────
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                  ),
                )
              : _filteredNotes.isEmpty
                  ? SliverFillRemaining(
                      child: _EmptyState(
                        hasSearch: _searchQuery.isNotEmpty ||
                            _selectedCategory != 'Semua',
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final note = _filteredNotes[i];
                            return _NoteCard(
                              note: note,
                              color: _categoryColor(note.category),
                              icon: _categoryIcon(note.category),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NoteDetailPage(note: note),
                                  ),
                                );
                                _loadData();
                              },
                              onDelete: () => _deleteNote(note),
                              onEdit: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NoteFormPage(note: note),
                                  ),
                                );
                                _loadData();
                              },
                            );
                          },
                          childCount: _filteredNotes.length,
                        ),
                      ),
                    ),
        ],
      ),

      // ─── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoteFormPage()),
            );
            await _prefs.incrementNoteCount();
            _loadData();
          },
          backgroundColor: const Color(0xFF3B82F6),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Tambah Catatan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets Pendukung ─────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text(subtitle,
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _NoteCard({
    required this.note,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color strip top
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: color, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          color: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: const [
                                  Icon(Icons.edit_rounded,
                                      color: Color(0xFF3B82F6), size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: const [
                                  Icon(Icons.delete_rounded,
                                      color: Colors.red, size: 18),
                                  SizedBox(width: 8),
                                  Text('Hapus',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (v) {
                            if (v == 'edit') onEdit();
                            if (v == 'delete') onDelete();
                          },
                          icon: const Icon(Icons.more_vert_rounded,
                              color: Colors.white38, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.content,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            note.category,
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.access_time_rounded,
                            color: Colors.white30, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                              color: Colors.white30, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({this.hasSearch = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off_rounded : Icons.note_add_rounded,
            color: Colors.white24,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'Tidak ada catatan ditemukan' : 'Belum ada catatan',
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Coba kata kunci lain'
                : 'Tekan tombol + untuk menambah catatan baru',
            style: const TextStyle(color: Colors.white24, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
