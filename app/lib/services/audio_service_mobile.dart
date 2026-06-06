import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle;
import 'package:soundpool/soundpool.dart';

/// Mobil ses backend'i (soundpool).
class AudioBackend {
  Soundpool? _pool;
  final Map<int, int> _soundIds = {};

  Future<void> init(int low, int high, AssetBundle bundle) async {
    _pool = Soundpool.fromOptions(
      options: const SoundpoolOptions(streamType: StreamType.music),
    );
    for (var midi = low; midi <= high; midi++) {
      try {
        final data = await bundle.load('assets/audio/note_$midi.wav');
        _soundIds[midi] = await _pool!.load(data);
      } catch (e) {
        debugPrint('Ses örneği yüklenemedi: note_$midi.wav ($e)');
      }
    }
  }

  Future<void> playNote(int midi) async {
    final id = _soundIds[midi];
    if (id != null) await _pool?.play(id);
  }

  void dispose() {
    _pool?.dispose();
    _pool = null;
    _soundIds.clear();
  }
}
