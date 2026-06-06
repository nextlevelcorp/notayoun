import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';
import '../widgets/mascot.dart';
import '../widgets/parental_gate.dart';

/// Freemium kapısı taslağı. Gerçek satın alma YOK; yalnızca akış iskeleti.
/// Satın alma adımı **ebeveyn kapısı** arkasındadır (çocuk güvenliği).
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  Future<void> _onPurchase(BuildContext context) async {
    final ok = await showParentalGate(context);
    if (!ok || !context.mounted) return;
    // TODO(Faz 4): gerçek in-app purchase entegrasyonu.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium yakında! (taslak)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = NotaOyunColors.of(context);
    final progress = context.watch<ProgressService>();

    return Scaffold(
      appBar: AppBar(title: const Text('NotaOyun Premium')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Center(child: Mascot(size: 120, mood: MascotMood.happy)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Bu ay ${ProgressService.freeConversionsPerMonth} ücretsiz '
              'dönüştürme hakkını kullandın.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Kalan: ${progress.remainingFreeConversions}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            _feature(context, colors, '🎵', 'Sınırsız nota dönüştürme'),
            _feature(context, colors, '🎼', 'Tüm şarkılar çevrimdışı'),
            _feature(context, colors, '🚫', 'Reklam yok — hiç olmadı'),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => _onPurchase(context),
              child: const Text('Premium\'a Geç (Ebeveyn Onayı)'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Belki Sonra'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feature(
      BuildContext context, NotaOyunColors colors, String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.secondaryDim,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
