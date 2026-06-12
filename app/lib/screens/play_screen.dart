import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/note_naming.dart';
import '../models/song.dart';
import '../services/audio_service.dart';
import '../services/pitch/pitch_service.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/dimens.dart';
import '../widgets/falling_notes_painter.dart';
import '../widgets/piano_keyboard.dart';
import 'play_controller.dart';
import 'reward_screen.dart';

/// (4) Birlikte çal ekranı — düşen notalar + ses + tempo + A-B loop +
/// bekleme modu + mikrofon/ekran-piyanosu girişi + yatay düzen.
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
  late final PitchService _pitch;

  Duration _lastElapsed = Duration.zero;
  bool _navigatedToReward = false;

  // Canlı ayar kopyaları (build'de güncellenir).
  bool _haptics = true;
  NoteNameStyle _nameStyle = NoteNameStyle.solfej;

  bool _micOn = false;
  bool _micBusy = false;
  int? _countdown; // null = sayım yok

  @override
  void initState() {
    super.initState();
    final audio = context.read<AudioService>();
    final progress = context.read<ProgressService>();

    _controller = PlayController(
      song: widget.song,
      audio: audio,
      waitMode: progress.waitMode,
      metronomeEnabled: progress.metronomeEnabled,
    )
      ..onCorrectHit = _onCorrectHit
      ..onWrongHit = _onWrongHit
      ..addListener(_onControllerChanged);

    _lanes = widget.song.notes.map((n) => n.midi).toSet().toList()..sort();

    _pitch = createPitchService();
    if (_pitch.isSupported && progress.micEnabled) {
      // İlk karede izin iste ve başlat.
      WidgetsBinding.instance.addPostFrameCallback((_) => _startMic());
    }

    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    _controller.onTick(delta);
  }

  void _onCorrectHit() {
    if (_haptics) HapticFeedback.lightImpact();
  }

  void _onWrongHit() {
    if (_haptics) HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _controller.clearWrong();
    });
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

  // --- Mikrofon ---
  Future<void> _startMic() async {
    if (_micBusy || _micOn) return;
    setState(() => _micBusy = true);
    final ok = await _pitch.start(
      (midi) => _controller.notePlayed(midi, playSound: false),
    );
    if (!mounted) return;
    setState(() {
      _micOn = ok;
      _micBusy = false;
    });
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mikrofon izni gerekli ya da kullanılamıyor.')),
      );
    }
  }

  Future<void> _stopMic() async {
    await _pitch.stop();
    if (mounted) setState(() => _micOn = false);
  }

  Future<void> _toggleMic() => _micOn ? _stopMic() : _startMic();

  // --- Sayım + oynat ---
  Future<void> _togglePlay() async {
    if (_controller.isPlaying) {
      _controller.pause();
      return;
    }
    final progress = context.read<ProgressService>();
    if (progress.countInEnabled && _countdown == null) {
      await _runCountIn();
      if (!mounted) return;
    }
    _controller.play();
  }

  Future<void> _runCountIn() async {
    final audio = context.read<AudioService>();
    for (var n = 3; n >= 1; n--) {
      if (!mounted) return;
      setState(() => _countdown = n);
      audio.playTick(strong: n == 3);
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
    if (mounted) setState(() => _countdown = null);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _pitch.dispose();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  int _laneOf(int midi) => _lanes.indexOf(midi);

  @override
  Widget build(BuildContext context) {
    final colors = NotaOyunColors.of(context);
    final progress = context.watch<ProgressService>();

    // Ayarları canlı uygula.
    _haptics = progress.hapticsEnabled;
    _nameStyle = progress.noteNameStyle;
    _controller
      ..waitMode = progress.waitMode
      ..metronomeEnabled = progress.metronomeEnabled;

    return Scaffold(
      backgroundColor: colors.gameBg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                OrientationBuilder(
                  builder: (context, orientation) =>
                      orientation == Orientation.landscape
                          ? _landscape(context, colors)
                          : _portrait(context, colors),
                ),
                if (_countdown != null) _countdownOverlay(context),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Düzenler ---
  Widget _portrait(BuildContext context, NotaOyunColors colors) {
    return Column(
      children: [
        _topBar(context, colors),
        Expanded(child: _fallingArea(colors)),
        const SizedBox(height: AppSpacing.sm),
        _keyboard(),
        _controls(context, colors),
      ],
    );
  }

  Widget _landscape(BuildContext context, NotaOyunColors colors) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _topBar(context, colors, compact: true),
              Expanded(child: _fallingArea(colors)),
              const SizedBox(height: AppSpacing.xs),
              _keyboard(height: 80),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        ),
        SizedBox(
          width: 188,
          child: SingleChildScrollView(
            child: _controls(context, colors),
          ),
        ),
      ],
    );
  }

  Widget _fallingArea(NotaOyunColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
              nameStyle: _nameStyle,
              waiting: _controller.waiting,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  Widget _keyboard({double height = 96}) {
    return PianoKeyboard(
      lanes: _lanes,
      activeMidis: _controller.activeMidis,
      expectedMidis: _controller.expectedMidis,
      wrongMidi: _controller.lastWrongMidi,
      nameStyle: _nameStyle,
      height: height,
      onTap: (midi) => _controller.notePlayed(midi),
    );
  }

  Widget _topBar(BuildContext context, NotaOyunColors colors,
      {bool compact = false}) {
    final progress = context.read<ProgressService>();
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
                if (!compact)
                  Text(
                    widget.song.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (!compact) const SizedBox(height: AppSpacing.xs),
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
          const SizedBox(width: AppSpacing.xs),
          // Nota adı gösterimini döngüle.
          _iconToggle(
            icon: Icons.abc_rounded,
            on: _nameStyle != NoteNameStyle.none,
            tooltip: 'Nota adı: ${_nameStyle.label}',
            color: colors.gold,
            onTap: () => progress.setNoteNameStyle(_nextNameStyle(_nameStyle)),
          ),
          // Bekleme modu.
          _iconToggle(
            icon: Icons.pan_tool_rounded,
            on: progress.waitMode,
            tooltip: progress.waitMode ? 'Bekleme modu açık' : 'Bekleme modu kapalı',
            color: colors.gold,
            onTap: () => progress.setWaitMode(!progress.waitMode),
          ),
          // Mikrofon (destekleniyorsa).
          if (_pitch.isSupported)
            _iconToggle(
              icon: _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
              on: _micOn,
              tooltip: _micOn ? 'Mikrofon açık' : 'Mikrofonla dinle',
              color: colors.success,
              onTap: _micBusy ? null : _toggleMic,
            ),
          IconButton(
            onPressed: _controller.restart,
            icon: const Icon(Icons.replay_rounded, color: Colors.white),
            tooltip: 'Baştan',
          ),
        ],
      ),
    );
  }

  Widget _iconToggle({
    required IconData icon,
    required bool on,
    required String tooltip,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, color: on ? color : Colors.white54),
    );
  }

  Widget _controls(BuildContext context, NotaOyunColors colors) {
    final loopActive = _controller.hasLoop;
    final tempo = Row(
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
    );

    final transport = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    );

    final loopHint = loopActive
        ? TextButton.icon(
            onPressed: _controller.clearLoop,
            icon: const Icon(Icons.loop_rounded, size: 18),
            label: const Text('A-B Loop açık · temizle'),
            style: TextButton.styleFrom(foregroundColor: colors.gold),
          )
        : const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        AppSpacing.base,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tempo,
          const SizedBox(height: AppSpacing.sm),
          transport,
          loopHint,
        ],
      ),
    );
  }

  Widget _playButton(BuildContext context) {
    final playing = _controller.isPlaying;
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: _togglePlay,
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

  Widget _countdownOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        alignment: Alignment.center,
        child: TweenAnimationBuilder<double>(
          key: ValueKey(_countdown),
          tween: Tween(begin: 0.6, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Text(
            '${_countdown ?? ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 120,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  static NoteNameStyle _nextNameStyle(NoteNameStyle s) {
    switch (s) {
      case NoteNameStyle.none:
        return NoteNameStyle.solfej;
      case NoteNameStyle.solfej:
        return NoteNameStyle.letter;
      case NoteNameStyle.letter:
        return NoteNameStyle.none;
    }
  }
}
