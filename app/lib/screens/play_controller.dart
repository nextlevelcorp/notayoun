import 'package:flutter/foundation.dart';

import '../models/note_event.dart';
import '../models/song.dart';
import '../services/audio_service.dart';

/// "Birlikte çal" ekranının oyun mantığı.
///
/// Bir [Ticker]'dan gelen delta'larla [currentBeat]'i ilerletir; notalar alttaki
/// "vuruş çizgisine" değdiğinde sesi tetikler. Tempo yavaşlatma ve A–B loop
/// burada yönetilir.
class PlayController extends ChangeNotifier {
  PlayController({required this.song, required this.audio});

  final Song song;
  final AudioService audio;

  /// Notaların görünür olduğu ileri-bakış penceresi (vuruş cinsinden).
  static const double lookAheadBeats = 4.0;

  double _currentBeat = 0.0;
  double get currentBeat => _currentBeat;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _finished = false;
  bool get finished => _finished;

  /// 0.5x – 1.0x arası tempo çarpanı.
  double _tempoMultiplier = 1.0;
  double get tempoMultiplier => _tempoMultiplier;
  set tempoMultiplier(double v) {
    _tempoMultiplier = v.clamp(0.4, 1.0);
    notifyListeners();
  }

  double get effectiveBpm => song.tempoBpm * _tempoMultiplier;

  // --- A–B loop ---
  double? _loopA;
  double? _loopB;
  double? get loopA => _loopA;
  double? get loopB => _loopB;
  bool get hasLoop => _loopA != null && _loopB != null;

  /// Şu anki konumu A noktası olarak işaretler.
  void setLoopA() {
    _loopA = _currentBeat;
    if (_loopB != null && _loopB! <= _loopA!) _loopB = null;
    notifyListeners();
  }

  /// Şu anki konumu B noktası olarak işaretler.
  void setLoopB() {
    if (_currentBeat > (_loopA ?? 0)) {
      _loopB = _currentBeat;
      notifyListeners();
    }
  }

  void clearLoop() {
    _loopA = null;
    _loopB = null;
    notifyListeners();
  }

  // --- Şu an "yanan" (çalınan) notalar ---
  final Set<int> _activeMidis = {};
  Set<int> get activeMidis => _activeMidis;

  int _nextNoteIndex = 0;

  void play() {
    if (_finished) restart();
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  void togglePlay() => _isPlaying ? pause() : play();

  void restart() {
    _currentBeat = hasLoop ? _loopA! : 0.0;
    _nextNoteIndex = _firstNoteIndexAt(_currentBeat);
    _activeMidis.clear();
    _finished = false;
    notifyListeners();
  }

  /// Ticker'dan çağrılır. [delta] geçen gerçek süredir.
  void onTick(Duration delta) {
    if (!_isPlaying) return;

    final beatsPerSecond = effectiveBpm / 60.0;
    _currentBeat += delta.inMicroseconds / 1e6 * beatsPerSecond;

    // A–B loop: B'ye gelince A'ya dön.
    if (hasLoop && _currentBeat >= _loopB!) {
      _currentBeat = _loopA!;
      _nextNoteIndex = _firstNoteIndexAt(_currentBeat);
      _activeMidis.clear();
    }

    _triggerDueNotes();
    _updateActiveMidis();

    // Parça sonu.
    if (!hasLoop && _currentBeat >= song.totalBeats + 0.5) {
      _isPlaying = false;
      _finished = true;
    }
    notifyListeners();
  }

  /// Vuruş çizgisine ulaşan notaların sesini çalar.
  void _triggerDueNotes() {
    while (_nextNoteIndex < song.notes.length &&
        song.notes[_nextNoteIndex].startBeat <= _currentBeat) {
      final note = song.notes[_nextNoteIndex];
      // Loop dışına taşmış notaları çalma.
      if (!hasLoop || note.startBeat < _loopB!) {
        audio.playNote(note.midi);
      }
      _nextNoteIndex++;
    }
  }

  void _updateActiveMidis() {
    _activeMidis.clear();
    for (final n in song.notes) {
      if (n.startBeat <= _currentBeat && _currentBeat < n.endBeat) {
        _activeMidis.add(n.midi);
      }
    }
  }

  int _firstNoteIndexAt(double beat) {
    for (var i = 0; i < song.notes.length; i++) {
      if (song.notes[i].startBeat >= beat) return i;
    }
    return song.notes.length;
  }

  /// Görünür penceredeki notalar (painter için).
  List<NoteEvent> get visibleNotes => song.notes
      .where((n) =>
          n.startBeat >= _currentBeat - 0.5 &&
          n.startBeat <= _currentBeat + lookAheadBeats)
      .toList();

  /// 0.0–1.0 arası ilerleme.
  double get progress {
    final total = song.totalBeats;
    if (total <= 0) return 0;
    return (_currentBeat / total).clamp(0.0, 1.0);
  }
}
