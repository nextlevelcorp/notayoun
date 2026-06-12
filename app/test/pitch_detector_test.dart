import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:notaoyun/services/pitch/pitch_detector.dart';

List<double> _sine(double hz, {int sampleRate = 44100, int n = 2048}) {
  return List<double>.generate(
    n,
    (i) => 0.6 * math.sin(2 * math.pi * hz * i / sampleRate),
  );
}

void main() {
  group('PitchDetector', () {
    test('440 Hz → MIDI 69 (A4)', () {
      final d = PitchDetector();
      expect(d.detectMidi(_sine(440)), 69);
    });

    test('261.63 Hz → MIDI 60 (orta Do)', () {
      final d = PitchDetector();
      expect(d.detectMidi(_sine(261.63)), 60);
    });

    test('220 Hz → MIDI 57 (A3)', () {
      final d = PitchDetector();
      expect(d.detectMidi(_sine(220)), 57);
    });

    test('sessizlik → null', () {
      final d = PitchDetector();
      expect(d.detectMidi(List<double>.filled(2048, 0)), isNull);
    });

    test('hzToMidi referans noktaları', () {
      expect(PitchDetector.hzToMidi(440), 69);
      expect(PitchDetector.hzToMidi(880), 81);
    });
  });

  group('NoteStabilizer', () {
    test('aynı nota requiredHits kez gelince onaylanır', () {
      final s = NoteStabilizer(requiredHits: 2);
      expect(s.push(60), isNull); // 1. kez
      expect(s.push(60), 60); // 2. kez → onay
    });

    test('farklı nota adayı sıfırlar', () {
      final s = NoteStabilizer(requiredHits: 2);
      expect(s.push(60), isNull);
      expect(s.push(62), isNull); // aday değişti
      expect(s.push(62), 62);
    });

    test('aynı nota minGap içinde tekrar yayınlanmaz', () {
      final s = NoteStabilizer(
        requiredHits: 1,
        minGap: const Duration(milliseconds: 200),
      );
      final t0 = DateTime(2026, 1, 1, 0, 0, 0);
      expect(s.push(60, now: t0), 60);
      expect(s.push(60, now: t0.add(const Duration(milliseconds: 50))), isNull);
      expect(s.push(60, now: t0.add(const Duration(milliseconds: 300))), 60);
    });

    test('sessizlik sonrası aynı nota yeniden çalınabilir', () {
      final s = NoteStabilizer(requiredHits: 1);
      expect(s.push(60), 60);
      expect(s.push(null), isNull); // sessizlik → reset
      expect(s.push(60), 60);
    });
  });
}
