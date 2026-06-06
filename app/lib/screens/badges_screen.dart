import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/badge.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';

/// Başarılar (rozetler + gün serisi) ekranı.
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final unlocked = progress.unlockedBadgeIds;
    final colors = NotaOyunColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Başarılar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.base),
          children: [
            _streakCard(context, colors, progress.streakCount),
            const SizedBox(height: AppSpacing.lg),
            Text('Rozetler', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.1,
              children: [
                for (final b in Badges.all)
                  _BadgeTile(badge: b, unlocked: unlocked.contains(b.id)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _streakCard(
      BuildContext context, NotaOyunColors colors, int streak) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.goldDim,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 44)),
          const SizedBox(width: AppSpacing.base),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$streak gün',
                  style: Theme.of(context).textTheme.displayMedium),
              Text('Üst üste çalma serisi',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.unlocked});

  final BadgeDef badge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: unlocked ? AppShadow.sm : null,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(unlocked ? badge.emoji : '🔒',
                style: const TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.sm),
            Text(badge.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(badge.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
