import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'year_selection_screen.dart';
import 'recoveries_screen.dart';
import 'support_progress_screen.dart';

// ─── Spec-exact colour palette ────────────────────────────────────────────────
const Color _kGreen       = Color(0xFF18A369);
const Color _kBgGray      = Color(0xFFFAFAFA);
const Color _kDivider     = Color(0xFFE5E5E5);
const Color _kTextPrimary = Color(0xFF252A31);   // spec: Text Primary
const Color _kIconGray    = Color(0xFF737373);   // spec: Icon Gray
const Color _kChevron     = Color(0xFF4F5E71);   // spec: Chevron Gray
const Color _kHomeBar     = Color(0xFF1D1B20);   // spec: Bottom Indicator

// ─── Menu entry descriptor ────────────────────────────────────────────────────
class _Entry {
  final Widget icon;
  final bool hasCircle;   // true → 40×40 white circle container
  final String label;
  final WidgetBuilder destination;

  const _Entry({
    required this.icon,
    required this.hasCircle,
    required this.label,
    required this.destination,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class FarmerSupportScreen extends StatelessWidget {
  const FarmerSupportScreen({super.key});

  List<_Entry> _entries() => [
    // Item 1 — Record Support
    // Custom outline icon, 18×18 px, white 40×40 circle container
    _Entry(
      icon: const Icon(Icons.assignment_outlined, color: _kIconGray, size: 18),
      hasCircle: true,
      label: 'Record support',
      destination: (_) => const YearSelectionScreen(),
    ),

    // Item 2 — Support Progress
    // safety_divider icon, 24×24 px, transparent 40×40 container
    _Entry(
      icon: const Icon(Icons.safety_divider, color: _kIconGray, size: 24),
      hasCircle: false,
      label: 'Support progress',
      destination: (_) => const SupportProgressScreen(),
    ),

    // Item 3 — Recoveries
    // Arrow rotated 180°, 16×16 px, white 40×40 circle container
    _Entry(
      icon: Transform.rotate(
        angle: math.pi,
        child: const Icon(Icons.arrow_forward, color: _kIconGray, size: 16),
      ),
      hasCircle: true,
      label: 'Recoveries',
      destination: (_) => const RecoveriesScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = _entries();

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
            // §1 Status bar  ·  52 px
            const _StatusBar(),

            // §2 Top app bar  ·  64 px
            const _TopAppBar(),

            // §3 Bottom sheet (white)  ·  fills remaining space
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section header — 12 px from sheet top, 16 px side padding
                    const Padding(
                      padding: EdgeInsets.only(top: 12, left: 16, right: 16),
                      child: Text(
                        'What do you want to do?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black,
                          letterSpacing: 0.15,
                          height: 24 / 16,
                        ),
                      ),
                    ),

                    // 24 px gap between header and item list
                    const SizedBox(height: 24),

                    // Menu items with 1 px dividers (8 px total gap)
                    for (int i = 0; i < entries.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 8,
                          thickness: 1,
                          color: _kDivider,
                          indent: 0,
                          endIndent: 0,
                        ),
                      _MenuItem(
                        entry: entries[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: entries[i].destination),
                        ),
                      ),
                    ],

                    const Spacer(),
                  ],
                ),
              ),
            ),

            // §6 Bottom indicator  ·  28 px
            const _BottomIndicator(),
          ],
        ),
      ),
    );
  }
}

// ─── Menu item row — 56 px tall (spec §5) ─────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final _Entry entry;
  final VoidCallback onTap;

  const _MenuItem({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Left: icon container 40×40 px
              _IconBox(hasCircle: entry.hasCircle, child: entry.icon),

              // Gap: 16 px between icon and text
              const SizedBox(width: 16),

              // Label — Inter Regular 16 px #252A31
              Expanded(
                child: Text(
                  entry.label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: _kTextPrimary,
                    letterSpacing: 0.5,
                    height: 1.5,
                  ),
                ),
              ),

              // Right: chevron in 24×24 container, glyph #4F5E71
              const SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: Icon(Icons.chevron_right, color: _kChevron, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Icon container (40×40) ───────────────────────────────────────────────────
// hasCircle=true  → white filled circle, 8 px inner padding (spec items 1 & 3)
// hasCircle=false → transparent box, icon centred (spec item 2)
class _IconBox extends StatelessWidget {
  final bool hasCircle;
  final Widget child;

  const _IconBox({required this.hasCircle, required this.child});

  @override
  Widget build(BuildContext context) {
    if (hasCircle) {
      return Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: child,
      );
    }
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(child: child),
    );
  }
}

// ─── Status bar — 52 px (spec §1) ────────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: _kGreen,
      // 10 px vertical, 24 px horizontal padding (spec)
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          // Left — time "9:30"
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

          // Centre — camera cutout 24×24 circle (#1D1B20)
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _kHomeBar,
            ),
          ),

          const Spacer(),

          // Right — WiFi 17×17, Signal 17×17, Battery 17 px
          const Icon(Icons.wifi, color: Colors.white, size: 17),
          const SizedBox(width: 4),
          const Icon(
            Icons.signal_cellular_4_bar,
            color: Colors.white,
            size: 17,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.battery_full, color: Colors.white, size: 17),
        ],
      ),
    );
  }
}

// ─── Top app bar — 64 px (spec §2) ───────────────────────────────────────────
class _TopAppBar extends StatelessWidget {
  const _TopAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: _kGreen,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Leading: back button, 48×48 rounded container
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),

          // 4 px gap
          const SizedBox(width: 4),

          // Title — Inter Medium 16 px, white, flex: 1
          const Expanded(
            child: Text(
              'Farmer support',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                letterSpacing: 0.15,
                height: 24 / 16,
              ),
            ),
          ),

          // Trailing: empty 48×48 placeholder
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}

// ─── Bottom indicator — 28 px (spec §6) ──────────────────────────────────────
// Home bar: 72×10 px, #1D1B20, border-radius 8 px, 8 px from bottom
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
