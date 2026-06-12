import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note_naming.dart';
import '../services/progress_service.dart';
import '../theme/dimens.dart';
import '../widgets/parental_gate.dart';
import 'customization_screen.dart';

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
            _sectionHeader(context, 'Oynanış'),
            SwitchListTile(
              secondary: const Icon(Icons.pan_tool_rounded),
              title: const Text('Bekleme modu'),
              subtitle: const Text(
                  'Doğru nota çalınana kadar bekle (öğretici). Kapalıyken akıcı çalar.'),
              value: progress.waitMode,
              onChanged: progress.setWaitMode,
            ),
            ListTile(
              leading: const Icon(Icons.abc_rounded),
              title: const Text('Nota adı gösterimi'),
              subtitle: Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final s in NoteNameStyle.values)
                    ChoiceChip(
                      label: Text(s.label),
                      selected: progress.noteNameStyle == s,
                      onSelected: (_) => progress.setNoteNameStyle(s),
                    ),
                ],
              ),
            ),
            if (!kIsWeb)
              SwitchListTile(
                secondary: const Icon(Icons.mic_rounded),
                title: const Text('Mikrofonla dinle'),
                subtitle: const Text(
                    'Gerçek piyano sesini dinleyip yönlendirir (mobil).'),
                value: progress.micEnabled,
                onChanged: progress.setMicEnabled,
              ),
            const Divider(),
            _sectionHeader(context, 'Ses & Geri Bildirim'),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up_rounded),
              title: const Text('Ses'),
              subtitle: const Text('Nota seslerini çal'),
              value: progress.soundEnabled,
              onChanged: progress.setSoundEnabled,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.av_timer_rounded),
              title: const Text('Metronom'),
              subtitle: const Text('Her vuruşta tık sesi'),
              value: progress.metronomeEnabled,
              onChanged: progress.setMetronomeEnabled,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.timer_3_select_rounded),
              title: const Text('Başlangıç sayımı'),
              subtitle: const Text('Çalmadan önce 3·2·1 geri sayım'),
              value: progress.countInEnabled,
              onChanged: progress.setCountInEnabled,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.vibration_rounded),
              title: const Text('Titreşim (haptik)'),
              subtitle: const Text('Doğru/yanlış çalışta hafif titreşim'),
              value: progress.hapticsEnabled,
              onChanged: progress.setHapticsEnabled,
            ),
            const Divider(),
            _sectionHeader(context, 'Görünüm'),
            ListTile(
              leading: const Icon(Icons.palette_rounded),
              title: const Text('Kişiselleştir'),
              subtitle: const Text('Renk teması ve maskot'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const CustomizationScreen()),
              ),
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

  Widget _sectionHeader(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.base, AppSpacing.md, AppSpacing.base, AppSpacing.xs),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
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
              'toplanmaz veya gönderilmez. Mikrofon yalnızca cihazda nota '
              'algılamak için kullanılır; ses kaydedilmez veya gönderilmez.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
