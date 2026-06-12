import 'package:flutter/material.dart';

/// Çocuğun seçebileceği bir renk teması.
///
/// [requiredBadgeId] doluysa, tema yalnızca o rozet kazanılınca açılır.
@immutable
class ThemeVariant {
  const ThemeVariant({
    required this.id,
    required this.title,
    required this.emoji,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.gameBg,
    required this.gameSurface,
    this.requiredBadgeId,
  });

  final String id;
  final String title;
  final String emoji;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color gameBg;
  final Color gameSurface;
  final String? requiredBadgeId;
}

/// Maskot kostümü (renk + aksesuar emoji).
@immutable
class MascotCostume {
  const MascotCostume({
    required this.id,
    required this.title,
    required this.gradientStart,
    required this.gradientEnd,
    this.accessory,
    this.requiredBadgeId,
  });

  final String id;
  final String title;
  final Color gradientStart;
  final Color gradientEnd;

  /// Yüzün üstüne/yanına eklenen küçük emoji (şapka, yıldız…). Boşsa yok.
  final String? accessory;
  final String? requiredBadgeId;
}

/// Uygulamadaki tema ve kostüm kataloğu.
class Customizations {
  const Customizations._();

  static const List<ThemeVariant> themes = [
    ThemeVariant(
      id: 'classic',
      title: 'Klasik',
      emoji: '🎵',
      primary: Color(0xFFF4613C),
      secondary: Color(0xFF0BBFAE),
      tertiary: Color(0xFF7B4FD4),
      gameBg: Color(0xFF1A0A30),
      gameSurface: Color(0xFF2D1650),
    ),
    ThemeVariant(
      id: 'ocean',
      title: 'Okyanus',
      emoji: '🐳',
      primary: Color(0xFF1E88E5),
      secondary: Color(0xFF00BCD4),
      tertiary: Color(0xFF7E57C2),
      gameBg: Color(0xFF06243F),
      gameSurface: Color(0xFF0C3A63),
    ),
    ThemeVariant(
      id: 'candy',
      title: 'Şeker',
      emoji: '🍭',
      primary: Color(0xFFEC407A),
      secondary: Color(0xFFFFB300),
      tertiary: Color(0xFFAB47BC),
      gameBg: Color(0xFF2E0B28),
      gameSurface: Color(0xFF4A1342),
      requiredBadgeId: 'first_song',
    ),
    ThemeVariant(
      id: 'forest',
      title: 'Orman',
      emoji: '🌳',
      primary: Color(0xFF2E9E5B),
      secondary: Color(0xFF7CB342),
      tertiary: Color(0xFFFB8C00),
      gameBg: Color(0xFF08240F),
      gameSurface: Color(0xFF103D1C),
      requiredBadgeId: 'five_songs',
    ),
  ];

  static const List<MascotCostume> mascots = [
    MascotCostume(
      id: 'classic',
      title: 'Nota',
      gradientStart: Color(0xFF0BBFAE),
      gradientEnd: Color(0xFFF5A623),
    ),
    MascotCostume(
      id: 'party',
      title: 'Partici',
      gradientStart: Color(0xFFEC407A),
      gradientEnd: Color(0xFFFFB300),
      accessory: '🎉',
    ),
    MascotCostume(
      id: 'star',
      title: 'Yıldız',
      gradientStart: Color(0xFF7B4FD4),
      gradientEnd: Color(0xFF00BCD4),
      accessory: '⭐',
      requiredBadgeId: 'streak_3',
    ),
    MascotCostume(
      id: 'wizard',
      title: 'Sihirbaz',
      gradientStart: Color(0xFF311B92),
      gradientEnd: Color(0xFF7E57C2),
      accessory: '🎩',
      requiredBadgeId: 'streak_7',
    ),
  ];

  static ThemeVariant themeById(String id) =>
      themes.firstWhere((t) => t.id == id, orElse: () => themes.first);

  static MascotCostume mascotById(String id) =>
      mascots.firstWhere((m) => m.id == id, orElse: () => mascots.first);
}
