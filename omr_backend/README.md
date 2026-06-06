# NotaOyun OMR Backend

Bir nota görselini/PDF'ini **JSON "note timeline"**e çeviren küçük FastAPI servisi.

```
görsel/PDF  ──>  oemer (OMR)  ──>  MusicXML  ──>  music21  ──>  JSON timeline
```

> **OMR pahalıdır ve yalnızca parça başına BİR KEZ çalıştırılır.** Sonuç hem
> burada (dosya bazlı hash cache) hem de uygulamada cihazda saklanır.

> Lisans notu: **Audiveris AGPLv3** olduğundan kullanılmaz; daha izin verici
> **[oemer](https://github.com/BreezeWhite/oemer)** (MIT) tercih edilir.

## Uç noktalar

| Method | Yol         | Açıklama                                                        |
|--------|-------------|----------------------------------------------------------------|
| GET    | `/health`   | Sağlık kontrolü.                                               |
| POST   | `/convert`  | `multipart/form-data`, alan adı `file` (png/jpg/pdf) → timeline |

### Örnek

```bash
curl -F "file=@ornek_nota.png" http://localhost:8000/convert
```

Yanıt:

```json
{
  "title": "Küçük Yıldız",
  "tempoBpm": 90,
  "beatsPerMeasure": 4,
  "notes": [
    {"midi": 60, "name": "Do", "startBeat": 0.0, "durationBeats": 1.0, "hand": "right"}
  ]
}
```

## Yerel çalıştırma

```bash
cd omr_backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

> İlk `/convert` çağrısında oemer model dosyalarını indirir; bu yüzden ilk
> dönüştürme yavaş olabilir (birkaç dakika). Sonraki çağrılar hızlıdır.

## Docker

```bash
docker build -t notaoyun-omr ./omr_backend
docker run -p 8000:8000 notaoyun-omr
```

## Render'a deploy

Repo kökündeki `render.yaml` algılanır; `omr_backend/Dockerfile` ile bir web
servisi olarak deploy edilir. Her push'ta otomatik yeniden deploy.

Uygulama tarafında URL'i ver:

```bash
flutter run --dart-define=OMR_BASE_URL=https://notaoyun-omr.onrender.com
```
