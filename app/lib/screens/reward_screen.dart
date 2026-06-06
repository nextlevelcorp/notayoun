import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/badge.dart';
import '../models/song.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';
import '../widgets/confetti.dart';
import '../widgets/mascot.dart';
import 'play_screen.dart';

/// (5) Ödül ekranı — parça bitince yıldız + kutlama + yeni rozetler.
class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key, required this.song, this.stars = 3});

  final Song song;
  final int stars;

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  List<BadgeDef> _newBadges = const [];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _recordProgress();
  }

  Future<void> _recordProgress() async {
    final progress = context.read<ProgressService>();
    final newly = await progress.recordSongCompleted(widget.song.id);
    if (mounted && newly.isNotEmpty) {
      setState(() => _newBadges = newly);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = NotaOyunColors.of(context);
    final streak = context.watch<ProgressService>().streakCount;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                      child: Mascot(size: 140, mood: MascotMood.celebrate)),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Aferin! 🎉',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '"${widget.song.title}" parçasını çaldın!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _stars(colors),
                  if (streak > 0) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text('🔥 $streak günlük seri!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                  if (_newBadges.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _newBadgesBanner(colors),
                  ],
                  const SizedBox(height: AppSpacing.huge),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => PlayScreen(song: widget.song),
                      ),
                    ),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Tekrar Çal'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Kütüphaneye Dön'),
                  ),
                ],
              ),
            ),
          ),
          const Positioned.fill(child: Confetti()),
        ],
      ),
    );
  }

  Widget _newBadgesBanner(NotaOyunColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.successDim,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text('Yeni rozet${_newBadges.length > 1 ? 'ler' : ''}!',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.md,
            children: [
              for (final b in _newBadges)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(b.emoji, style: const TextStyle(fontSize: 36)),
                    Text(b.title,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stars(NotaOyunColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < widget.stars;
        final delay = i * 0.25;
        final scale = CurvedAnimation(
          parent: _anim,
          curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0),
              curve: Curves.elasticOut),
        );
        return ScaleTransition(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: colors.gold,
              size: 64,
            ),
          ),
        );
      }),
    );
  }
}
