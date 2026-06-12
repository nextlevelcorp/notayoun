/// Mikrofonu dinleyip çalınan notayı (MIDI) yayınlayan servis arayüzü.
///
/// Web'de mikrofonla nota algılama güvenilir olmadığından no-op uygulama
/// kullanılır ([isSupported] == false) ve oyun ekran piyanosuna düşer.
/// Mobilde gerçek mikrofon + saf-Dart pitch detection devreye girer.
abstract class PitchService {
  /// Bu platform mikrofonla nota algılamayı destekliyor mu?
  bool get isSupported;

  /// Dinlemeye başlar. İzin verilmediyse/desteklenmiyorsa `false` döner.
  Future<bool> start(void Function(int midi) onNote);

  /// Dinlemeyi durdurur (kaynakları serbest bırakır).
  Future<void> stop();

  void dispose();
}
