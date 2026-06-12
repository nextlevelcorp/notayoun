import 'package:flutter/foundation.dart';

import '../models/note_event.dart';
import '../models/song.dart';
import '../services/audio_service.dart';

/// Aynı [startBeat]'te başlayan notalar (akor) — bekleme modunda birlikte
/// beklenir.
class NoteGroup {
  NoteGroup(this.startBeat, this.notes);
  final double startBeat;
  final List<NoteEvent> notes;
  Set<int> get midis => notes.map((n) => n.midi).toSet();
}

/// "Birlikte çal" ekranının oyun mantığı.
///
/// Bir [Ticker]'dan gelen delta'larla [currentBeat]'i ilerletir. İki mod:
///  * **Akıcı** ([waitMode] false): notalar vuruş çizgisine değdiğinde ses
///    otomatik çalınır (eski davranış).
///  * **Bekleme** ([waitMode] true): akış her notada durur; doğru nota
///    (ekran piyanosu veya mikrofon ile) [notePlayed] üzerinden gelene kadar
///    bekler — Synthesia "wait mode" mantığı.
class PlayController extends ChangeNotifier {
  PlayController({
    required this.song,
    required this.audio,
    this.waitMode = false,
    this.metronomeEnabled = false,
  }) {
    _groups = _buildGroups(song.notes);
  }

  final Song song;
  final AudioService audio;

  /// Doğru nota beklenir mi (yanlışta/eksikte akış durur).
  bool waitMode;

  /// Her vuruşta metronom tıkı.
  bool metronomeEnabled;

  /// Doğru nota çalındığında (eşleşme) tetiklenir — UI haptik/efekt bağlar.
  VoidCallback? onCorrectHit;

  /// Yanlış nota çalındığında tetiklenir.
  VoidCallback? onWrongHit;

  /// Notaların görünür olduğu ileri-bakış penceresi (vuruş cinsinden).
  static const double lookAheadBeats = 4.0;

  late final List<NoteGroup> _groups;

  double _currentBeat = 0.0;
  double get currentBeat => _currentBeat;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _finished = false;
  bool get finished => _finished;

  // --- Bekleme modu durumu ---
  bool _waiting = false;
  bool get waiting => _waiting;
  int _nextGroupIndex = 0;
  final Set<int> _pendingMidis = {};

  /// Bekleme modunda şu an basılması beklenen tuşlar (MIDI).
  Set<int> get expectedMidis => _waiting ? _pendingMidis : const {};

  int? _lastWrongMidi;
  int? get lastWrongMidi => _lastWrongMidi;

  int _lastBeatTick = -1;

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

  void setLoopA() {
    _loopA = _currentBeat;
    if (_loopB != null && _loopB! <= _loopA!) _loopB = null;
    notifyListeners();
  }

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

