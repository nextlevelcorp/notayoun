import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import 'pitch_detector.dart';
import 'pitch_service_base.dart';

/// Android / iOS / masaüstü: mikrofondan PCM16 akışı alır, saf-Dart
/// [PitchDetector] ile çalınan notayı bulur ve [NoteStabilizer] ile
/// kararlı hale getirip yayınlar.
class MicPitchService implements PitchService {
  static const int _sampleRate = 44100;
  static const int _window = 2048; // ~46 ms analiz penceresi
  static const int _hop = 1024; // pencereler arası kayma

  final AudioRecorder _recorder = AudioRecorder();
  final PitchDetector _detector = PitchDetector(sampleRate: _sampleRate);
  final NoteStabilizer _stabilizer = NoteStabilizer();

  final List<double> _buffer = [];
  StreamSubscription<Uint8List>? _sub;
  bool _running = false;

  @override
  bool get isSupported => true;

  @override
  Future<bool> start(void Function(int midi) onNote) async {
    if (_running) return true;
    try {
      if (!await _recorder.hasPermission()) return false;
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ),
      );
      _running = true;
      _sub = stream.listen(
        (chunk) => _onChunk(chunk, onNote),
        onError: (Object e) => debugPrint('Mikrofon akış hatası: $e'),
      );
      return true;
    } catch (e) {
      debugPrint('Mikrofon başlatılamadı: $e');
      _running = false;
      return false;
    }
  }

  void _onChunk(Uint8List chunk, void Function(int midi) onNote) {
    // PCM16 little-endian → [-1, 1] double.
    final bd = ByteData.sublistView(chunk);
    for (var i = 0; i + 1 < chunk.lengthInBytes; i += 2) {
      _buffer.add(bd.getInt16(i, Endian.little) / 32768.0);
    }

    while (_buffer.length >= _window) {
      final frame = _buffer.sublist(0, _window);
      final midi = _detector.detectMidi(frame);
      final stable = _stabilizer.push(midi);
      if (stable != null) onNote(stable);
      _buffer.removeRange(0, _hop);
    }

    // Tampon kontrolden çıkmasın.
    if (_buffer.length > _window * 4) {
      _buffer.removeRange(0, _buffer.length - _window);
    }
  }

  @override
  Future<void> stop() async {
    _running = false;
    await _sub?.cancel();
    _sub = null;
    _buffer.clear();
    _stabilizer.reset();
    try {
      await _recorder.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    _recorder.dispose();
  }
}

PitchService createPitchService() => MicPitchService();
