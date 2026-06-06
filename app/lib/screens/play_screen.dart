import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';
import '../widgets/falling_notes_painter.dart';
import '../widgets/piano_keyboard.dart';
import 'play_controller.dart';
import 'reward_screen.dart';

/// (4) Birlikte çal ekranı — düşen notalar + ses + tempo + A-B loop.
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.song});

  final Song song;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen>
    with SingleTickerProviderStateMixin {
  late final PlayController _controller;
  late final Ticker _ticker;
  late final List<int> _lanes;
  Duration _lastElapsed = Duration.zero;
  bool _navigatedToReward = false;

  @override
  void initState() {
    super.initState();
    final audio = context.read<AudioService>();
    _controller = PlayController(song: widget.song, audio: audio)
      ..addListener(_onControllerChanged);

    // Şeritler: parçadaki farklı MIDI değerleri (artan).
    _lanes = widget.song.notes.map((n) => n.midi).toSet().toList()..sort();

    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    _controller.onTick(delta);
  }

  void _onControllerChanged() {
    if (_controller.finished && !_navigatedToReward) {
      _navigatedToReward = true;
      _ticker.stop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => RewardScreen(song: widget.song),
        ),
      );
    }
  }

  int _laneOf(int midi) => _lanes.indexOf(midi);

  @override
  void dispose() {
    _ticker.dispose();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = NotaOyunColors.of(context);

    return Scaffold(
      backgroundColor: colors.gameBg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              children: [
                _topBar(context, colors),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Container(
                        color: colors.gameSurface,
                        child: CustomPaint(
                          painter: FallingNotesPainter(
                            notes: _controller.visibleNotes,
                            currentBeat: _controller.currentBeat,
                            lookAheadBeats: PlayController.lookAheadBeats,
                            laneOf: _laneOf,
                            laneCount: _lanes.length,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                PianoKeyboard(
                  lanes: _lanes,
                  activeMidis: _controller.activeMidis,
                  onTap: (midi) => _controller.audio.playNote(midi),
                ),
                _controls(context, colors),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, NotaOyunColors colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            tooltip: 'Kapat',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.song.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: _controller.progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(colors.gold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: _controller.restart,
            icon: const Icon(Icons.replay_rounded, color: Colors.white),
            tooltip: 'Baştan',
          ),
        ],
      ),
    );
  }

  Widget _controls(BuildContext context, NotaOyunColors colors) {
    final loopActive = _controller.hasLoop;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        AppSpacing.base,
      ),
      child: Column(
        children: [
          // Tempo
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: Colors.white70, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${(_controller.tempoMultiplier * 100).round()}%',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              Expanded(
                child: Slider(
                  min: 0.4,
                  max: 1.0,
                  divisions: 6,
                  value: _controller.tempoMultiplier,
                  activeColor: colors.gold,
                  onChanged: (v) => _controller.tempoMultiplier = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _loopButton(
                label: 'A',
                color: Theme.of(context).colorScheme.secondary,
                onTap: _controller.setLoopA,
                marked: _controller.loopA != null,
              ),
              _playButton(context),
              _loopButton(
                label: 'B',
                color: Theme.of(context).colorScheme.tertiary,
                onTap: _controller.setLoopB,
                marked: _controller.loopB != null,
              ),
            ],
          ),
          if (loopActive)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: TextButton.icon(
                onPressed: _controller.clearLoop,
                icon: const Icon(Icons.loop_rounded, size: 18),
                label: const Text('A-B Loop açık · temizle'),
                style: TextButton.styleFrom(foregroundColor: colors.gold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _playButton(BuildContext context) {
    final playing = _controller.isPlaying;
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: _controller.togglePlay,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: AppShadow.button(color),
        ),
        child: Icon(
          playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _loopButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool marked,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppA11y.minTouchTarget,
        height: AppA11y.minTouchTarget,
        decoration: BoxDecoration(
          color: marked ? color : color.withValues(alpha: 0.25),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
