/// Nota adı gösterim biçimi (ayarlardan seçilir).
enum NoteNameStyle {
  /// Hiç gösterme.
  none,

  /// Solfej: Do, Re, Mi…
  solfej,

  /// Harf: C, D, E…
  letter,
}

extension NoteNameStyleX on NoteNameStyle {
  String get label {
    switch (this) {
      case NoteNameStyle.none:
        return 'Kapalı';
      case NoteNameStyle.solfej:
        return 'Do-Re-Mi';
      case NoteNameStyle.letter:
        return 'A-B-C';
    }
  }

  String get storageKey {
    switch (this) {
      case NoteNameStyle.none:
        return 'none';
      case NoteNameStyle.solfej:
        return 'solfej';
      case NoteNameStyle.letter:
        return 'letter';
    }
  }

  static NoteNameStyle fromStorage(String? s) {
    switch (s) {
      case 'none':
        return NoteNameStyle.none;
      case 'letter':
        return NoteNameStyle.letter;
      case 'solfej':
      default:
        return NoteNameStyle.solfej;
    }
  }
}

/// MIDI numarasını seçilen biçime göre adlandırır.
class NoteNaming {
  const NoteNaming._();

  static const _solfej = <String>[
    'Do', 'Do#', 'Re', 'Re#', 'Mi', 'Fa', //
    'Fa#', 'Sol', 'Sol#', 'La', 'La#', 'Si',
  ];

  static const _letter = <String>[
    'C', 'C#', 'D', 'D#', 'E', 'F', //
    'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  /// Solfej adı (oktav bilgisi olmadan).
  static String solfej(int midi) => _solfej[midi % 12];

  /// Harf adı (oktav numarasıyla, örn. C4).
  static String letter(int midi) => '${_letter[midi % 12]}${midi ~/ 12 - 1}';

  /// Seçili biçime göre etiket; [none] ise boş döner.
  static String forStyle(int midi, NoteNameStyle style) {
    switch (style) {
      case NoteNameStyle.none:
        return '';
      case NoteNameStyle.solfej:
        return solfej(midi);
      case NoteNameStyle.letter:
        return letter(midi);
    }
  }
}
