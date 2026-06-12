import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Örnek (sample) tabanlı düşük gecikmeli nota çalar.
///
/// `assets/audio/note_<midi>.wav` örneklerini bir [AudioPlayer] havuzuyla
/// çalar; eş zamanlı nota sesi için havuzdan döngüsel olarak player alır.
/// Android / iOS / Web üçünde de çalışır (audioplayers).
class AudioService {
  AudioService();

  static const int _lowMidi = 48; // C3
  static const int _highMidi = 79; // G5
  static const int _poolSize = 8; // eş zamanlı maksimum ses

  final List<AudioPlayer> _pool = [];
  int _poolIndex = 0;
  bool _ready = false;
  bool get isReady => _ready;

  /// Metronom/sayım tıkı için ayrı oynatıcı (nota havuzunu meşgul etmez).
  final AudioPlayer _tickPlayer = AudioPlayer();

  /// Ses açık mı (ayarlardan kontrol edilir).
  bool enabled = true;

  Future<void> init() async {
    if (_ready) return;
    for (var i = 0; i < _poolSize; i++) {
      final p = AudioPlayer();
      await p.setReleaseMode(ReleaseMode.stop);
      _pool.add(p);
    }
    await _tickPlayer.setReleaseMode(ReleaseMode.stop);
    _ready = true;
  }

  /// Metronom/sayım tıkı. [strong] true ise vurgulu (ölçü başı) tık çalar.
  Future<void> playTick({bool strong = false}) async {
    if (!enabled || !_ready) return;
    try {
      await _tickPlayer.play(
        AssetSource(strong ? 'audio/tick_hi.wav' : 'audio/tick_lo.wav'),
      );
    } catch (e) {
      debugPrint('Tık çalınamadı ($e)');
    }
  }

  /// Verilen MIDI notasını çalar. Aralık dışındaysa en yakın oktava kaydırır.
  Future<void> playNote(int midi) async {
    if (!enabled || !_ready) return;
    var m = midi;
    while (m < _lowMidi) {
      m += 12;
    }
    while (m > _highMidi) {
      m -= 12;
    }
    try {
      final player = _pool[_poolIndex % _poolSize];
      _poolIndex++;
      await player.play(AssetSource('audio/note_$m.wav'));
    } catch (e) {
      debugPrint('Ses çalınamadı: note_$m.wav ($e)');
    }
  }

  void dispose() {
    for (final p in _pool) {
      p.dispose();
    }
    _pool.clear();
    _tickPlayer.dispose();
    _ready = false;
  }
}
