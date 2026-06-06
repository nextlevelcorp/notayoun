import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/app_config.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';
import '../widgets/mascot.dart';
import 'converting_screen.dart';

/// (2) İçe aktar ekranı — fotoğraf çek / galeriden seç / PDF seç.
///
/// Faz 1'de OMR backend tanımlı değilse [MockOmrService] kullanılır ve
/// gömülü bir şarkı döner (uçtan uca akışı denemek için).
class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 90);
    if (file != null && context.mounted) {
      _startConvert(context, file.path);
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );
    final path = result?.files.single.path;
    if (path != null && context.mounted) {
      _startConvert(context, path);
    }
  }

  void _startConvert(BuildContext context, String path) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ConvertingScreen(sourcePath: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = NotaOyunColors.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Nota Ekle')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.base),
          children: [
            const Center(child: Mascot(size: 110, mood: MascotMood.think)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Öğretmenin verdiği nota kâğıdını ekle',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Fotoğrafı bir kez dönüştürürüz, sonra hep hazır olur. 🎵',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            _OptionCard(
              icon: Icons.photo_camera_rounded,
              color: Theme.of(context).colorScheme.primary,
              title: 'Fotoğraf Çek',
              subtitle: 'Kamerayla nota kâğıdını çek',
              onTap: () => _pickImage(context, ImageSource.camera),
            ),
            const SizedBox(height: AppSpacing.md),
            _OptionCard(
              icon: Icons.photo_library_rounded,
              color: Theme.of(context).colorScheme.secondary,
              title: 'Galeriden Seç',
              subtitle: 'Kayıtlı bir fotoğraf seç',
              onTap: () => _pickImage(context, ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.md),
            _OptionCard(
              icon: Icons.picture_as_pdf_rounded,
              color: colors.gold,
              title: 'PDF Seç',
              subtitle: 'Bir PDF nota dosyası seç',
              onTap: () => _pickFile(context),
            ),
            if (!AppConfig.hasRemoteOmr) ...[
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.goldDim,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  'Demo modu: OMR backend ayarlı değil. Seçtiğin dosya örnek '
                  'bir şarkıya dönüştürülecek.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
