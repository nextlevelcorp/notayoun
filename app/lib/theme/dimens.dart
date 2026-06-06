import 'package:flutter/material.dart';

/// 4dp tabanlı spacing skalası. FLUTTER_TOKENS.md bölüm 3.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4.0; // İkon–metin arası
  static const double sm = 8.0; // Çok küçük gap
  static const double md = 12.0; // Kart iç boşluk
  static const double base = 16.0; // Temel padding
  static const double lg = 24.0; // Bölüm başlık altı
  static const double xl = 32.0; // Büyük bölüm arası
  static const double huge = 48.0; // Ekran kenar payı
}

/// Border radius skalası. FLUTTER_TOKENS.md bölüm 4.
class AppRadius {
  const AppRadius._();

  static const double sm = 8.0; // Küçük eleman (ikon bg)
  static const double md = 16.0; // Kart, panel
  static const double lg = 24.0; // Büyük kart, modal
  static const double xl = 32.0; // Kamera çerçevesi
  static const double full = 999.0; // Pill buton, FAB, chip
}

/// Gölgeler. FLUTTER_TOKENS.md bölüm 5.
class AppShadow {
  const AppShadow._();

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// Renkli "oyuncak buton" gölgesi (alt kenar + yumuşak halo).
  static List<BoxShadow> button(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.53),
          blurRadius: 0,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

/// Erişilebilirlik sabitleri. FLUTTER_TOKENS.md bölüm 6.
class AppA11y {
  const AppA11y._();

  static const double minTouchTarget = 48.0; // Minimum dokunma hedefi
  static const double minFontSize = 11.0; // Minimum yazı boyutu
}
