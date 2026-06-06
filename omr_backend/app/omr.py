"""OMR pipeline: görsel/PDF -> MusicXML (oemer ile).

oemer bir CLI'dır: `oemer <image> -o <out_dir>` çalıştırılır ve `.musicxml`
üretir. PDF girişleri ilk sayfası PNG'ye çevrilerek işlenir.
"""

from __future__ import annotations

import os
import subprocess
import tempfile
from pathlib import Path


class OmrError(Exception):
    pass


def pdf_first_page_to_png(pdf_path: str, out_path: str, dpi: int = 200) -> str:
    """PDF'in ilk sayfasını PNG'ye çevirir (PyMuPDF)."""
    import fitz  # PyMuPDF

    doc = fitz.open(pdf_path)
    if doc.page_count == 0:
        raise OmrError("PDF boş.")
    page = doc.load_page(0)
    zoom = dpi / 72.0
    pix = page.get_pixmap(matrix=fitz.Matrix(zoom, zoom))
    pix.save(out_path)
    doc.close()
    return out_path


def _ensure_image(input_path: str, work_dir: str) -> str:
    """Girişi OMR'nin işleyebileceği bir görsele normalize eder."""
    ext = Path(input_path).suffix.lower()
    if ext == ".pdf":
        png = os.path.join(work_dir, "page.png")
        return pdf_first_page_to_png(input_path, png)
    return input_path


def image_to_musicxml(input_path: str) -> str:
    """Görsel/PDF'i MusicXML'e çevirir, üretilen dosyanın yolunu döner."""
    work_dir = tempfile.mkdtemp(prefix="omr_")
    image = _ensure_image(input_path, work_dir)

    try:
        # oemer çıktıyı çalışma dizinine <ad>.musicxml olarak yazar.
        subprocess.run(
            ["oemer", image, "-o", work_dir],
            check=True,
            capture_output=True,
            timeout=600,
        )
    except FileNotFoundError as e:  # oemer kurulu değil
        raise OmrError(
            "oemer bulunamadı. requirements.txt kurulu mu?"
        ) from e
    except subprocess.CalledProcessError as e:
        raise OmrError(
            f"OMR başarısız: {e.stderr.decode(errors='ignore')[:500]}"
        ) from e
    except subprocess.TimeoutExpired as e:
        raise OmrError("OMR zaman aşımına uğradı.") from e

    candidates = list(Path(work_dir).glob("*.musicxml")) + list(
        Path(work_dir).glob("*.xml")
    )
    if not candidates:
        raise OmrError("OMR çıktısı (MusicXML) bulunamadı.")
    return str(candidates[0])
