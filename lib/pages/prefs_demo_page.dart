import 'package:flutter/material.dart';
import '../services/shared_prefs_helper.dart';

/// Halaman demonstrasi teknologi local storage ALTERNATIF: SharedPreferences.
///
/// Menampilkan semua fitur SharedPreferences: read, write, dan clear data.
class PrefsDemoPage extends StatefulWidget {
  const PrefsDemoPage({super.key});

  @override
  State<PrefsDemoPage> createState() => _PrefsDemoPageState();
}

class _PrefsDemoPageState extends State<PrefsDemoPage> {
  final SharedPreferencesHelper _prefs = SharedPreferencesHelper();

  String _username = '';
  bool _isDarkMode = false;
  DateTime? _lastVisit;
  int _noteCount = 0;
  String _favoriteCategory = 'Umum';
  bool _onboardingDone = false;
  Map<String, dynamic> _allPrefs = {};

  final _usernameController = TextEditingController();

  final List<String> _categories = [
    'Umum', 'Pekerjaan', 'Pribadi', 'Ide', 'Penting'
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    final username = await _prefs.getUsername();
    final darkMode = await _prefs.getDarkMode();
    final lastVisit = await _prefs.getLastVisit();
    final noteCount = await _prefs.getNoteCount();
    final favCategory = await _prefs.getFavoriteCategory();
    final onboarding = await _prefs.isOnboardingDone();
    final allPrefs = await _prefs.getAllPrefs();

    setState(() {
      _username = username;
      _isDarkMode = darkMode;
      _lastVisit = lastVisit;
      _noteCount = noteCount;
      _favoriteCategory = favCategory;
      _onboardingDone = onboarding;
      _allPrefs = allPrefs;
      _usernameController.text = username;
    });
  }

  String _formatLastVisit(DateTime? dt) {
    if (dt == null) return 'Belum pernah';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text(
          'SharedPreferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text('Reset Data',
                      style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Yakin ingin menghapus semua data SharedPreferences?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _prefs.clearAll();
                await _loadAllData();
                messenger.showSnackBar(
                  SnackBar(
                    content: const Text('Data SharedPreferences dihapus'),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Reset semua data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Info Banner ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.storage_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'SharedPreferences',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Menyimpan data sederhana (primitif) dalam format key-value '
                    'yang persisten antar sesi. Cocok untuk preferensi pengguna, '
                    'token, dan pengaturan aplikasi.',
                    style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Username Setting ──────────────────────────────────────────
            _SectionTitle(title: 'String — Nama Pengguna'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KeyValueRow(keyStr: 'key', value: '"username"'),
                  _KeyValueRow(keyStr: 'value saat ini', value: '"$_username"'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Nama baru...',
                            hintStyle: const TextStyle(color: Colors.white24),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final val = _usernameController.text.trim();
                          if (val.isEmpty) return;
                          await _prefs.setUsername(val);
                          await _loadAllData();
                          _showSaved('Username disimpan!');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Dark Mode Setting ─────────────────────────────────────────
            _SectionTitle(title: 'Boolean — Tema Gelap'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KeyValueRow(keyStr: 'key', value: '"app_theme"'),
                  _KeyValueRow(keyStr: 'value saat ini', value: '$_isDarkMode'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Light', style: TextStyle(color: Colors.white54)),
                      Switch(
                        value: _isDarkMode,
                        activeThumbColor: const Color(0xFF8B5CF6),
                        onChanged: (v) async {
                          await _prefs.setDarkMode(v);
                          await _loadAllData();
                          _showSaved('Tema disimpan!');
                        },
                      ),
                      const Text('Dark', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Favorite Category ─────────────────────────────────────────
            _SectionTitle(title: 'String — Kategori Favorit'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KeyValueRow(keyStr: 'key', value: '"favorite_category"'),
                  _KeyValueRow(keyStr: 'value saat ini', value: '"$_favoriteCategory"'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _favoriteCategory,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) async {
                      if (v != null) {
                        await _prefs.setFavoriteCategory(v);
                        await _loadAllData();
                        _showSaved('Kategori favorit disimpan!');
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Read-only Stats ───────────────────────────────────────────
            _SectionTitle(title: 'Integer & DateTime — Statistik'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _StatTile(
                    icon: Icons.note_add_rounded,
                    color: const Color(0xFF3B82F6),
                    label: 'Total Catatan Dibuat',
                    keyStr: 'total_notes_created (int)',
                    value: _noteCount.toString(),
                  ),
                  const Divider(color: Colors.white12),
                  _StatTile(
                    icon: Icons.access_time_rounded,
                    color: const Color(0xFFF59E0B),
                    label: 'Kunjungan Terakhir',
                    keyStr: 'last_visit (string/datetime)',
                    value: _formatLastVisit(_lastVisit),
                  ),
                  const Divider(color: Colors.white12),
                  _StatTile(
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF10B981),
                    label: 'Onboarding Selesai',
                    keyStr: 'onboarding_done (bool)',
                    value: _onboardingDone ? 'Ya' : 'Tidak',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── All Stored Data ───────────────────────────────────────────
            _SectionTitle(title: 'Semua Data Tersimpan'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_allPrefs.isEmpty)
                    const Text(
                      'Belum ada data tersimpan',
                      style: TextStyle(color: Colors.white38),
                    )
                  else
                    ..._allPrefs.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.circle,
                                  color: Color(0xFF059669), size: 8),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '"${e.key}"',
                                        style: const TextStyle(
                                          color: Color(0xFF93C5FD),
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' : ',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '"${e.value}"',
                                        style: const TextStyle(
                                          color: Color(0xFFFBBF24),
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _loadAllData,
                    child: Row(
                      children: const [
                        Icon(Icons.refresh_rounded,
                            color: Color(0xFF059669), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Refresh',
                          style: TextStyle(
                              color: Color(0xFF059669), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSaved(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String keyStr;
  final String value;
  const _KeyValueRow({required this.keyStr, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$keyStr: ',
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          Text(value,
              style: const TextStyle(
                color: Color(0xFF93C5FD),
                fontSize: 11,
                fontFamily: 'monospace',
              )),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String keyStr;
  final String value;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.keyStr,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text(keyStr,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
