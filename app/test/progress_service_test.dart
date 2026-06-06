import 'package:flutter_test/flutter_test.dart';
import 'package:notaoyun/models/badge.dart';
import 'package:notaoyun/services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProgressService> _service() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProgressService(prefs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressService', () {
    test('varsayılanlar', () async {
      final s = await _service();
      expect(s.seenOnboarding, isFalse);
      expect(s.soundEnabled, isTrue);
      expect(s.streakCount, 0);
      expect(s.canConvert, isTrue);
      expect(s.remainingFreeConversions, ProgressService.freeConversionsPerMonth);
    });

    test('onboarding ve ses ayarı kalıcı', () async {
      final s = await _service();
      await s.setSeenOnboarding();
      await s.setSoundEnabled(false);
      expect(s.seenOnboarding, isTrue);
      expect(s.soundEnabled, isFalse);
    });

    test('ilk şarkı tamamlanınca streak=1 ve ilk rozet açılır', () async {
      final s = await _service();
      final newly = await s.recordSongCompleted('kucuk_yildiz');
      expect(s.streakCount, 1);
      expect(s.completedSongIds, contains('kucuk_yildiz'));
      expect(newly.map((b) => b.id), contains(Badges.firstSong.id));
    });

    test('aynı şarkı tekrar streak’i artırmaz (aynı gün)', () async {
      final s = await _service();
      await s.recordSongCompleted('a');
      await s.recordSongCompleted('b');
      expect(s.streakCount, 1); // aynı gün
      expect(s.completedSongIds.length, 2);
    });

    test('dönüştürme sayacı ve importer rozeti', () async {
      final s = await _service();
      await s.recordConversion();
      expect(s.totalConversions, 1);
      expect(s.conversionsThisMonth, 1);
      expect(s.unlockedBadgeIds, contains(Badges.importer.id));
    });

    test('aylık limit aşılınca canConvert=false', () async {
      final s = await _service();
      for (var i = 0; i < ProgressService.freeConversionsPerMonth; i++) {
        await s.recordConversion();
      }
      expect(s.canConvert, isFalse);
      expect(s.remainingFreeConversions, 0);
    });
  });
}
