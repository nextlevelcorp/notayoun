import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:soundpool/soundpool.dart';

/// Örnek (sample) tabanlı düşük gecikmeli nota çalar.
///
/// `assets/audio/note_<midi>.wav` örneklerini `soundpool` ile önceden yükler;
/// oyun sırasında MIDI numarasına göre tetikler.
class AudioService {
  AudioService();

  static const int _lowMidi = 48; // C3 (üretilen ilk örnek)
  static const int _highMidi = 79; // G5 (üretilen son örnek)

  Soundpool? _pool;
  final Map<int, int> _soundIds = {}; // midi -> soundpool id
  bool _ready = false;
  bool get isReady => _ready;

  /// Tüm nota örneklerini belleğe yükler. Uygulama açılışında bir kez çağrılır.
  Future<void> init() async {
    if (_ready) return;
    _pool = Soundpool.fromOptions(
      options: const SoundpoolOptions(streamType: StreamType.music),
    );
    for (var midi = _lowMidi; midi <= _highMidi; midi++) {
      try {
        final data = await rootBundle.load('assets/audio/note_$midi.wav');
        _soundIds[midi] = await _pool!.load(data);
      } catch (e) {
        // Örnek yoksa sessizce atla (görsel oynanış etkilenmez).
        debugPrint('Ses örneği yüklenemedi: note_$midi.wav ($e)');
      }
    }
    _ready = true;
  }

  /// Verilen MIDI notasını çalar. Aralık dışındaysa en yakın oktava kaydırır.
  Future<void> playNote(int midi) async {
    final pool = _pool;
    if (pool == null) return;

    var m = midi;
    while (m < _lowMidi) {
      m += 12;
    }
    while (m > _highMidi) {
      m -= 12;
    }
    final id = _soundIds[m];
    if (id != null) {
      await pool.play(id);
    }
  }

  void dispose() {
    _pool?.dispose();
    _pool = null;
    _ready = false;
    _soundIds.clear();
  }
}
