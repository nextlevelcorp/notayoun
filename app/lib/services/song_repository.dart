import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/song.dart';
import 'mock_omr_service.dart';

/// Şarkıların kaynağı: gömülü (asset) şarkılar + kullanıcının içe aktarıp
/// dönüştürdüğü (cache'lenmiş) şarkılar.
///
/// OMR çıktısı **bir kez** üretilir ve burada kalıcı saklanır; bir daha
/// backend çağrılmaz.
class SongRepository extends ChangeNotifier {
  SongRepository({MockOmrService? mock})
      : _mock = mock ?? MockOmrService();

  final MockOmrService _mock;

  final List<Song> _songs = [];
  List<Song> get songs => List.unmodifiable(_songs);

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Gömülü + cache'lenmiş şarkıları yükler.
  Future<void> load() async {
    _songs
      ..clear()
      ..addAll(await _mock.loadBundledSongs())
      ..addAll(await _loadCachedSongs());
    _loaded = true;
    notifyListeners();
  }

  /// Dönüştürülmüş bir şarkıyı kalıcı olarak ekler (cache + bellek).
  Future<void> addSong(Song song) async {
    await _writeCachedSong(song);
    _songs.removeWhere((s) => s.id == song.id);
    _songs.add(song);
    notifyListeners();
  }

  Song? byId(String id) {
    for (final s in _songs) {
      if (s.id == id) return s;
    }
    return null;
  }

  // --- Yerel cache (path_provider) ---

  Future<Directory> _cacheDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final songsDir = Directory('${dir.path}/songs');
    if (!await songsDir.exists()) {
      await songsDir.create(recursive: true);
    }
    return songsDir;
  }

  Future<List<Song>> _loadCachedSongs() async {
    try {
      final dir = await _cacheDir();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'));
      final out = <Song>[];
      for (final f in files) {
        out.add(Song.fromJsonString(await f.readAsString()));
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeCachedSong(Song song) async {
    final dir = await _cacheDir();
    final file = File('${dir.path}/${song.id}.json');
    await file.writeAsString(jsonEncode(song.toJson()));
  }
}
