/// Hangi el ile çalınacak (tek porte ise hepsi [right]).
enum Hand { left, right }

Hand _handFromString(String? s) =>
    s == 'left' ? Hand.left : Hand.right;

String _handToString(Hand h) => h == Hand.left ? 'left' : 'right';

/// Tek bir nota olayı (note timeline'ın bir elemanı).
class NoteEvent {
  const NoteEvent({
    required this.midi,
    required this.name,
    required this.startBeat,
    required this.durationBeats,
    this.hand = Hand.right,
  });

  /// MIDI nota numarası (örn. 60 = orta Do).
  final int midi;

  /// Solfej adı (Do/Re/Mi…) — UI gösterimi için.
  final String name;

  /// Başlangıç anı (vuruş cinsinden).
  final double startBeat;

  /// Süre (vuruş cinsinden).
  final double durationBeats;

  /// Sağ/sol el.
  final Hand hand;

  double get endBeat => startBeat + durationBeats;

  NoteEvent copyWith({
    int? midi,
    String? name,
    double? startBeat,
    double? durationBeats,
    Hand? hand,
  }) {
    return NoteEvent(
      midi: midi ?? this.midi,
      name: name ?? this.name,
      startBeat: startBeat ?? this.startBeat,
      durationBeats: durationBeats ?? this.durationBeats,
      hand: hand ?? this.hand,
    );
  }

  factory NoteEvent.fromJson(Map<String, dynamic> json) {
    return NoteEvent(
      midi: (json['midi'] as num).toInt(),
      name: json['name'] as String? ?? '',
      startBeat: (json['startBeat'] as num).toDouble(),
      durationBeats: (json['durationBeats'] as num).toDouble(),
      hand: _handFromString(json['hand'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'midi': midi,
        'name': name,
        'startBeat': startBeat,
        'durationBeats': durationBeats,
        'hand': _handToString(hand),
      };
}
