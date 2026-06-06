import 'package:flutter_test/flutter_test.dart';
import 'package:notaoyun/models/note_event.dart';
import 'package:notaoyun/models/song.dart';
import 'package:notaoyun/screens/play_controller.dart';
import 'package:notaoyun/services/audio_service.dart';

/// Ses çalmayı kaydeden, asset yüklemeyen sahte AudioService.
class _FakeAudio extends AudioService {
  final List<int> played = [];
  @override
  Future<void> init() async {}
  @override
  Future<void> playNote(int midi) async => played.add(midi);
}

Song _song() => const Song(
      id: 'test',
      title: 'Test',
      tempoBpm: 60, // 1 beat = 1 saniye → kolay hesap
      beatsPerMeasure: 4,
      notes: [
        NoteEvent(midi: 60, name: 'Do', startBeat: 0.0, durationBeats: 1.0),
        NoteEvent(midi: 62, name: 'Re', startBeat: 1.0, durationBeats: 1.0),
      ],
    );

void main() {
  group('PlayController', () {
    test('60 BPM ilerlemesi: 1 saniye = 1 beat', () {
      final c = PlayController(song: _song(), audio: _FakeAudio());
      c.play();
      c.onTick(const Duration(seconds: 1));
      expect(c.currentBeat, closeTo(1.0, 0.001));
    });

    test('vuruş çizgisine ulaşan nota çalınır', () {
      final audio = _FakeAudio();
      final c = PlayController(song: _song(), audio: audio);
      c.play();
      c.onTick(const Duration(milliseconds: 1)); // beat ~0 → ilk nota
      expect(audio.played, contains(60));
    });

    test('tempo çarpanı sınırlanır (0.4–1.0)', () {
      final c = PlayController(song: _song(), audio: _FakeAudio());
      c.tempoMultiplier = 2.0;
      expect(c.tempoMultiplier, 1.0);
      c.tempoMultiplier = 0.1;
      expect(c.tempoMultiplier, 0.4);
    });

    test('parça sonunda finished olur', () {
      final c = PlayController(song: _song(), audio: _FakeAudio());
      c.play();
      c.onTick(const Duration(seconds: 5));
      expect(c.finished, isTrue);
      expect(c.isPlaying, isFalse);
    });

    test('A-B loop B noktasında A’ya döner', () {
      final c = PlayController(song: _song(), audio: _FakeAudio());
      c.play();
      c.onTick(const Duration(milliseconds: 500)); // beat 0.5
      c.setLoopA(); // A=0.5
      c.onTick(const Duration(milliseconds: 1000)); // beat 1.5
      c.setLoopB(); // B=1.5
      c.onTick(const Duration(milliseconds: 200)); // B'yi geçer → A'ya döner
      expect(c.currentBeat, closeTo(0.5, 0.05));
    });
  });
}
