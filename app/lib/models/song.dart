import 'dart:convert';

import 'note_event.dart';

/// Bir parçanın tamamı: backend'in ürettiği / cihazda saklanan "note timeline".
class Song {
  const Song({
    required this.id,
    required this.title,
    required this.tempoBpm,
    required this.beatsPerMeasure,
    required this.notes,
  });

  /// Yerel benzersiz kimlik (cache anahtarı). JSON'da yoksa başlıktan türetilir.
  final String id;
  final String title;
  final int tempoBpm;
  final int beatsPerMeasure;
  final List<NoteEvent> notes;

  /// Parçanın toplam uzunluğu (vuruş cinsinden).
  double get totalBeats {
    if (notes.isEmpty) return 0;
    return notes
        .map((n) => n.endBeat)
        .reduce((a, b) => a > b ? a : b);
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? 'Adsız Parça';
    final notes = (json['notes'] as List<dynamic>? ?? [])
        .map((e) => NoteEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    return Song(
      id: json['id'] as String? ?? _slug(title),
      title: title,
      tempoBpm: (json['tempoBpm'] as num?)?.toInt() ?? 90,
      beatsPerMeasure: (json['beatsPerMeasure'] as num?)?.toInt() ?? 4,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'tempoBpm': tempoBpm,
        'beatsPerMeasure': beatsPerMeasure,
        'notes': notes.map((n) => n.toJson()).toList(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory Song.fromJsonString(String source) =>
      Song.fromJson(jsonDecode(source) as Map<String, dynamic>);

  static String _slug(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}
