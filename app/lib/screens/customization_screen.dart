import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/badge.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';
import '../theme/theme_variants.dart';
import '../widgets/mascot.dart';

/// Tema ve maskot kişiselleştirme ekranı.
/// Bazı seçenekler rozet kazanılınca açılır.
class CustomizationScreen extends StatelessWidget {
  const CustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final unlocked = progress.unlockedBadgeIds;

    return Scaffold(
      appBar: AppBar(title: const Text('Kişiselleştir')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.base),
          children: [
            _sectionTitle(context, '🎨 Renk Teması'),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final t in Customizations.themes)
                  _ThemeTile(
                    variant: t,
                    selected: progress.themeId == t.id,
                    locked: _locked(t.requiredBadgeId, unlocked),
                    onTap: () => progress.setThemeId(t.id),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _sectionTitle(context, '🦄 Maskot'),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final m in Customizations.mascots)
                  _MascotTile(
                    costume: m,
                    selected: progress.mascotId == m.id,
                    locked: _locked(m.requiredBadgeId, unlocked),
                    onTap: () => progress.setMascotId(m.id),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Kilitli olanlar başarı rozetleriyle açılır. 🏆',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static bool _locked(String? badgeId, Set<String> unlocked) =>
      badgeId != null && !unlocked.contains(badgeId);

  Widget _sectionTitle(BuildContext context, String text) =>
      Text(text, style: Theme.of(context).textTheme.titleLarge);
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.variant,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final ThemeVariant variant;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Tile(
      selected: selected,
      locked: locked,
      label: variant.title,
      requiredBadge: variant.requiredBadgeId,
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [variant.gameSurface, variant.primary],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: Text(variant.emoji, style: const TextStyle(fontSize: 30)),
      ),
    );
  }
}

class _MascotTile extends StatelessWidget {
  const _MascotTile({
    required this.costume,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final MascotCostume costume;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Tile(
      selected: selected,
      locked: locked,
      label: costume.title,
      requiredBadge: costume.requiredBadgeId,
      onTap: onTap,
      child: Mascot(size: 72, costume: costume),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.child,
    required this.selected,
    required this.locked,
    required this.label,
    required this.requiredBadge,
    required this.onTap,
  });

  final Widget child;
  final bool selected;
  final bool locked;
  final String label;
  final String? requiredBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = NotaOyunColors.of(context);
    return GestureDetector(
      onTap: locked ? () => _showLocked(context) : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: selected ? colors.gold : Colors.transparent,
                width: 3,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(opacity: locked ? 0.35 : 1, child: child),
                if (locked)
                  const Icon(Icons.lock_rounded, color: Colors.white, size: 28),
                if (selected && !locked)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(Icons.check_circle_rounded,
                        color: colors.success, size: 22),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  void _showLocked(BuildContext context) {
    final badge = requiredBadge == null ? null : Badges.byId(requiredBadge!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(badge == null
            ? 'Bu seçenek kilitli.'
            : '🔒 "${badge.title}" rozetini kazanınca açılır.'),
      ),
    );
  }
}
