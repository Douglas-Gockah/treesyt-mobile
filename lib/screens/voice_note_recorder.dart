import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Colours ──────────────────────────────────────────────────────────────────
const Color _kGreen        = Color(0xFF18A369);
const Color _kGreenLight   = Color(0xFFE8F7F1);
const Color _kBgGray       = Color(0xFFFAFAFA);
const Color _kHomeBar      = Color(0xFF1D1B20);
const Color _kDivider      = Color(0xFFE5E5E5);
const Color _kTextDark     = Color(0xFF171717);
const Color _kTextGray     = Color(0xFF737373);
const Color _kRed          = Color(0xFFDC362E);
const Color _kBtnGray      = Color(0xFFF5F5F5);
const Color _kWave         = Color(0xFFD4D4D4);

// ─── Recording state ──────────────────────────────────────────────────────────
enum _RecState { ready, recording, recorded, playing }

// ─── Script text ──────────────────────────────────────────────────────────────
const _kScript =
    'I confirm on behalf of the group that all selected members have been '
    'informed of the support request. We understand the terms: the agreed '
    'amount will be disbursed, and each member undertakes to repay the '
    'equivalent in commodity bags at the time of recovery, as specified.';

// ─── Public widget ────────────────────────────────────────────────────────────
class VoiceNoteRecorder extends StatefulWidget {
  /// Text shown in the header below the app bar.
  final String headerText;

  /// Called when the user taps "Proceed".
  final VoidCallback? onProceed;

  const VoiceNoteRecorder({
    super.key,
    required this.headerText,
    this.onProceed,
  });

