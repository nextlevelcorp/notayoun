import os
import tempfile

from app import cache


def test_sha256_stable():
    assert cache.sha256_bytes(b"abc") == cache.sha256_bytes(b"abc")
    assert cache.sha256_bytes(b"abc") != cache.sha256_bytes(b"abd")


def test_put_get_roundtrip(monkeypatch):
    with tempfile.TemporaryDirectory() as d:
        monkeypatch.setattr(cache, "CACHE_DIR", d)
        key = cache.sha256_bytes(b"song-bytes")
        assert cache.get(key) is None
        cache.put(key, {"title": "Test", "notes": []})
        got = cache.get(key)
        assert got is not None
        assert got["title"] == "Test"
        assert os.path.exists(os.path.join(d, f"{key}.json"))
