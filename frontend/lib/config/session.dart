import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ──────────────────────────────────────────────────────────
// SESSION MANAGER
// Stores login data locally. Session expires after 1 hour.
// ──────────────────────────────────────────────────────────
class SessionManager {
  static const _keyUser      = 'session_user';
  static const _keyTimestamp = 'session_ts';
  static const _sessionHours = 1; // hours before session expires

  // ── Save session after login ────────────────────────────
  static Future<void> save(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(userData));
    await prefs.setInt(_keyTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  // ── Load session if still valid ─────────────────────────
  // Returns null if no session or session has expired
  static Future<Map<String, dynamic>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyUser);
      final ts       = prefs.getInt(_keyTimestamp);

      if (userJson == null || ts == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - ts;
      final maxAgeMs = _sessionHours * 60 * 60 * 1000;

      if (age > maxAgeMs) {
        // Session expired — clear it
        await clear();
        return null;
      }

      return Map<String, dynamic>.from(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  // ── Clear session on logout ─────────────────────────────
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.remove(_keyTimestamp);
  }

  // ── Refresh timestamp (extend session on activity) ──────
  static Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_keyUser)) {
      await prefs.setInt(_keyTimestamp, DateTime.now().millisecondsSinceEpoch);
    }
  }
}
