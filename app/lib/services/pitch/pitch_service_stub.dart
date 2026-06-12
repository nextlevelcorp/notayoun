import 'pitch_service_base.dart';

/// Web (ve mikrofon erişimi olmayan platformlar) için no-op uygulama.
/// Oyun bu durumda yalnızca ekran piyanosu girişine güvenir.
class NoopPitchService implements PitchService {
  @override
  bool get isSupported => false;

  @override
  Future<bool> start(void Function(int midi) onNote) async => false;

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}
}

PitchService createPitchService() => NoopPitchService();
