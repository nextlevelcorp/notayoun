/// Bir başarı rozeti tanımı.
class BadgeDef {
  const BadgeDef({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
}

/// Uygulamadaki tüm rozetler.
class Badges {
  const Badges._();

  static const firstSong = BadgeDef(
    id: 'first_song',
    title: 'İlk Şarkı',
    description: 'İlk parçanı çaldın!',
    emoji: '🎵',
  );
  static const fiveSongs = BadgeDef(
    id: 'five_songs',
    title: 'Müzik Kâşifi',
    description: '5 parça çaldın!',
    emoji: '🎼',
  );
  static const streak3 = BadgeDef(
    id: 'streak_3',
    title: '3 Gün Üst Üste',
    description: '3 gün boyunca çaldın!',
    emoji: '🔥',
  );
  static const streak7 = BadgeDef(
    id: 'streak_7',
    title: 'Haftalık Yıldız',
    description: '7 gün üst üste çaldın!',
    emoji: '⭐',
  );
  static const importer = BadgeDef(
    id: 'importer',
    title: 'Nota Avcısı',
    description: 'Bir nota kâğıdı dönüştürdün!',
    emoji: '📸',
  );

  static const List<BadgeDef> all = [
    firstSong,
    fiveSongs,
    streak3,
    streak7,
    importer,
  ];

  static BadgeDef? byId(String id) {
    for (final b in all) {
      if (b.id == id) return b;
    }
    return null;
  }
}
