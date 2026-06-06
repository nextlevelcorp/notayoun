import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../theme/dimens.dart';
import '../widgets/parental_gate.dart';

/// Ayarlar ekranı. Yetişkin işlemleri (ör. "uygulamayı değerlendir" gibi dış
/// bağlantılar) ebeveyn kapısı arkasındadır.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _parentArea(BuildContext context) async {
    final ok = await showParentalGate(context);
    if (!ok || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ebeveyn alanı (taslak)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: SafeArea(
        child: ListView(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.volume_up_rounded),
              title: const Text('Ses'),
              subtitle: const Text('Nota seslerini çal'),
              value: progress.soundEnabled,
              onChanged: (v) => progress.setSoundEnabled(v),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.auto_graph_rounded),
              title: const Text('Bu ay kalan ücretsiz dönüştürme'),
              trailing: Text('${progress.remainingFreeConversions}',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.family_restroom_rounded),
              title: const Text('Ebeveyn Alanı'),
              subtitle: const Text('Yetişkin onayı gerektirir'),
              trailing: const Icon(Icons.lock_outline_rounded),
              onTap: () => _parentArea(context),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.base),
              child: _SafetyNote(),
            ),
            const AboutListTile(
              icon: Icon(Icons.info_outline_rounded),
              applicationName: 'NotaOyun',
              applicationVersion: '0.1.0',
              child: Text('Hakkında'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Text('🛡️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Çocuk güvenliği: Reklam yok, izleme yok. Hiçbir kişisel veri '
              'toplanmaz veya gönderilmez. Çalma tamamen çevrimdışıdır.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
