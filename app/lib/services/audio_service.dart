import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

// soundpool web'i desteklemez; platforma göre koşullu import.
import 'audio_service_mobile.dart'
    if (dart.library.html) 'audio_service_web.dart' as _impl;

/// Örnek (sample) tabanlı düşük gecikmeli nota çalar.
///
/// Mobil: `soundpool` ile WAV örnekleri.
/// Web: sessiz (görsel oynanış tam, ses devre dışı — ileride Web Audio API).
class AudioService {
  AudioService();

  static const int _lowMidi = 48;
  static const int _highMidi = 79;

  final _impl.AudioBackend _backend = _impl.AudioBackend();
  bool _ready = false;
  bool get isReady => _ready;

  /// Ses açık mı (ayarlardan kontrol edilir).
  bool enabled = true;

  Future<void> init() async {
    if (_ready) return;
    if (!kIsWeb) {
      await _backend.init(_lowMidi, _highMidi, rootBundle);
    }
    _ready = true;
  }

  Future<void> playNote(int midi) async {
    if (!enabled) return;
    if (kIsWeb) return; // Web Audio API Faz 4'te eklenecek.
    var m = midi;
    while (m < _lowMidi) {
      m += 12;
    }
    while (m > _highMidi) {
      m -= 12;
    }
    await _backend.playNote(m);
  }

  void dispose() {
    _backend.dispose();
    _ready = false;
  }
}
