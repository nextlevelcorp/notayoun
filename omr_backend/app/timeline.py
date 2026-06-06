"""MusicXML -> basit JSON "note timeline" dönüşümü (music21 ile)."""

from __future__ import annotations

from typing import Any

from music21 import converter, note, tempo, meter, stream

# Sabit-do solfej adları (Türkçe), pitch-class tabanlı.
_SOLFEGE = ["Do", "Do#", "Re", "Re#", "Mi", "Fa", "Fa#", "Sol", "Sol#", "La", "La#", "Si"]


def _solfege(midi: int) -> str:
    return _SOLFEGE[midi % 12]


def musicxml_to_timeline(musicxml_path: str, title: str | None = None) -> dict[str, Any]:
    """Bir MusicXML dosyasını JSON timeline sözlüğüne çevirir."""
    score = converter.parse(musicxml_path)
    return score_to_timeline(score, title=title)


def score_to_timeline(score: stream.Score, title: str | None = None) -> dict[str, Any]:
    # Tempo
    tempo_bpm = 90
    mm = score.recurse().getElementsByClass(tempo.MetronomeMark)
    for m in mm:
        if m.number:
            tempo_bpm = int(round(m.number))
            break

    # Ölçü vuruşu (time signature)
    beats_per_measure = 4
    ts = score.recurse().getElementsByClass(meter.TimeSignature)
    for t in ts:
        beats_per_measure = t.numerator
        break

    # Başlık
    if not title:
        md = score.metadata
        title = (md.title if md and md.title else None) or "Adsız Parça"

    notes: list[dict[str, Any]] = []
    # Her partı (el) ayrı işle. Birden fazla part varsa ikincisi "left".
    parts = list(score.parts) if score.parts else [score]
    for idx, part in enumerate(parts):
        hand = "left" if idx == 1 and len(parts) > 1 else "right"
        flat = part.flatten()
        for n in flat.notes:
            # Akor ise en üst notayı al (tek hatlı oyun için sadeleştirme).
            pitches = n.pitches if hasattr(n, "pitches") else [n.pitch]
            top = max(pitches, key=lambda p: p.midi)
            midi = int(top.midi)
            notes.append(
                {
                    "midi": midi,
                    "name": _solfege(midi),
                    "startBeat": round(float(n.offset), 3),
                    "durationBeats": round(float(n.duration.quarterLength), 3),
                    "hand": hand,
                }
            )

    notes.sort(key=lambda x: (x["startBeat"], x["midi"]))

    return {
        "title": title,
        "tempoBpm": tempo_bpm,
        "beatsPerMeasure": beats_per_measure,
        "notes": notes,
    }
