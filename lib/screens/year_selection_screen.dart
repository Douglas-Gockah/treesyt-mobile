import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'record_support_screen.dart';

// ─── Colours (spec-exact) ─────────────────────────────────────────────────────
const Color _kGreen       = Color(0xFF18A369);
const Color _kGreenDark   = Color(0xFF198246);
const Color _kGreenLight  = Color(0xFFE8F7F1);
const Color _kGreenBorder = Color(0xFFB7E5D4);
const Color _kBgGray      = Color(0xFFFAFAFA);
const Color _kHomeBar     = Color(0xFF1D1B20);
const Color _kDivider     = Color(0xFFE5E5E5);
const Color _kTextDark    = Color(0xFF171717);
const Color _kTextGray    = Color(0xFF696969);

// Years that already have a support submission recorded.
const Set<int> _kSubmittedYears = {2024, 2025};
const List<int> _kYears = [2024, 2025, 2026];

// ─── Screen ───────────────────────────────────────────────────────────────────
class YearSelectionScreen extends StatefulWidget {
  const YearSelectionScreen({super.key});

  @override
  State<YearSelectionScreen> createState() => _YearSelectionScreenState();
}

class _YearSelectionScreenState extends State<YearSelectionScreen> {
  // Default to the current / non-submitted year.
  int _selectedYear = 2026;

  void _continue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordSupportScreen(year: _selectedYear),
      ),
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
                    // Scrollable body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heading
                            const Text(
                              'Select support year',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: _kTextDark,
                                letterSpacing: 0.15,
                                height: 24 / 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Each group can only receive support once per year.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: _kTextGray,
                                letterSpacing: 0.25,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Year option cards
                            for (final year in _kYears) ...[
                              _YearCard(
                                year: year,
                                isSelected: _selectedYear == year,
                                isSubmitted: _kSubmittedYears.contains(year),
                                onTap: () =>
                                    setState(() => _selectedYear = year),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // §4 Continue button
                    _ContinueButton(onTap: _continue),

                    // §5 Bottom indicator · 28 px
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

// ─── Year option card ─────────────────────────────────────────────────────────
class _YearCard extends StatelessWidget {
  final int year;
  final bool isSelected;
  final bool isSubmitted;
  final VoidCallback onTap;

  const _YearCard({
    required this.year,
    required this.isSelected,
    required this.isSubmitted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? _kGreenLight : Colors.white,
          border: Border.all(
            color: isSelected ? _kGreen : _kDivider,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Year label
            Expanded(
              child: Text(
                '$year',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: isSubmitted ? _kTextGray : _kTextDark,
                  letterSpacing: 0.15,
                  height: 24 / 16,
                ),
              ),
            ),

            // Status badge
            _StatusBadge(label: isSubmitted ? 'Submitted' : 'Current'),

            const SizedBox(width: 16),

            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _kGreen : const Color(0xFFD0D5DD),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kGreen,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status badge pill ────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;

  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kGreenLight,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _kGreenBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: _kGreenDark,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─── Continue button ──────────────────────────────────────────────────────────
class _ContinueButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ContinueButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Container(
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
                'Continue',
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

// ─── Top app bar — 64 px ─────────────────────────────────────────────────────
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
              'Record support',
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
