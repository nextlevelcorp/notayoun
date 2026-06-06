import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Basit maskot: yuvarlak bir nota karakteri (emoji tabanlı, v1).
/// İleride özel illüstrasyon/animasyonla değiştirilebilir.
class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    this.size = 96,
    this.mood = MascotMood.happy,
  });

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    final colors = NotaOyunColors.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondary,
            colors.gold,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.gold.withValues(alpha: 0.35),
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
