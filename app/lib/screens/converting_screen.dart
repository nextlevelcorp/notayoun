import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../services/app_config.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';
import '../widgets/mascot.dart';
import 'correction_screen.dart';

/// (3) Dönüştürülüyor ekranı — maskot + ilerleme.
///
/// OMR servisini (mock veya remote) çağırır, sonucu cihazda kalıcı saklar
/// ([SongRepository.addSong]) ve oyun ekranına geçer.
class ConvertingScreen extends StatefulWidget {
  const ConvertingScreen({super.key, required this.sourcePath});

  final String sourcePath;

  @override
  State<ConvertingScreen> createState() => _ConvertingScreenState();
}

class _ConvertingScreenState extends State<ConvertingScreen> {
  String _status = 'Nota kâğıdı okunuyor…';
  String? _error;

  @override
  void initState() {
    super.initState();
    _convert();
  }

  Future<void> _convert() async {
    try {
      final omr = AppConfig.buildOmrService();
      if (mounted) {
        setState(() => _status = AppConfig.hasRemoteOmr
            ? 'Notalar tanınıyor… (ilk seferde biraz sürebilir)'
            : 'Örnek şarkı hazırlanıyor…');
      }
      final Song song = await omr.convert(widget.sourcePath);

      if (!mounted) return;
      // Freemium sayacı: başarılı dönüştürmeyi kaydet.
      await context.read<ProgressService>().recordConversion();

      if (!mounted) return;
      // Kaydetme, düzeltme ekranında onaylanınca yapılır.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => CorrectionScreen(song: song)),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Dönüştürme başarısız oldu:\n$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = NotaOyunColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: _error == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Mascot(size: 130, mood: MascotMood.think),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: 180,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            backgroundColor: colors.primaryDim,
                            valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: AppSpacing.base),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Geri Dön'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
