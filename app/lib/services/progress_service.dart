import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/badge.dart';

/// Oyunlaştırma + ayarlar + freemium durumunu cihazda saklayan servis.
///
/// Çocuk güvenliği: hiçbir veri dışarı gönderilmez; her şey [SharedPreferences]
/// ile yalnızca cihazda tutulur.
class ProgressService extends ChangeNotifier {
  ProgressService(this._prefs);

  final SharedPreferences _prefs;

  /// Aylık ücretsiz dönüştürme limiti (freemium taslağı).
  static const int freeConversionsPerMonth = 5;

  // --- Anahtarlar ---
  static const _kSeenOnboarding = 'seen_onboarding';
  static const _kSoundEnabled = 'sound_enabled';
  static const _kStreak = 'streak_count';
  static const _kLastPlayDay = 'last_play_day';
  static const _kCompleted = 'completed_song_ids';
  static const _kBadges = 'unlocked_badges';
  static const _kConvMonth = 'conv_month';
  static const _kConvCount = 'conv_count';
  static const _kTotalConv = 'total_conversions';

  bool get seenOnboarding => _prefs.getBool(_kSeenOnboarding) ?? false;
  bool get soundEnabled => _prefs.getBool(_kSoundEnabled) ?? true;
  int get streakCount => _prefs.getInt(_kStreak) ?? 0;
  Set<String> get completedSongIds =>
      (_prefs.getStringList(_kCompleted) ?? const []).toSet();
  Set<String> get unlockedBadgeIds =>
      (_prefs.getStringList(_kBadges) ?? const []).toSet();
  int get totalConversions => _prefs.getInt(_kTotalConv) ?? 0;

  int get conversionsThisMonth {
    if (_prefs.getString(_kConvMonth) != _monthKey()) return 0;
    return _prefs.getInt(_kConvCount) ?? 0;
  }

  int get remainingFreeConversions =>
      (freeConversionsPerMonth - conversionsThisMonth).clamp(0, 9999);

  bool get canConvert => conversionsThisMonth < freeConversionsPerMonth;

  Future<void> setSeenOnboarding() async {
    await _prefs.setBool(_kSeenOnboarding, true);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool(_kSoundEnabled, value);
    notifyListeners();
  }

  /// Bir dönüştürme yapıldığında çağrılır (aylık sayaç + toplam).
  Future<void> recordConversion() async {
    if (_prefs.getString(_kConvMonth) != _monthKey()) {
      await _prefs.setString(_kConvMonth, _monthKey());
      await _prefs.setInt(_kConvCount, 0);
    }
    await _prefs.setInt(_kConvCount, conversionsThisMonth + 1);
    await _prefs.setInt(_kTotalConv, totalConversions + 1);
    await _checkBadges();
    notifyListeners();
  }

  /// Bir parça tamamlandığında çağrılır. Streak'i günceller, yeni açılan
  /// rozetleri döndürür.
  Future<List<BadgeDef>> recordSongCompleted(String songId) async {
    // Tamamlanan şarkılar
    final completed = completedSongIds..add(songId);
    await _prefs.setStringList(_kCompleted, completed.toList());

    // Streak
    final today = _dayKey(DateTime.now());
    final last = _prefs.getString(_kLastPlayDay);
    if (last != today) {
      final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
      final newStreak = last == yesterday ? streakCount + 1 : 1;
      await _prefs.setInt(_kStreak, newStreak);
      await _prefs.setString(_kLastPlayDay, today);
    }

    final newly = await _checkBadges();
    notifyListeners();
    return newly;
  }

  /// Kuralları değerlendirir, yeni açılan rozetleri kaydeder ve döndürür.
  Future<List<BadgeDef>> _checkBadges() async {
    final unlocked = unlockedBadgeIds;
    final newly = <BadgeDef>[];

    void unlock(BadgeDef b, bool condition) {
      if (condition && !unlocked.contains(b.id)) {
        unlocked.add(b.id);
        newly.add(b);
      }
    }

    final completedCount = completedSongIds.length;
    unlock(Badges.firstSong, completedCount >= 1);
    unlock(Badges.fiveSongs, completedCount >= 5);
    unlock(Badges.streak3, streakCount >= 3);
    unlock(Badges.streak7, streakCount >= 7);
    unlock(Badges.importer, totalConversions >= 1);

    if (newly.isNotEmpty) {
      await _prefs.setStringList(_kBadges, unlocked.toList());
    }
    return newly;
  }

  String _monthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
