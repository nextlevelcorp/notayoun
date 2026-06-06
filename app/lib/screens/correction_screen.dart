import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note_event.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/song_repository.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';
import 'play_screen.dart';

/// "Şunu mu demek istedin?" — OMR sonrası basit düzeltme ekranı.
///
/// Yanlış okunan notayı kullanıcı yarım ses yukarı/aşağı kaydırabilir veya
/// silebilir. Onaylayınca parça cihazda saklanır ve oyun başlar.
class CorrectionScreen extends StatefulWidget {
  const CorrectionScreen({super.key, required this.song});

  final Song song;

  @override
  State<CorrectionScreen> createState() => _CorrectionScreenState();
}

class _CorrectionScreenState extends State<CorrectionScreen> {
  late List<NoteEvent> _notes;

  @override
  void initState() {
    super.initState();
    _notes = List<NoteEvent>.from(widget.song.notes);
  }

  void _shift(int index, int semitones) {
    final n = _notes[index];
    final newMidi = (n.midi + semitones).clamp(21, 108);
    setState(() {
      _notes[index] = n.copyWith(
        midi: newMidi,
        name: NoteColors.nameForMidi(newMidi),
      );
    });
    context.read<AudioService>().playNote(newMidi);
  }

  void _delete(int index) => setState(() => _notes.removeAt(index));

  Future<void> _confirm() async {
    final corrected = Song(
      id: widget.song.id,
      title: widget.song.title,
      tempoBpm: widget.song.tempoBpm,
      beatsPerMeasure: widget.song.beatsPerMeasure,
      notes: _notes,
    );
    await context.read<SongRepository>().addSong(corrected);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => PlayScreen(song: corrected)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notaları Kontrol Et')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Text(
                'Yanlış okunan bir nota varsa düzelt. Hazırsan onayla! 🎵',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base),
                itemCount: _notes.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) => _noteRow(i),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _notes.isEmpty ? null : _confirm,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Onayla ve Çal'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteRow(int i) {
    final n = _notes[i];
    final color = NoteColors.forMidi(n.midi);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: Text(
                n.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '${i + 1}. nota · vuruş ${n.startBeat}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            IconButton(
              tooltip: 'Yarım ses pes',
              onPressed: () => _shift(i, -1),
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
            IconButton(
              tooltip: 'Yarım ses tiz',
              onPressed: () => _shift(i, 1),
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
            IconButton(
              tooltip: 'Sil',
              onPressed: () => _delete(i),
              icon: Icon(Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}
