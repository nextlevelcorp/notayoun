import 'package:flutter/services.dart' show AssetBundle;

/// Web ses backend'i — şimdilik sessiz.
/// TODO(Faz 4): Web Audio API ile gerçek ses.
class AudioBackend {
  Future<void> init(int low, int high, AssetBundle bundle) async {}
  Future<void> playNote(int midi) async {}
  void dispose() {}
}
