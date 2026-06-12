import 'package:flutter_test/flutter_test.dart';
import 'package:notaoyun/models/note_event.dart';
import 'package:notaoyun/models/song.dart';
import 'package:notaoyun/screens/play_controller.dart';
import 'package:notaoyun/services/audio_service.dart';

class _FakeAudio extends AudioService {
  final List<int> played = [];
  @override
  Future<void> init() async {}
  @override
  Future<void> playNote(int midi) async => played.add(midi);
  @override
  Future<void> playTick({bool strong = false}) async {}
}

Song _song() => const Song(
      id: 'test',
      title: 'Test',
      tempoBpm: 60,
      beatsPerMeasure: 4,
      notes: [
        NoteEvent(midi: 60, name: 'Do', startBeat: 0.0, durationBeats: 1.0),
        NoteEvent(midi: 62, name: 'Re', startBeat: 1.0, durationBeats: 1.0),
      ],
    );

void main() {
  group('PlayController bekleme modu', () {
    test('ilk notada durur ve doğru tuş beklenir', () {
      final c = PlayController(song: _song(), audio: _FakeAudio(), waitMode: true);
      c.play();
      c.onTick(const Duration(milliseconds: 100));
      expect(c.waiting, isTrue);
      expect(c.expectedMidis, {60});
      expect(c.currentBeat, closeTo(0.0, 1e-6));
    });

    test('beklerken zaman ilerlemez', () {
      final c = PlayController(song: _song(), audio: _FakeAudio(), waitMode: true);
      c.play();
      c.onTick(const Duration(milliseconds: 100));
      c.onTick(const Duration(seconds: 2));
      expect(c.currentBeat, closeTo(0.0, 1e-6));
      expect(c.waiting, isTrue);
    });

    test('yanlış nota ilerletmez, lastWrongMidi işaretlenir', () {
      final c = PlayController(song: _song(), audio: _FakeAudio(), waitMode: true);
      c.play();
      c.onTick(const Duration(milliseconds: 100));
      c.notePlayed(61);
      expect(c.waiting, isTrue);
      expect(c.lastWrongMidi, 61);
    });

    test('doğru nota bariyeri açar; oktav farkı kabul edilir', () {
      final c = PlayController(song: _song(), audio: _FakeAudio(), waitMode: true);
      c.play();
      c.onTick(const Duration(milliseconds: 100));
      c.notePlayed(60); // doğru
      expect(c.waiting, isFalse);

      // Bir sonraki notaya ilerle (beat 1).
      c.onTick(const Duration(milliseconds: 1100));
      expect(c.waiting, isTrue);
      expect(c.expectedMidis, {62});

      // 62 yerine 74 (bir oktav üstü) → pitch-class eşleşir.
      c.notePlayed(74);
      expect(c.waiting, isFalse);
    });

    test('callback: doğru ve yanlış tetiklenir', () {
      var correct = 0;
      var wrong = 0;
      final c =
          PlayController(song: _song(), audio: _FakeAudio(), waitMode: true);
      c.onCorrectHit = () => correct++;
      c.onWrongHit = () => wrong++;
      c.play();
      c.onTick(const Duration(milliseconds: 100));
      c.notePlayed(99); // yanlış
      c.notePlayed(60); // doğru
      expect(wrong, 1);
      expect(correct, 1);
    });
  });
}
