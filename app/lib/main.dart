import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/library_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/audio_service.dart';
import 'services/progress_service.dart';
import 'services/song_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final progress = ProgressService(prefs);
  final audio = AudioService()..enabled = progress.soundEnabled;
  final repo = SongRepository();

  // Ses aç/kapa ayarını canlı uygula.
  progress.addListener(() => audio.enabled = progress.soundEnabled);

  // Ses örneklerini ve şarkı kütüphanesini paralel yükle.
  await Future.wait([
    audio.init(),
    repo.load(),
  ]);

  runApp(NotaOyunApp(audio: audio, repository: repo, progress: progress));
}

class NotaOyunApp extends StatelessWidget {
  const NotaOyunApp({
    super.key,
    required this.audio,
    required this.repository,
    required this.progress,
  });

  final AudioService audio;
  final SongRepository repository;
  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(value: repository),
        ChangeNotifierProvider<ProgressService>.value(value: progress),
        Provider<AudioService>.value(value: audio),
      ],
      child: MaterialApp(
        title: 'NotaOyun',
        debugShowCheckedModeBanner: false,
        theme: buildNotaOyunTheme(),
        home: progress.seenOnboarding
            ? const LibraryScreen()
            : const OnboardingScreen(),
      ),
    );
  }
}
