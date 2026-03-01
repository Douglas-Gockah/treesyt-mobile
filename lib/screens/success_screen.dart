import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Colours ──────────────────────────────────────────────────────────────────
const Color _kGreen     = Color(0xFF18A369);
const Color _kGreenBg   = Color(0xFFE8F7F1);
const Color _kBgGray    = Color(0xFFFAFAFA);
const Color _kHomeBar   = Color(0xFF1D1B20);
const Color _kTextDark  = Color(0xFF171717);

// ─── Screen ───────────────────────────────────────────────────────────────────
class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {
  // Sheet slides up
  late final AnimationController _sheetCtrl;
  late final Animation<Offset>   _sheetSlide;

  // Checkmark scales in with elastic bounce + fades in
  late final AnimationController _iconCtrl;
  late final Animation<double>   _iconScale;
  late final Animation<double>   _iconOpacity;

  // Success text fades + slides up
  late final AnimationController _textCtrl;
  late final Animation<double>   _textOpacity;
  late final Animation<Offset>   _textSlide;

  @override
  void initState() {
    super.initState();

    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _sheetSlide = Tween(begin: const Offset(0, 0.18), end: Offset.zero).animate(
      CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic),
    );

    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _iconScale = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlide = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _sheetCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    _iconCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    _textCtrl.forward();
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _iconCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _goHome() => Navigator.of(context).popUntil((r) => r.isFirst);

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
            // §1 Status bar · 52 px (sits on green background)
            const _StatusBar(),

            // §3 White bottom sheet — slides up on entry
            Expanded(
              child: SlideTransition(
                position: _sheetSlide,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // §4/5 Centred success content
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // §5 Checkmark icon — scale + fade
                                FadeTransition(
                                  opacity: _iconOpacity,
                                  child: ScaleTransition(
                                    scale: _iconScale,
                                    child: const _CheckmarkIcon(),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // §6 Success message — fade + slide
                                FadeTransition(
                                  opacity: _textOpacity,
                                  child: SlideTransition(
                                    position: _textSlide,
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Group support request submitted\nsuccessfully',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: _kTextDark,
                                            height: 1.55,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'The request has been recorded and will be\nprocessed by the support team.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // §7 Go home button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _GoHomeButton(onTap: _goHome),
                      ),

                      // §8 Bottom indicator · 28 px
                      const _BottomIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Checkmark icon — 98 × 98 px ─────────────────────────────────────────────
class _CheckmarkIcon extends StatelessWidget {
  const _CheckmarkIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 98,
      height: 98,
      decoration: const BoxDecoration(color: _kGreenBg, shape: BoxShape.circle),
      child: const Icon(Icons.check_circle_rounded, color: _kGreen, size: 72),
    );
  }
}

// ─── Go home button ───────────────────────────────────────────────────────────
class _GoHomeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoHomeButton({required this.onTap});

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
          child: const Center(
            child: Text(
              'Go home',
              style: TextStyle(
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

// ─── Status bar — 52 px ───────────────────────────────────────────────────────
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

// ─── Bottom indicator — 28 px ─────────────────────────────────────────────────
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
