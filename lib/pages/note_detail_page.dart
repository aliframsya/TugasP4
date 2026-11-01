import 'package:flutter/material.dart';
import '../models/note.dart';
import 'note_form_page.dart';

/// Halaman detail catatan (READ operasi SQLite).
class NoteDetailPage extends StatelessWidget {
  final Note note;
  const NoteDetailPage({super.key, required this.note});

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

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(note.category);
    final icon = _categoryIcon(note.category);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () {
                  final nav = Navigator.of(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteFormPage(note: note),
                    ),
                  ).then((_) => nav.pop());
                },
                icon: const Icon(Icons.edit_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      const Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: color.withOpacity(0.4)),
                              ),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                note.category,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          note.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Timestamps ────────────────────────────────────────
                  Row(
                    children: [
                      _InfoBadge(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Dibuat',
                        value: _formatDate(note.createdAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoBadge(
                        icon: Icons.update_rounded,
                        label: 'Diperbarui',
                        value: _formatDate(note.updatedAt),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  _InfoBadge(
                    icon: Icons.tag_rounded,
                    label: 'ID',
                    value: '#${note.id}',
                  ),

                  const SizedBox(height: 24),

                  // ─── Divider ───────────────────────────────────────────
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Content ───────────────────────────────────────────
                  Text(
                    note.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
