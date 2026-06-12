import 'dart:math' as math;

/// Saf-Dart, autocorrelation tabanlı temel frekans (pitch) bulucu.
///
/// Bir [AudioPlayer] veya platform kanalı gerektirmez; bir örnek tamponu (PCM,
/// [-1, 1] aralığında double) alıp baskın frekansı tahmin eder. Çocukların
/// piyano çalışını "yönlendirmek" için yeterince iyidir; stüdyo doğruluğu
/// hedeflenmez. Tüm platformlarda (web dahil) derlenir → birim testi yapılır.
class PitchDetector {
  PitchDetector({
    this.sampleRate = 44100,
    this.minHz = 70, // ~ C#2
    this.maxHz = 1100, // ~ C#6
    this.rmsThreshold = 0.02, // sessizlik eşiği
    this.clarityThreshold = 0.85, // korelasyon güveni
  });

  final int sampleRate;
  final double minHz;
  final double maxHz;
  final double rmsThreshold;
  final double clarityThreshold;

  /// Verilen örneklerden temel frekansı (Hz) döndürür; bulunamazsa `null`.
  double? detectHz(List<double> samples) {
    final n = samples.length;
    if (n < 256) return null;

    // Sessizlik kontrolü (RMS).
    double sumSq = 0;
    for (final s in samples) {
      sumSq += s * s;
    }
    final rms = math.sqrt(sumSq / n);
    if (rms < rmsThreshold) return null;

    final maxLag = math.min(n ~/ 2, (sampleRate / minHz).floor());
    final minLag = math.max(2, (sampleRate / maxHz).floor());
    if (minLag >= maxLag) return null;

    // Normalleştirilmiş autocorrelation; en güçlü zirveyi (ilk vadiden sonra) bul.
    double bestCorr = 0;
    int bestLag = -1;

    // r(0) — enerji.
    double r0 = 0;
    for (var i = 0; i < n; i++) {
      r0 += samples[i] * samples[i];
    }
    if (r0 == 0) return null;

    for (var lag = minLag; lag <= maxLag; lag++) {
      double corr = 0;
      for (var i = 0; i < n - lag; i++) {
        corr += samples[i] * samples[i + lag];
      }
      final norm = corr / r0;
      if (norm > bestCorr) {
        bestCorr = norm;
        bestLag = lag;
      }
    }

    if (bestLag < 0 || bestCorr < clarityThreshold) return null;

    // Parabolik enterpolasyon ile lag'i ince ayarla.
    final refined = _parabolicLag(samples, bestLag, r0);
    final hz = sampleRate / refined;
    if (hz < minHz || hz > maxHz) return null;
    return hz;
  }

  /// Frekansı en yakın MIDI notasına çevirir; bulunamazsa `null`.
  int? detectMidi(List<double> samples) {
    final hz = detectHz(samples);
    if (hz == null) return null;
    return hzToMidi(hz);
  }

  double _parabolicLag(List<double> samples, int lag, double r0) {
    double corrAt(int l) {
      if (l < 1 || l >= samples.length) return 0;
      double c = 0;
      for (var i = 0; i < samples.length - l; i++) {
        c += samples[i] * samples[i + l];
      }
      return c / r0;
    }

    final y1 = corrAt(lag - 1);
    final y2 = corrAt(lag);
    final y3 = corrAt(lag + 1);
    final denom = (y1 - 2 * y2 + y3);
    if (denom == 0) return lag.toDouble();
    final delta = 0.5 * (y1 - y3) / denom;
    return lag + delta.clamp(-1.0, 1.0);
  }

  /// Frekans (Hz) → en yakın MIDI nota numarası.
  static int hzToMidi(double hz) =>
      (69 + 12 * (math.log(hz / 440.0) / math.ln2)).round();
}

/// Ardışık MIDI tahminlerini kararlı hale getiren basit filtre.
///
/// Aynı nota üst üste [requiredHits] kez algılanınca "onaylanmış" sayılır;
/// böylece tek-kare gürültüleri ve oktav sıçramaları elenir. Aynı nota,
/// [minGap] geçmeden tekrar yayınlanmaz.
class NoteStabilizer {
  NoteStabilizer({
    this.requiredHits = 2,
    this.minGap = const Duration(milliseconds: 180),
  });

  final int requiredHits;
  final Duration minGap;

  int? _candidate;
  int _candidateCount = 0;
  int? _lastEmitted;
  DateTime _lastEmitTime = DateTime.fromMillisecondsSinceEpoch(0);

  /// Bir tahmin ekler; yeni bir nota onaylandıysa onu döndürür, aksi halde null.
  /// [midi] null ise (sessizlik) aday sıfırlanır ve tekrar yayına izin verilir.
  int? push(int? midi, {DateTime? now}) {
    final t = now ?? DateTime.now();
    if (midi == null) {
      _candidate = null;
      _candidateCount = 0;
      _lastEmitted = null; // sessizlik sonrası aynı nota yeniden çalınabilir
      return null;
    }

    if (midi == _candidate) {
      _candidateCount++;
    } else {
      _candidate = midi;
      _candidateCount = 1;
    }

    if (_candidateCount < requiredHits) return null;

    final isRepeat = midi == _lastEmitted;
    if (isRepeat && t.difference(_lastEmitTime) < minGap) return null;

    _lastEmitted = midi;
    _lastEmitTime = t;
    return midi;
  }

  void reset() {
    _candidate = null;
    _candidateCount = 0;
    _lastEmitted = null;
    _lastEmitTime = DateTime.fromMillisecondsSinceEpoch(0);
  }
}
