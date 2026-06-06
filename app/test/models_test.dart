import 'package:flutter_test/flutter_test.dart';
import 'package:notaoyun/models/note_event.dart';
import 'package:notaoyun/models/song.dart';

void main() {
  group('NoteEvent', () {
    test('fromJson/toJson round-trip', () {
      const json = {
        'midi': 60,
        'name': 'Do',
        'startBeat': 0.0,
        'durationBeats': 1.0,
        'hand': 'right',
      };
      final note = NoteEvent.fromJson(json);
      expect(note.midi, 60);
      expect(note.name, 'Do');
      expect(note.hand, Hand.right);
      expect(note.endBeat, 1.0);
      expect(note.toJson(), json);
    });

    test('defaults hand to right when missing', () {
      final note = NoteEvent.fromJson({
        'midi': 64,
        'name': 'Mi',
        'startBeat': 2.0,
        'durationBeats': 0.5,
      });
      expect(note.hand, Hand.right);
    });
  });

  group('Song', () {
    const source = '''
    {
      "title": "Test Şarkı",
      "tempoBpm": 90,
      "beatsPerMeasure": 4,
      "notes": [
        {"midi": 60, "name": "Do", "startBeat": 0.0, "durationBeats": 1.0, "hand": "right"},
        {"midi": 62, "name": "Re", "startBeat": 1.0, "durationBeats": 2.0, "hand": "right"}
      ]
    }
    ''';

    test('parses and derives id from title when absent', () {
      final song = Song.fromJsonString(source);
      expect(song.title, 'Test Şarkı');
      expect(song.tempoBpm, 90);
      expect(song.notes.length, 2);
      expect(song.id, isNotEmpty);
    });

    test('totalBeats is max endBeat', () {
      final song = Song.fromJsonString(source);
      expect(song.totalBeats, 3.0); // 1.0 + 2.0
    });

    test('toJson/fromJson round-trip preserves notes', () {
      final song = Song.fromJsonString(source);
      final round = Song.fromJson(song.toJson());
      expect(round.title, song.title);
      expect(round.notes.length, song.notes.length);
      expect(round.notes.last.midi, 62);
    });
  });
}
