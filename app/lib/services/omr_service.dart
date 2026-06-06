import '../models/song.dart';

/// Görsel/PDF kaynağından bir [Song] (note timeline) üreten servis arayüzü (port).
///
/// İki uyarlama vardır:
/// * [MockOmrService]  — projeyle gelen hazır JSON'u döner (offline geliştirme).
/// * [RemoteOmrService] — `/omr_backend`'e HTTP ile bağlanır.
///
/// OMR **parça başına yalnızca BİR KEZ** çalıştırılmalı; sonuç cihazda
/// önbelleğe alınır (bkz. [SongRepository]).
abstract class OmrService {
  /// Bir dosyadan (görsel/PDF) parça çıkarır.
  Future<Song> convert(String filePath);
}
