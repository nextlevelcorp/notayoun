import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/library_screen.dart';
import 'services/audio_service.dart';
import 'services/song_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audio = AudioService();
  final repo = SongRepository();

  // Ses örneklerini ve şarkı kütüphanesini paralel yükle.
  await Future.wait([
    audio.init(),
    repo.load(),
  ]);

  runApp(NotaOyunApp(audio: audio, repository: repo));
}

class NotaOyunApp extends StatelessWidget {
  const NotaOyunApp({
    super.key,
    required this.audio,
    required this.repository,
  });

  final AudioService audio;
  final SongRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SongRepository>.value(value: repository),
        Provider<AudioService>.value(value: audio),
      ],
      child: MaterialApp(
        title: 'NotaOyun',
        debugShowCheckedModeBanner: false,
        theme: buildNotaOyunTheme(),
        home: const LibraryScreen(),
      ),
    );
  }
}
