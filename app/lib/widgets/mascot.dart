import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/theme_variants.dart';

/// Basit maskot: yuvarlak bir nota karakteri (emoji tabanlı, v1).
/// [costume] verilirse renkleri ve küçük bir aksesuar emojisini değiştirir.
class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    this.size = 96,
    this.mood = MascotMood.happy,
    this.costume,
  });

  final double size;
  final MascotMood mood;
  final MascotCostume? costume;

  @override
  Widget build(BuildContext context) {
    final colors = NotaOyunColors.of(context);
    final start = costume?.gradientStart ??
        Theme.of(context).colorScheme.secondary;
    final end = costume?.gradientEnd ?? colors.gold;

    final face = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: end.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _emoji,
        style: TextStyle(fontSize: size * 0.5),
      ),
    );

    final accessory = costume?.accessory;
    if (accessory == null) return face;

    // Aksesuarı sağ üst köşeye küçük bir rozet gibi yerleştir.
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          face,
          Positioned(
            top: -size * 0.08,
            right: -size * 0.04,
            child: Text(accessory, style: TextStyle(fontSize: size * 0.32)),
          ),
        ],
      ),
    );
  }

  String get _emoji {
    switch (mood) {
      case MascotMood.happy:
        return '🎵';
      case MascotMood.celebrate:
        return '🥳';
      case MascotMood.think:
        return '🤔';
      case MascotMood.wave:
        return '👋';
    }
  }
}

enum MascotMood { happy, celebrate, think, wave }
