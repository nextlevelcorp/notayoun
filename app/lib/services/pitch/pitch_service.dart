import 'pitch_service_base.dart';
import 'pitch_service_stub.dart'
    if (dart.library.io) 'pitch_service_io.dart' as impl;

export 'pitch_service_base.dart';

/// Platforma uygun [PitchService] örneğini üretir
/// (web → no-op, mobil → mikrofon).
PitchService createPitchService() => impl.createPitchService();
