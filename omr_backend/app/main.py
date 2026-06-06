"""NotaOyun OMR backend — FastAPI uygulaması."""

from __future__ import annotations

import os
import tempfile
from pathlib import Path

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.responses import JSONResponse

from . import cache
from .omr import OmrError, image_to_musicxml
from .timeline import musicxml_to_timeline

app = FastAPI(title="NotaOyun OMR", version="0.1.0")

ALLOWED_EXT = {".png", ".jpg", ".jpeg", ".pdf"}


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/convert")
async def convert(file: UploadFile = File(...)) -> JSONResponse:
    ext = Path(file.filename or "").suffix.lower()
    if ext not in ALLOWED_EXT:
        raise HTTPException(
            status_code=400,
            detail=f"Desteklenmeyen dosya türü: {ext or 'bilinmiyor'}",
        )

    data = await file.read()
    if not data:
        raise HTTPException(status_code=400, detail="Boş dosya.")

    # Cache: aynı içerik daha önce dönüştürüldüyse tekrar çalıştırma.
    key = cache.sha256_bytes(data)
    cached = cache.get(key)
    if cached is not None:
        return JSONResponse(cached)

    # Geçici dosyaya yaz.
    with tempfile.NamedTemporaryFile(delete=False, suffix=ext) as tmp:
        tmp.write(data)
        tmp_path = tmp.name

    try:
        musicxml = image_to_musicxml(tmp_path)
        title = Path(file.filename or "").stem or "Yeni Parça"
        timeline = musicxml_to_timeline(musicxml, title=title)
    except OmrError as e:
        raise HTTPException(status_code=422, detail=str(e)) from e
    except Exception as e:  # beklenmeyen
        raise HTTPException(status_code=500, detail=f"İşleme hatası: {e}") from e
    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass

    cache.put(key, timeline)
    return JSONResponse(timeline)
