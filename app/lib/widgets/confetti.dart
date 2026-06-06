import 'dart:math';

import 'package:flutter/material.dart';

/// Hafif kutlama konfetisi — ek paket gerektirmeyen basit CustomPainter.
class Confetti extends StatefulWidget {
  const Confetti({super.key, this.pieces = 40, this.colors = const []});

  final int pieces;
  final List<Color> colors;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(widget.pieces, (_) => _Piece(rng));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors.isNotEmpty
        ? widget.colors
        : [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
            Colors.amber,
          ];
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(_particles, _controller.value, colors),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Piece {
  _Piece(Random rng)
      : x = rng.nextDouble(),
        startY = -rng.nextDouble() * 0.3,
        speed = 0.6 + rng.nextDouble() * 0.8,
        drift = (rng.nextDouble() - 0.5) * 0.3,
        size = 6 + rng.nextDouble() * 8,
        colorIndex = rng.nextInt(4),
        rotation = rng.nextDouble() * pi;

  final double x;
  final double startY;
  final double speed;
  final double drift;
  final double size;
  final int colorIndex;
  final double rotation;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t, this.colors);

  final List<_Piece> pieces;
  final double t;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      final y = (p.startY + p.speed * t) * size.height;
      if (y < 0 || y > size.height) continue;
      final x = (p.x + p.drift * t) * size.width;
      paint.color = colors[p.colorIndex % colors.length]
          .withValues(alpha: (1 - t).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + t * 6);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
