# NotaOyun — Test Rehberi

Bu sandbox'ta Flutter SDK kurulu değil; **derlemenin doğruluk kaynağı Codemagic /
GitHub Actions**'tır. Aşağıdaki adımlar bir cihaz veya CI üzerinde geçerlidir.

## Yerel (SDK kuruluysa)

```bash
cd app
flutter pub get
flutter analyze       # statik analiz temiz olmalı
flutter test          # birim testleri
flutter run           # bağlı cihaz/emülatörde çalıştır
```

## Faz 1 — Oynanabilir dikey dilim (mock veri) nasıl test edilir

1. Uygulamayı çalıştır (`flutter run`). OMR backend gerekmez; mock şarkılar gömülü.
2. **Kütüphane** ekranında "Küçük Yıldız" ve "Kardeş Çocuk Frère Jacques" gibi
   gömülü şarkıları görmelisin.
3. Bir şarkıya dokun → **Birlikte Çal** ekranı açılır.
4. ▶ **Başlat**'a bas: notalar yukarıdan iner, alttaki klavye şeridinde doğru tuş yanar
   ve nota sesi çalar.
5. **Tempo** kaydırıcısıyla yavaşlat/hızlandır (0.5x–1.0x).
6. **A-B Loop**: "A" ve "B" düğmeleriyle bir aralık seçip tekrar çaldır.
7. Şarkı bittiğinde **Ödül** ekranı (yıldızlar + maskot) açılır.

### Beklenenler
- Ses, notalar ekranın altındaki "vuruş çizgisine" değdiğinde tetiklenir.
- Tempo değişimi anında notaların düşme hızını etkiler.
- A-B loop seçili aralığı kesintisiz tekrarlar.

## Birim testleri

- `test/models_test.dart` — `Song`/`NoteEvent` JSON serileştirme round-trip testi.
- `test/mock_omr_service_test.dart` — gömülü şarkıların yüklenmesi.

## CI

- **GitHub Actions** (`.github/workflows/flutter_ci.yml`): `flutter analyze`,
  `flutter test` ve Android **APK artifact** üretir → Actions sekmesinden indirilir.
- **Codemagic** (`codemagic.yaml`): Android APK ve iOS IPA→TestFlight iş akışları.
  Gerçek cihaz testi için Codemagic build'i kullanılır.

## Faz 2 — İçe aktarma + OMR + cache nasıl test edilir

### Uygulama tarafı (demo / mock)
1. Kütüphane → **İçe Aktar** (FAB) → Fotoğraf/Galeri/PDF seç.
2. **Dönüştürülüyor** ekranı → **Notaları Kontrol Et** (düzeltme) ekranı açılır.
3. Bir notayı +/- ile yarım ses kaydır veya sil → **Onayla ve Çal**.
4. Şarkı kütüphaneye **kalıcı** eklenir (uygulamayı kapatıp açınca durur).

### Gerçek backend ile
```bash
flutter run --dart-define=OMR_BASE_URL=https://notaoyun-omr.onrender.com
```
URL tanımlıyken İçe Aktar gerçek OMR'yi çağırır; sonuç hem backend'de
(hash cache) hem cihazda saklanır, bir daha çağrılmaz.

## Backend (omr_backend)

```bash
cd omr_backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
# POST /convert (multipart, alan adı: "file") → JSON note timeline
curl -F "file=@ornek_nota.png" http://localhost:8000/convert
```

Hafif birim testleri (oemer gerekmez):
```bash
cd omr_backend
pip install fastapi "music21==9.1.*" pytest
pytest -q
```

> İlk gerçek `/convert` çağrısı oemer modellerini indirir → yavaş olabilir.

## Faz 3 — Oyunlaştırma / onboarding / freemium nasıl test edilir

1. **Onboarding**: İlk açılışta 3 sayfalık tanıtım gelir (uygulama verisini
   silersen tekrar görünür). "Başla" → Kütüphane.
2. **Streak & rozetler**: Bir şarkıyı bitir → Ödül ekranında konfeti, yıldız,
   "🔥 1 günlük seri" ve **İlk Şarkı** rozeti. Kütüphane başlığında seri çipi,
   sağ üstte 🏆 **Başarılar** ekranı.
3. **Ayarlar** (⚙): Ses aç/kapa anında etkili; "Ebeveyn Alanı" çarpma sorusu sorar.
4. **Freemium**: 1 ayda ${freeConversionsPerMonth} (varsayılan 5) dönüştürmeden
   sonra İçe Aktar **Paywall**'a yönlenir; "Premium'a Geç" ebeveyn kapısı ister.

Birim testi: `test/progress_service_test.dart` (streak, rozetler, aylık limit).
