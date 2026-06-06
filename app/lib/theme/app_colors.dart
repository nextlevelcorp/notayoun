import 'package:flutter/material.dart';

/// NotaOyun ColorScheme (Material 3, light).
/// FLUTTER_TOKENS.md bölüm 1 ile birebir.
const ColorScheme kNotaOyunColorScheme = ColorScheme.light(
  surface: Color(0xFFFFFDF7), // bgSurface
  primary: Color(0xFFF4613C), // mercan
  onPrimary: Colors.white,
  secondary: Color(0xFF0BBFAE), // turkuaz
  onSecondary: Colors.white,
  tertiary: Color(0xFF7B4FD4), // mor
  onTertiary: Colors.white,
  error: Color(0xFFE84040),
  onError: Colors.white,
  onSurface: Color(0xFF2A1600), // textPrimary
  outline: Color(0xFF8C6840), // textSecond
  outlineVariant: Color(0xFFC4A882), // textDisabled
);

/// Arka plan rengi (ColorScheme.background M3'te kaldırıldığı için ayrı tutuyoruz).
const Color kBgBase = Color(0xFFFFF6E9);

/// ThemeData içine eklenen ek (semantik) renkler.
/// FLUTTER_TOKENS.md bölüm 1 — Ek Renkler.
@immutable
class NotaOyunColors extends ThemeExtension<NotaOyunColors> {
  const NotaOyunColors({
    this.gold = const Color(0xFFF5A623),
    this.success = const Color(0xFF2CC16B),
    this.warning = const Color(0xFFF58C22),
    this.gameBg = const Color(0xFF1A0A30),
    this.gameSurface = const Color(0xFF2D1650),
    this.primaryDim = const Color(0xFFFFEAE5),
    this.secondaryDim = const Color(0xFFDFFAF7),
    this.goldDim = const Color(0xFFFFF4DC),
    this.purpleDim = const Color(0xFFEDE7FA),
    this.successDim = const Color(0xFFDCFAAA),
  });

  final Color gold;
  final Color success;
  final Color warning;
  final Color gameBg;
  final Color gameSurface;
  final Color primaryDim;
  final Color secondaryDim;
  final Color goldDim;
  final Color purpleDim;
  final Color successDim;

  @override
  NotaOyunColors copyWith({
    Color? gold,
    Color? success,
    Color? warning,
    Color? gameBg,
    Color? gameSurface,
    Color? primaryDim,
    Color? secondaryDim,
    Color? goldDim,
    Color? purpleDim,
    Color? successDim,
  }) {
    return NotaOyunColors(
      gold: gold ?? this.gold,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      gameBg: gameBg ?? this.gameBg,
      gameSurface: gameSurface ?? this.gameSurface,
      primaryDim: primaryDim ?? this.primaryDim,
      secondaryDim: secondaryDim ?? this.secondaryDim,
      goldDim: goldDim ?? this.goldDim,
      purpleDim: purpleDim ?? this.purpleDim,
      successDim: successDim ?? this.successDim,
    );
  }

  @override
  NotaOyunColors lerp(ThemeExtension<NotaOyunColors>? other, double t) {
    if (other is! NotaOyunColors) return this;
    return NotaOyunColors(
      gold: Color.lerp(gold, other.gold, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      gameBg: Color.lerp(gameBg, other.gameBg, t)!,
      gameSurface: Color.lerp(gameSurface, other.gameSurface, t)!,
      primaryDim: Color.lerp(primaryDim, other.primaryDim, t)!,
      secondaryDim: Color.lerp(secondaryDim, other.secondaryDim, t)!,
      goldDim: Color.lerp(goldDim, other.goldDim, t)!,
      purpleDim: Color.lerp(purpleDim, other.purpleDim, t)!,
      successDim: Color.lerp(successDim, other.successDim, t)!,
    );
  }

  /// Tema içinden kısa erişim: `context.notaColors`.
  static NotaOyunColors of(BuildContext context) {
    return Theme.of(context).extension<NotaOyunColors>() ??
        const NotaOyunColors();
  }
}

/// Müzik notalarının (solfej) renkleri. FLUTTER_TOKENS.md bölüm 7.
class NoteColors {
  const NoteColors._();

  static const Color do_ = Color(0xFFF4613C); // Mercan
  static const Color re = Color(0xFFF5A623); // Altın
  static const Color mi = Color(0xFFFFD600); // Sarı
  static const Color fa = Color(0xFF2CC16B); // Yeşil
  static const Color sol = Color(0xFF0BBFAE); // Turkuaz
  static const Color la = Color(0xFF7B4FD4); // Mor
  static const Color si = Color(0xFFE84898); // Pembe

  /// MIDI nota numarasından (pitch class) renk döner.
  static Color forMidi(int midi) {
    const palette = <Color>[
      do_, // C
      do_, // C#
      re, // D
      re, // D#
      mi, // E
      fa, // F
      fa, // F#
      sol, // G
      sol, // G#
      la, // A
      la, // A#
      si, // B
    ];
    return palette[midi % 12];
  }

  /// MIDI nota numarasından solfej adı döner (UI gösterimi).
  static String nameForMidi(int midi) {
    const names = <String>[
      'Do', 'Do#', 'Re', 'Re#', 'Mi', 'Fa', //
      'Fa#', 'Sol', 'Sol#', 'La', 'La#', 'Si',
    ];
    return names[midi % 12];
  }
}
