import 'package:flutter/material.dart';

import '../models/note_naming.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';

/// Ekranın altındaki renkli klavye şeridi. Her şerit (lane) bir notaya karşılık
/// gelir; çalınan nota "yanar". Dokununca [onTap] ile değerlendirme tetiklenir.
///
/// Bekleme modunda [expectedMidis] basılması gereken tuşları (ipucu) vurgular,
/// [wrongMidi] ise son yanlış tuşu kırmızı gösterir.
class PianoKeyboard extends StatelessWidget {
  const PianoKeyboard({
    super.key,
    required this.lanes,
    required this.activeMidis,
    required this.onTap,
    this.expectedMidis = const {},
    this.wrongMidi,
    this.nameStyle = NoteNameStyle.solfej,
    this.height = 96,
  });

  /// Soldan sağa şeritlerin MIDI değerleri (artan).
  final List<int> lanes;
  final Set<int> activeMidis;
  final Set<int> expectedMidis;
  final int? wrongMidi;
  final NoteNameStyle nameStyle;
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
                expected: expectedMidis.contains(midi),
                wrong: wrongMidi == midi,
                nameStyle: nameStyle,
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
    required this.expected,
    required this.wrong,
    required this.nameStyle,
    required this.onTap,
  });

  final int midi;
  final bool active;
  final bool expected;
  final bool wrong;
  final NoteNameStyle nameStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = NoteColors.forMidi(midi);
    final label = NoteNaming.forStyle(midi, nameStyle);
    final lit = active || expected;

    final borderColor = wrong
        ? const Color(0xFFE84040)
        : expected
            ? Colors.white
            : Colors.white.withValues(alpha: lit ? 0.9 : 0.3);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          decoration: BoxDecoration(
            color: wrong
                ? const Color(0xFFE84040).withValues(alpha: 0.55)
                : lit
                    ? color
                    : color.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: lit ? AppShadow.button(color) : AppShadow.sm,
            border: Border.all(
              color: borderColor,
              width: expected || wrong ? 3 : 2,
            ),
          ),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: label.isEmpty
              ? null
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}
