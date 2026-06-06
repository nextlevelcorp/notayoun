import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../services/song_repository.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';
import '../widgets/mascot.dart';
import 'import_screen.dart';
import 'play_screen.dart';

/// (1) Ana / kütüphane ekranı — cihazdaki şarkıları listeler.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<SongRepository>();

    return Scaffold(
      body: SafeArea(
        child: !repo.isLoaded
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _header(context)),
                  if (repo.songs.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _empty(context),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.base,
                        0,
                        AppSpacing.base,
                        AppSpacing.huge,
                      ),
                      sliver: SliverList.separated(
                        itemCount: repo.songs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, i) =>
                            _SongCard(song: repo.songs[i]),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ImportScreen()),
        ),
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('İçe Aktar'),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          const Mascot(size: 64, mood: MascotMood.wave),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Merhaba! 👋',
                    style: Theme.of(context).textTheme.bodyMedium),
                Text('Şarkı Kütüphanesi',
                    style: Theme.of(context).textTheme.displayMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Mascot(size: 120, mood: MascotMood.happy),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Henüz şarkı yok',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bir nota kâğıdı fotoğrafı ekleyerek başla!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  const _SongCard({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final accent = song.notes.isNotEmpty
        ? NoteColors.forMidi(song.notes.first.midi)
        : Theme.of(context).colorScheme.primary;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => PlayScreen(song: song)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.music_note_rounded, color: accent, size: 30),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${song.tempoBpm} BPM · ${song.notes.length} nota',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill_rounded, color: accent, size: 40),
            ],
          ),
        ),
      ),
    );
  }
}
