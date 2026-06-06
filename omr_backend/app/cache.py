"""Dosya bazlı hash cache.

Aynı görsel için OMR'yi tekrar çalıştırmamak adına; sonucu içeriğin
SHA-256'sıyla anahtarlar.
"""

from __future__ import annotations

import hashlib
import json
import os
from typing import Any

CACHE_DIR = os.environ.get("OMR_CACHE_DIR", "/tmp/omr_cache")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _path(key: str) -> str:
    os.makedirs(CACHE_DIR, exist_ok=True)
    return os.path.join(CACHE_DIR, f"{key}.json")


def get(key: str) -> dict[str, Any] | None:
    path = _path(key)
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    return None


def put(key: str, value: dict[str, Any]) -> None:
    with open(_path(key), "w", encoding="utf-8") as f:
        json.dump(value, f, ensure_ascii=False)
