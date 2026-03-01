import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'assign_cash_support_screen.dart';

// ─── Colours (spec-exact) ─────────────────────────────────────────────────────
const Color _kGreen      = Color(0xFF18A369);
const Color _kGreenLight = Color(0xFFE8F5F1);
const Color _kBgGray     = Color(0xFFFAFAFA);
const Color _kHomeBar    = Color(0xFF1D1B20);
const Color _kDivider    = Color(0xFFE5E5E5);
const Color _kTextDark   = Color(0xFF171717);
const Color _kTextGray   = Color(0xFF737373);
const Color _kDisabled   = Color(0xFFF5F5F5);
const Color _kToggleOff  = Color(0xFFF5F5F5);
const Color _kToggleBdr  = Color(0xFFA3A3A3);

// ─── Support options ──────────────────────────────────────────────────────────
const List<String> _kSupportOptions = ['Ploughing', 'Cash', 'Farm inputs'];

// ─── Screen ───────────────────────────────────────────────────────────────────
class SelectSupportScreen extends StatefulWidget {
  final int year;

  const SelectSupportScreen({super.key, required this.year});

  @override
  State<SelectSupportScreen> createState() => _SelectSupportScreenState();
}

class _SelectSupportScreenState extends State<SelectSupportScreen> {
  // Radio-style: index of selected option (null = none selected)
  int? _primarySelected;
  int? _secondarySelected;
  bool _agroforestry = false;

  bool get _canProceed =>
      _primarySelected != null || _secondarySelected != null || _agroforestry;

  void _proceed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AssignCashSupportScreen(year: widget.year)),
    );
  }

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
            // §1 Status bar · 52 px
            const _StatusBar(),

            // §2 Top app bar · 64 px
            const _TopAppBar(),

            // §3 White content area
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Scrollable section list
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Primary Support ──────────────────────────────
                            const _SectionHeader(title: 'Primary Support'),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: _kDivider,
                            ),
                            for (int i = 0;
                                i < _kSupportOptions.length;
                                i++) ...[
                              _ToggleRow(
                                label: _kSupportOptions[i],
                                value: _primarySelected == i,
                                onChanged: (on) => setState(
                                  () => _primarySelected = on ? i : null,
                                ),
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: _kDivider,
                              ),
                            ],

                            const SizedBox(height: 16),

                            // ── Secondary Support ────────────────────────────
                            const _SectionHeader(title: 'Secondary Support'),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: _kDivider,
                            ),
                            for (int i = 0;
                                i < _kSupportOptions.length;
                                i++) ...[
                              _ToggleRow(
                                label: _kSupportOptions[i],
                                value: _secondarySelected == i,
                                onChanged: (on) => setState(
                                  () => _secondarySelected = on ? i : null,
                                ),
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: _kDivider,
                              ),
                            ],

                            const SizedBox(height: 16),

                            // ── Agroforestry ─────────────────────────────────
                            const _SectionHeader(title: 'Agroforestry'),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: _kDivider,
                            ),
                            _ToggleRow(
                              label: 'Agroforestry',
                              value: _agroforestry,
                              onChanged: (on) =>
                                  setState(() => _agroforestry = on),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: _kDivider,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // §9 Proceed button — disabled until ≥1 selection
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _ProceedButton(
                        enabled: _canProceed,
                        onTap: _canProceed ? _proceed : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // §10 Bottom indicator · 28 px
            const _BottomIndicator(),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: _kTextDark,
          letterSpacing: 0.1,
          height: 20 / 14,
        ),
      ),
    );
  }
}

// ─── Toggle row ───────────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Label — flex 1
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: _kTextDark,
                  letterSpacing: 0.5,
                  height: 1.5,
                ),
              ),
            ),

            // Custom toggle
            _CustomToggle(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

// ─── Custom toggle ────────────────────────────────────────────────────────────
// OFF: track #F5F5F5, border #A3A3A3, handle #737373 (left)
// ON:  track #E8F5F1, border #18A369, handle #18A369 (right)
class _CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? _kGreenLight : _kToggleOff,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: value ? _kGreen : _kToggleBdr,
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment:
              value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? _kGreen : _kTextGray,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Proceed button ───────────────────────────────────────────────────────────
// Disabled: #F5F5F5 bg, #737373 text
// Active:   #18A369 bg, white text
class _ProceedButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _ProceedButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: enabled ? _kGreen : _kDisabled,
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
              'Proceed',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: enabled ? Colors.white : _kTextGray,
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

// ─── Status bar — 52 px (spec §1) ────────────────────────────────────────────
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
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}

// ─── Bottom indicator — 28 px (spec §10) ─────────────────────────────────────
// #FAFAFA bg, 72×10 px bar, #1D1B20, radius 8 px, 8 px from bottom
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
