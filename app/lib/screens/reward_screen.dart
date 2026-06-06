import 'package:flutter/material.dart';

import '../models/song.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';
import '../widgets/mascot.dart';
import 'play_screen.dart';

/// (5) Ödül ekranı — parça bitince yıldız + kutlama.
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

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = NotaOyunColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: Mascot(size: 140, mood: MascotMood.celebrate)),
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
