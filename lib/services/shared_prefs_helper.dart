import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferencesHelper mengelola penyimpanan data sederhana berbasis
/// key-value menggunakan package shared_preferences.
///
/// Digunakan sebagai teknologi local storage ALTERNATIF selain SQLite.
/// Cocok untuk menyimpan preferensi pengguna, token, pengaturan, dsb.
class SharedPreferencesHelper {
  // ─── Keys ─────────────────────────────────────────────────────────────────
  static const String _keyTheme = 'app_theme';
  static const String _keyUsername = 'username';
  static const String _keyLastVisit = 'last_visit';
  static const String _keyNoteCount = 'total_notes_created';
  static const String _keyFavoriteCategory = 'favorite_category';
  static const String _keyOnboardingDone = 'onboarding_done';

  // ─── Theme ────────────────────────────────────────────────────────────────

  /// Menyimpan preferensi tema (dark / light).
  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTheme, isDark);
  }

  /// Membaca preferensi tema. Default: false (light mode).
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTheme) ?? false;
  }

  // ─── Username ─────────────────────────────────────────────────────────────

  /// Menyimpan nama pengguna.
  Future<void> setUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, name);
  }

  /// Membaca nama pengguna. Default: 'Pengguna'.
  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername) ?? 'Pengguna';
  }

  // ─── Last Visit ───────────────────────────────────────────────────────────

  /// Menyimpan timestamp kunjungan terakhir.
  Future<void> updateLastVisit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastVisit, DateTime.now().toIso8601String());
  }

  /// Membaca timestamp kunjungan terakhir.
  Future<DateTime?> getLastVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastVisit);
    return raw != null ? DateTime.parse(raw) : null;
  }

  // ─── Note Counter ─────────────────────────────────────────────────────────

  /// Menambah hitungan total catatan yang pernah dibuat.
  Future<void> incrementNoteCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyNoteCount) ?? 0;
    await prefs.setInt(_keyNoteCount, current + 1);
  }

  /// Membaca total catatan yang pernah dibuat.
  Future<int> getNoteCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyNoteCount) ?? 0;
  }

  // ─── Favorite Category ────────────────────────────────────────────────────

  /// Menyimpan kategori favorit pengguna.
  Future<void> setFavoriteCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFavoriteCategory, category);
  }

  /// Membaca kategori favorit.
  Future<String> getFavoriteCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFavoriteCategory) ?? 'Umum';
  }

  // ─── Onboarding ───────────────────────────────────────────────────────────

  /// Menandai bahwa onboarding sudah selesai.
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }

  /// Mengecek apakah onboarding sudah selesai.
  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  // ─── Utility ──────────────────────────────────────────────────────────────

  /// Menghapus semua data SharedPreferences (reset).
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Mengambil semua key-value yang tersimpan (untuk demo/debug).
  Future<Map<String, dynamic>> getAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> result = {};
    for (final key in keys) {
      result[key] = prefs.get(key);
    }
    return result;
  }
}
