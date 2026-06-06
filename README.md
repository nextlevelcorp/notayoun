# NotaOyun 🎵

4–9 yaş çocuklar için bir **mobil müzik oyunu**. Öğretmenin verdiği nota kâğıdının
fotoğrafını/PDF'ini alıp **"düşen notalı" bir birlikte-çal oyununa** çevirir.
iOS + Android, tek kod tabanı (Flutter).

> Nota tanıma (OMR) **parça başına yalnızca BİR KEZ** çalışır; sonuç cihazda
> önbelleğe alınır. Çalma ve oyun **tamamen cihazda / çevrimdışı** çalışır.

## Monorepo yapısı

```
/app           → Flutter uygulaması (asıl ürün)
/omr_backend   → Python (FastAPI) — nota görselini JSON nota-zaman çizelgesine çevirir (Faz 2)
```

## Veri akışı

1. Uygulama, nota görselini/PDF'ini `/omr_backend`'e gönderir.
2. Backend açık kaynak OMR (oemer/homr) ile MusicXML üretir.
3. `music21` ile parse edip **basit JSON "note timeline"**e çevirir.
4. Uygulama bu JSON'u cihazda saklar; düşen-nota oyununu ve sesi tamamen yerelde çalar.

OMR bir arayüz (`OmrService`) arkasındadır:
- `MockOmrService` → projeyle gelen hazır JSON'u döner (offline geliştirme/test).
- `RemoteOmrService` → `/omr_backend`'e HTTP ile bağlanır.

> Lisans notu: **Audiveris AGPLv3** olduğundan kapalı kaynakta kullanılmaz; daha
> izin verici **oemer/homr** motorları tercih edilir.

## Geliştirme

Bu sandbox'ta Flutter derlemesi yapılmaz; **derlemenin doğruluk kaynağı Codemagic**'tir.

```bash
cd app
flutter pub get
flutter analyze
flutter run        # bir cihaz/emülatör bağlıyken
flutter test
```

### Backend URL'i ayarlama

Uygulama, OMR backend URL'ini bir derleme zamanı ortam değişkeninden okur:

```bash
flutter run --dart-define=OMR_BASE_URL=https://notaoyun-omr.onrender.com
```

Tanımlı değilse uygulama otomatik olarak `MockOmrService`'e düşer (offline demo).

## CI / Derleme

- `codemagic.yaml` → Android APK + iOS IPA→TestFlight iş akışları (placeholder'larla).
- `.github/workflows/flutter_ci.yml` → `flutter analyze` + Android APK artifact.

## Fazlar

- [x] **Faz 0** — İskelet + tema + CI
- [x] **Faz 1** — Dikey dilim (mock veri ile oynanabilir demo)
- [x] **Faz 2** — İçe aktarma + gerçek OMR backend + yerel cache + düzeltme ekranı
- [ ] **Faz 3** — Oyunlaştırma + onboarding + freemium kapısı

Test ayrıntıları için bkz. [`TESTING.md`](TESTING.md).