  // --- Şu an "yanan" (çalınan/beklenen) notalar ---
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
    _nextGroupIndex = _firstGroupIndexAt(_currentBeat);
    _waiting = false;
    _pendingMidis.clear();
    _lastWrongMidi = null;
    _lastBeatTick = -1;
    _activeMidis.clear();
    _finished = false;
    notifyListeners();
  }

  /// Ticker'dan çağrılır. [delta] geçen gerçek süredir.
  void onTick(Duration delta) {
    if (!_isPlaying) return;

    // Bekleme modunda doğru nota gelene kadar zaman donar.
    if (waitMode && _waiting) return;

    final beatsPerSecond = effectiveBpm / 60.0;
    _currentBeat += delta.inMicroseconds / 1e6 * beatsPerSecond;

    // A–B loop: B'ye gelince A'ya dön.
    if (hasLoop && _currentBeat >= _loopB!) {
      _currentBeat = _loopA!;
      _nextNoteIndex = _firstNoteIndexAt(_currentBeat);
      _nextGroupIndex = _firstGroupIndexAt(_currentBeat);
      _waiting = false;
      _pendingMidis.clear();
      _activeMidis.clear();
    }

    _emitMetronome();

    if (waitMode) {
      _maybeEnterWait();
    } else {
      _triggerDueNotes();
      _updateActiveMidis();
    }

    // Parça sonu (bekleme modunda son grup geçildikten sonra kuyruk dolunca).
    if (!hasLoop && !_waiting && _currentBeat >= song.totalBeats + 0.5) {
      _isPlaying = false;
      _finished = true;
    }
    notifyListeners();
  }

  /// Çocuğun çaldığı nota (ekran piyanosu dokunuşu veya mikrofon) buraya gelir.
  ///
  /// [playSound] dokunuşta true (uygulama sesi çalsın); mikrofonda false
  /// (gerçek piyano sesi zaten duyuluyor).
  void notePlayed(int midi, {bool playSound = true}) {
    if (playSound) audio.playNote(midi);

    if (!waitMode || !_waiting) {
      // Akıcı mod ya da bariyer dışı: sadece serbest çalma.
      notifyListeners();
      return;
    }

    // Bekleme modunda eşleştir (oktav toleranslı: pitch-class).
    final pc = midi % 12;
    int? matched;
    for (final m in _pendingMidis) {
      if (m % 12 == pc) {
        matched = m;
        break;
      }
    }

    if (matched != null) {
      _pendingMidis.remove(matched);
      _lastWrongMidi = null;
      onCorrectHit?.call();
      if (_pendingMidis.isEmpty) {
        // Bariyer geçildi → bir sonraki gruba.
        _waiting = false;
        _nextGroupIndex++;
        _activeMidis.clear();
      } else {
        _activeMidis
          ..clear()
          ..addAll(_pendingMidis);
      }
    } else {
      _lastWrongMidi = midi;
      onWrongHit?.call();
    }
    notifyListeners();
  }

  /// Yanlış-nota kırmızı flaşını temizler (UI kısa süre sonra çağırır).
  void clearWrong() {
    if (_lastWrongMidi != null) {
      _lastWrongMidi = null;
      notifyListeners();
    }
  }

  void _maybeEnterWait() {
    if (_nextGroupIndex >= _groups.length) return;
    final g = _groups[_nextGroupIndex];
    if (_currentBeat >= g.startBeat) {
      _currentBeat = g.startBeat; // tam çizgide dur
      _waiting = true;
      _pendingMidis
        ..clear()
        ..addAll(g.midis);
      _activeMidis
        ..clear()
        ..addAll(g.midis);
    }
  }

  void _emitMetronome() {
    if (!metronomeEnabled) return;
    final beatNow = _currentBeat.floor();
    if (beatNow != _lastBeatTick && _currentBeat >= 0) {
      _lastBeatTick = beatNow;
      final strong = song.beatsPerMeasure > 0 &&
          beatNow % song.beatsPerMeasure == 0;
      audio.playTick(strong: strong);
    }
  }

  /// Vuruş çizgisine ulaşan notaların sesini çalar (akıcı mod).
  void _triggerDueNotes() {
    while (_nextNoteIndex < song.notes.length &&
        song.notes[_nextNoteIndex].startBeat <= _currentBeat) {
      final note = song.notes[_nextNoteIndex];
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

  int _firstGroupIndexAt(double beat) {
    for (var i = 0; i < _groups.length; i++) {
      if (_groups[i].startBeat >= beat) return i;
    }
    return _groups.length;
  }

  static List<NoteGroup> _buildGroups(List<NoteEvent> notes) {
    final sorted = [...notes]..sort((a, b) => a.startBeat.compareTo(b.startBeat));
    final groups = <NoteGroup>[];
    for (final n in sorted) {
      if (groups.isNotEmpty &&
          (groups.last.startBeat - n.startBeat).abs() < 1e-6) {
        groups.last.notes.add(n);
      } else {
        groups.add(NoteGroup(n.startBeat, [n]));
      }
    }
    return groups;
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
