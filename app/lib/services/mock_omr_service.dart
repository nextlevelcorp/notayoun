import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/song.dart';
import 'omr_service.dart';

/// Projeyle gelen hazır JSON'ları döndüren offline OMR uyarlaması.
/// Geliştirme/test ve "fotoğraf yokken oynanabilir demo" için kullanılır.
class MockOmrService implements OmrService {
  static const String _basePath = 'assets/songs';

  /// `assets/songs/manifest.json` içindeki tüm gömülü şarkıları yükler.
  Future<List<Song>> loadBundledSongs() async {
    final manifestStr = await rootBundle.loadString('$_basePath/manifest.json');
    final manifest = jsonDecode(manifestStr) as Map<String, dynamic>;
    final files = (manifest['songs'] as List<dynamic>).cast<String>();

    final songs = <Song>[];
    for (final file in files) {
      final raw = await rootBundle.loadString('$_basePath/$file');
      songs.add(Song.fromJsonString(raw));
    }
    return songs;
  }

  /// Mock modda "dönüştürme" sadece ilk gömülü şarkıyı döndürür (simülasyon).
  @override
  Future<Song> convert(String filePath) async {
    // Gerçekçi bir "dönüştürülüyor" hissi için kısa gecikme.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final songs = await loadBundledSongs();
    return songs.first;
  }
}
