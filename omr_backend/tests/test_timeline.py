"""music21 -> timeline dönüşüm testi. music21 yoksa atlanır."""

import pytest

music21 = pytest.importorskip("music21")

from app.timeline import score_to_timeline  # noqa: E402


def test_score_to_timeline_basic():
    from music21 import stream, note, tempo, meter

    s = stream.Score()
    p = stream.Part()
    p.append(tempo.MetronomeMark(number=90))
    p.append(meter.TimeSignature("4/4"))
    p.append(note.Note("C4", quarterLength=1.0))  # Do, midi 60
    p.append(note.Note("D4", quarterLength=2.0))  # Re, midi 62
    s.append(p)

    tl = score_to_timeline(s, title="Test")

    assert tl["title"] == "Test"
    assert tl["tempoBpm"] == 90
    assert tl["beatsPerMeasure"] == 4
    assert len(tl["notes"]) == 2

    first = tl["notes"][0]
    assert first["midi"] == 60
    assert first["name"] == "Do"
    assert first["startBeat"] == 0.0
    assert first["durationBeats"] == 1.0
    assert first["hand"] == "right"

    second = tl["notes"][1]
    assert second["midi"] == 62
    assert second["name"] == "Re"
    assert second["startBeat"] == 1.0
