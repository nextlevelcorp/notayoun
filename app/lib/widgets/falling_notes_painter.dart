import 'package:flutter/material.dart';

import '../models/note_event.dart';
import '../models/note_naming.dart';
import '../theme/app_colors.dart';

/// Düşen notaları çizen [CustomPainter].
///
/// Notalar yukarıdan iner; [lookAheadBeats] beat ileriden görünür ve
/// `startBeat == currentBeat` olduğunda alttaki vuruş çizgisine değer.
class FallingNotesPainter extends CustomPainter {
  FallingNotesPainter({
    required this.notes,
    required this.currentBeat,
    required this.lookAheadBeats,
    required this.laneOf,
    required this.laneCount,
    this.nameStyle = NoteNameStyle.solfej,
    this.waiting = false,
  });

  final List<NoteEvent> notes;
  final double currentBeat;
  final double lookAheadBeats;
  final NoteNameStyle nameStyle;

  /// Bekleme modunda çizgide donulduğunu vurgular.
  final bool waiting;

  /// MIDI → şerit (lane) indeksi.
  final int Function(int midi) laneOf;
  final int laneCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (laneCount <= 0) return;
    final laneWidth = size.width / laneCount;
    final hitLineY = size.height;

    // Şerit ayraçları (hafif).
    final dividerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var i = 1; i < laneCount; i++) {
      final x = i * laneWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), dividerPaint);
    }

    // Vuruş çizgisi (bekleme modunda altın renkli ve kalın → "şimdi çal").
    final hitPaint = Paint()
      ..color = waiting
          ? const Color(0xFFF5A623)
          : Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = waiting ? 5 : 3;
    canvas.drawLine(
      Offset(0, hitLineY - 1.5),
      Offset(size.width, hitLineY - 1.5),
      hitPaint,
    );

    for (final note in notes) {
      final lane = laneOf(note.midi);
      if (lane < 0) continue;

      final beatsUntilHit = note.startBeat - currentBeat;
      final fraction = beatsUntilHit / lookAheadBeats; // 1=tepe, 0=çizgi
      final bottomY = size.height * (1 - fraction);
      final noteHeight =
          (note.durationBeats / lookAheadBeats) * size.height * 0.9;
      final topY = bottomY - noteHeight;

      const gap = 6.0;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          lane * laneWidth + gap,
          topY,
          laneWidth - gap * 2,
          noteHeight.clamp(10.0, size.height),
        ),
        const Radius.circular(10),
      );

      final color = NoteColors.forMidi(note.midi);
      // Çizgiye yaklaştıkça parlasın.
      final glow = (1 - fraction).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = color.withValues(alpha: 0.85 + 0.15 * glow);
      canvas.drawRRect(rect, paint);

      // Üst kenarda açık şerit (hacim hissi).
      final highlight = Paint()..color = Colors.white.withValues(alpha: 0.25);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left, rect.top, rect.width, 4),
          const Radius.circular(10),
        ),
        highlight,
      );

      // Nota adı (yer varsa ve gösterim açıksa).
      final label = NoteNaming.forStyle(note.midi, nameStyle);
      if (noteHeight > 22 && label.isNotEmpty) {
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: laneWidth);
        tp.paint(
          canvas,
          Offset(
            rect.left + (rect.width - tp.width) / 2,
            bottomY - tp.height - 4,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant FallingNotesPainter old) =>
      old.currentBeat != currentBeat ||
      old.notes != notes ||
      old.laneCount != laneCount ||
      old.nameStyle != nameStyle ||
      old.waiting != waiting;
}
