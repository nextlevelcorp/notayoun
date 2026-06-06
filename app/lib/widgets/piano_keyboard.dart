import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/dimens.dart';

/// Ekranın altındaki renkli klavye şeridi. Her şerit (lane) bir notaya karşılık
/// gelir; çalınan nota "yanar". Dokununca [onTap] ile ses tetiklenir.
class PianoKeyboard extends StatelessWidget {
  const PianoKeyboard({
    super.key,
    required this.lanes,
    required this.activeMidis,
    required this.onTap,
    this.height = 96,
  });

  /// Soldan sağa şeritlerin MIDI değerleri (artan).
  final List<int> lanes;
  final Set<int> activeMidis;
  final ValueChanged<int> onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (final midi in lanes)
            Expanded(
              child: _Key(
                midi: midi,
                active: activeMidis.contains(midi),
                onTap: () => onTap(midi),
              ),
            ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.midi,
    required this.active,
    required this.onTap,
  });

  final int midi;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = NoteColors.forMidi(midi);
    final label = NoteColors.nameForMidi(midi);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          decoration: BoxDecoration(
            color: active ? color : color.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: active ? AppShadow.button(color) : AppShadow.sm,
            border: Border.all(
              color: Colors.white.withValues(alpha: active ? 0.9 : 0.3),
              width: 2,
            ),
          ),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