  @override
  State<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<VoiceNoteRecorder>
    with TickerProviderStateMixin {
  // ── Recording state ─────────────────────────────────────────────────────────
  _RecState _state = _RecState.ready;
  bool _scriptExpanded = false;

  // ── Timer ───────────────────────────────────────────────────────────────────
  int _elapsed = 0;
  int _recorded = 0;
  Timer? _clock;

  // ── Waveform animation ───────────────────────────────────────────────────────
  late final AnimationController _waveCtrl;
  final _rng = Random();
  List<double> _bars = List.filled(28, 0.15);

  // ── Record button pulse ──────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )..addListener(_onWaveTick);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 1.0,
      upperBound: 1.12,
    );
  }

  @override
  void dispose() {
    _clock?.cancel();
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Wave callback ─────────────────────────────────────────────────────────
  void _onWaveTick() {
    if (_state == _RecState.recording || _state == _RecState.playing) {
      setState(() {
        _bars = List.generate(28, (_) => 0.12 + _rng.nextDouble() * 0.88);
      });
      _waveCtrl.forward(from: 0);
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────────
  void _onRecordTap() {
    if (_state == _RecState.ready || _state == _RecState.recorded) {
      _startRecording();
    } else if (_state == _RecState.recording) {
      _stopRecording();
    }
  }

  void _startRecording() {
    _clock?.cancel();
    setState(() {
      _state = _RecState.recording;
      _elapsed = 0;
    });
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed++);
    });
    _waveCtrl.forward(from: 0);
    _pulseCtrl.repeat(reverse: true);
  }

  void _stopRecording() {
    _clock?.cancel();
    _waveCtrl.stop();
    _pulseCtrl.stop();
    _pulseCtrl.value = 1.0;
    setState(() {
      _state = _RecState.recorded;
      _recorded = _elapsed;
      _bars = List.generate(28, (_) => 0.12 + _rng.nextDouble() * 0.88);
    });
  }

  void _onPlayTap() {
    if (_state == _RecState.recorded) {
      _startPlayback();
    } else if (_state == _RecState.playing) {
      _pausePlayback();
    }
  }

  void _startPlayback() {
    _clock?.cancel();
    setState(() {
      _state = _RecState.playing;
      _elapsed = 0;
    });
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_elapsed >= _recorded) {
        _stopPlayback();
      } else {
        setState(() => _elapsed++);
      }
    });
    _waveCtrl.forward(from: 0);
  }

  void _pausePlayback() {
    _clock?.cancel();
    _waveCtrl.stop();
    setState(() => _state = _RecState.recorded);
  }

  void _stopPlayback() {
    _clock?.cancel();
    _waveCtrl.stop();
    setState(() {
      _state = _RecState.recorded;
      _elapsed = _recorded;
    });
  }

  void _onStopTap() {
    if (_state == _RecState.recording) {
      _stopRecording();
    } else if (_state == _RecState.playing) {
      _stopPlayback();
    }
  }

  void _onRecordAgain() {
    _clock?.cancel();
    _waveCtrl.stop();
    _pulseCtrl.stop();
    _pulseCtrl.value = 1.0;
    setState(() {
      _state = _RecState.ready;
      _elapsed = 0;
      _recorded = 0;
      _bars = List.filled(28, 0.15);
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String get _timerText {
    final h = _elapsed ~/ 3600;
    final m = (_elapsed % 3600) ~/ 60;
    final s = _elapsed % 60;
    return '${h.toString().padLeft(2, '0')} : '
        '${m.toString().padLeft(2, '0')} : '
        '${s.toString().padLeft(2, '0')}';
  }

  String get _statusText => switch (_state) {
        _RecState.ready     => 'Start recording',
        _RecState.recording => 'Recording...',
        _RecState.recorded  => 'Recording complete',
        _RecState.playing   => 'Playing...',
      };

  Color get _statusColor => _state == _RecState.recording
      ? _kRed
      : _state == _RecState.playing
          ? _kGreen
          : _kTextGray;

  bool get _hasRecording =>
      _state == _RecState.recorded || _state == _RecState.playing;

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _kGreen,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kGreen,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StatusBar(),
            _TopAppBar(title: 'Record evidence'),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header ────────────────────────────────────────────
                    _Header(text: widget.headerText),
                    const Divider(height: 1, thickness: 1, color: _kDivider),

                    // ── Scrollable body ───────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Script dropdown
                            _ScriptDropdown(
                              expanded: _scriptExpanded,
                              onToggle: () => setState(
                                () => _scriptExpanded = !_scriptExpanded,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Timer
                            Text(
                              _timerText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 32,
                                color: _kTextDark,
                                height: 40 / 32,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Status text
                            Text(
                              _statusText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: _statusColor,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Waveform
                            _Waveform(
                              bars: _bars,
                              active: _state == _RecState.recording ||
                                  _state == _RecState.playing,
                              progress: _recorded > 0 && _state == _RecState.playing
                                  ? _elapsed / _recorded
                                  : null,
                            ),

                            const SizedBox(height: 32),

                            // Control buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Play / Pause
                                _CircleButton(
                                  size: 56,
                                  bg: _kBtnGray,
                                  enabled: _hasRecording,
                                  onTap: _onPlayTap,
                                  child: Icon(
                                    _state == _RecState.playing
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: _hasRecording
                                        ? _kTextGray
                                        : _kTextGray.withOpacity(0.35),
                                    size: 28,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Record / mic (centre, larger)
                                AnimatedBuilder(
                                  animation: _pulseCtrl,
                                  builder: (_, child) => Transform.scale(
                                    scale: _pulseCtrl.value,
                                    child: child,
                                  ),
                                  child: GestureDetector(
                                    onTap: _onRecordTap,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E5E5),
                                        shape: BoxShape.circle,
                                        boxShadow: _state == _RecState.recording
                                            ? [
                                                BoxShadow(
                                                  color: _kRed.withOpacity(0.25),
                                                  blurRadius: 16,
                                                  spreadRadius: 4,
                                                )
                                              ]
                                            : null,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: _kRed,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.mic,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Stop
                                _CircleButton(
                                  size: 56,
                                  bg: _kBtnGray,
                                  enabled: _state == _RecState.recording ||
                                      _state == _RecState.playing,
                                  onTap: _onStopTap,
                                  child: Icon(
                                    Icons.stop,
                                    color: (_state == _RecState.recording ||
                                            _state == _RecState.playing)
                                        ? _kTextGray
                                        : _kTextGray.withOpacity(0.35),
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Bottom buttons ────────────────────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Row(
                        children: [
                          // "Record again"
                          Expanded(
                            child: _OutlinedBtn(
                              label: 'Record again',
                              enabled: _hasRecording,
                              onTap: _hasRecording ? _onRecordAgain : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // "Proceed"
                          Expanded(
                            child: _FilledBtn(
                              label: 'Proceed',
                              onTap: widget.onProceed,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const _BottomIndicator(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Script dropdown ──────────────────────────────────────────────────────────
class _ScriptDropdown extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const _ScriptDropdown({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kGreenLight,
        border: Border.all(color: _kGreen),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Service acceptance script',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: _kGreen,
                        letterSpacing: 0.15,
                        height: 24 / 16,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: _kGreen,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded script text
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: _kGreen, height: 1, thickness: 1),
                  const SizedBox(height: 12),
                  Text(
                    _kScript,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF198246),
                      letterSpacing: 0.25,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ─── Waveform visualisation ───────────────────────────────────────────────────
class _Waveform extends StatelessWidget {
  final List<double> bars; // 0.0 – 1.0 heights
  final bool active;
  final double? progress; // 0.0 – 1.0 playback progress

  const _Waveform({required this.bars, required this.active, this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 63,
      child: ClipRect(
        child: CustomPaint(
          painter: _WavePainter(
            bars: bars,
            active: active,
            progress: progress,
            activeColor: _kGreen,
            inactiveColor: _kWave,
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final List<double> bars;
  final bool active;
  final double? progress;
  final Color activeColor;
  final Color inactiveColor;

  const _WavePainter({
    required this.bars,
    required this.active,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 3.0;
    final barW = (size.width - gap * (bars.length - 1)) / bars.length;
    final maxH = size.height - 13 * 2; // 13 px top/bottom padding
    final threshold = progress != null ? (progress! * bars.length).floor() : -1;

    for (var i = 0; i < bars.length; i++) {
      final h = max(4.0, bars[i] * maxH);
      final x = i * (barW + gap);
      final top = (size.height - h) / 2;
      final paint = Paint()
        ..color = (active || i <= threshold) ? activeColor : inactiveColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, barW, h),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter o) =>
      bars != o.bars || active != o.active || progress != o.progress;
}

// ─── Circle button ────────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final double size;
  final Color bg;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget child;

  const _CircleButton({
    required this.size,
    required this.bg,
    required this.enabled,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Center(child: child),
      ),
    );
  }
}

// ─── Outlined bottom button ───────────────────────────────────────────────────
class _OutlinedBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _OutlinedBtn({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kDivider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: enabled
                    ? _kTextGray
                    : _kTextGray.withOpacity(0.38),
                letterSpacing: 0.15,
                height: 24 / 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Filled bottom button ─────────────────────────────────────────────────────
class _FilledBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _FilledBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 24, 40, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.15,
                height: 24 / 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header below app bar ─────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String text;

  const _Header({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: _kTextDark,
          letterSpacing: 0.15,
          height: 24 / 16,
        ),
      ),
    );
  }
}

// ─── Status bar ───────────────────────────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: _kGreen,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          const Text(
            '9:30',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              letterSpacing: 0.14,
              height: 20 / 14,
            ),
          ),
          const Spacer(),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          const Icon(Icons.wifi, color: Colors.white, size: 17),
          const SizedBox(width: 4),
          const Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 17),
          const SizedBox(width: 4),
          const Icon(Icons.battery_full, color: Colors.white, size: 17),
        ],
      ),
    );
  }
}

// ─── Top app bar ──────────────────────────────────────────────────────────────
class _TopAppBar extends StatelessWidget {
  final String title;

  const _TopAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: _kGreen,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                letterSpacing: 0.15,
                height: 24 / 16,
              ),
            ),
          ),
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}

// ─── Bottom indicator ─────────────────────────────────────────────────────────
class _BottomIndicator extends StatelessWidget {
  const _BottomIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      color: _kBgGray,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: 72,
        height: 10,
        decoration: BoxDecoration(
          color: _kHomeBar,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
