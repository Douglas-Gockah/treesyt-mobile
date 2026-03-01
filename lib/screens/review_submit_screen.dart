import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'record_consent_screen.dart';

// ─── Colours (spec-exact) ─────────────────────────────────────────────────────
const Color _kGreen      = Color(0xFF18A369);
const Color _kBgLight    = Color(0xFFF5F5F5);
const Color _kHomeBar    = Color(0xFF1D1B20);
const Color _kDivider    = Color(0xFFE5E5E5);
const Color _kTextDark   = Color(0xFF171717);
const Color _kTextGray   = Color(0xFF696969);
const Color _kTextLtGray = Color(0xFFA3A3A3);

// ─── Screen ───────────────────────────────────────────────────────────────────
class ReviewSubmitScreen extends StatelessWidget {
  final String groupName;
  final int selectedFarmers;
  final int totalFarmers;
  final int year;
  final int amountPerFarmer;          // base amount chosen
  final bool doubleAmount;            // farmer returns 2 bags at recovery
  final int effectiveAmountPerFarmer; // actual disbursement (2× if double)

  const ReviewSubmitScreen({
    super.key,
    this.groupName = 'Jirapa Fields Cooperative',
    this.selectedFarmers = 8,
    this.totalFarmers = 11,
    this.year = 2026,
    this.amountPerFarmer = 700,
    this.doubleAmount = false,
    this.effectiveAmountPerFarmer = 700,
  });

  int get _total => effectiveAmountPerFarmer * selectedFarmers;

  void _submit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordConsentScreen()),
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

            // §2 Top app bar · 65 px
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // §4 "Request summary" heading
                            const Text(
                              'Request summary',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: _kTextDark,
                                letterSpacing: 0.5,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // §5 Group summary card
                            _GroupSummaryCard(
                              groupName: groupName,
                              selectedFarmers: selectedFarmers,
                              totalFarmers: totalFarmers,
                            ),

                            // §7 Divider
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: _kDivider,
                              ),
                            ),

                            // §8 Support details card
                            _SupportDetailsCard(
                              year: year,
                              amountPerFarmer: amountPerFarmer,
                              doubleAmount: doubleAmount,
                              effectiveAmountPerFarmer: effectiveAmountPerFarmer,
                              selectedFarmers: selectedFarmers,
                              total: _total,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // §9 Proceed / Submit button
                    _BottomButton(onTap: () => _submit(context)),

                    // §10 Bottom indicator · 28 px
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

// ─── §5 Group summary card ────────────────────────────────────────────────────
class _GroupSummaryCard extends StatelessWidget {
  final String groupName;
  final int selectedFarmers;
  final int totalFarmers;

  const _GroupSummaryCard({
    required this.groupName,
    required this.selectedFarmers,
    required this.totalFarmers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Group name — centred
        Text(
          groupName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: _kTextDark,
            letterSpacing: 0.15,
            height: 24 / 16,
          ),
        ),

        const SizedBox(height: 8),

        // "8 farmers selected" — inline
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$selectedFarmers ',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: _kTextDark,
                letterSpacing: 0.5,
                height: 1.5,
              ),
            ),
            const Text(
              'farmers selected',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: _kTextGray,
                letterSpacing: 0.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── §8 Support details card ──────────────────────────────────────────────────
class _SupportDetailsCard extends StatelessWidget {
  final int year;
  final int amountPerFarmer;
  final bool doubleAmount;
  final int effectiveAmountPerFarmer;
  final int selectedFarmers;
  final int total;

  const _SupportDetailsCard({
    required this.year,
    required this.amountPerFarmer,
    required this.doubleAmount,
    required this.effectiveAmountPerFarmer,
    required this.selectedFarmers,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kDivider),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 24, 40, 0.06),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1 — year pill + support type
                Row(
                  children: [
                    // Year badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7F1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0xFFB7E5D4)),
                      ),
                      child: Text(
                        '$year',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Color(0xFF198246),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Support type
                    const Text(
                      'Cash',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: _kTextDark,
                        letterSpacing: 0.25,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1, color: _kDivider),
                const SizedBox(height: 8),

                // Row 2 — amount per farmer
                Row(
                  children: [
                    Text(
                      '$effectiveAmountPerFarmer GHC per farmer',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: _kTextDark,
                        letterSpacing: 0.25,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),

                // Double-bags note (only shown when doubleAmount is true)
                if (doubleAmount) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.swap_vert_rounded,
                        size: 16,
                        color: Color(0xFF198246),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Double bags — returns 2 bags at recovery',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF198246),
                          letterSpacing: 0.2,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1, color: _kDivider),
                const SizedBox(height: 16),

                // Row 3 — total amount (prominent)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      'Total amount  ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: _kTextDark,
                        letterSpacing: 0.1,
                        height: 21 / 14,
                      ),
                    ),
                    const Text(
                      'GHC ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: _kTextLtGray,
                        letterSpacing: 0.1,
                        height: 21 / 14,
                      ),
                    ),
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: _kTextDark,
                        height: 32 / 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Calculation note — e.g. "GHC 700 × 8 farmers"
                Text(
                  'GHC $effectiveAmountPerFarmer × $selectedFarmers farmers',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: _kTextLtGray,
                    letterSpacing: 0.2,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Checkmark icon — absolute top-right
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: _kGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── §9 Proceed / Submit button ────────────────────────────────────────────────
class _BottomButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BottomButton({required this.onTap});

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
                'Proceed',
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

// ─── Top app bar — 65 px ─────────────────────────────────────────────────────
class _TopAppBar extends StatelessWidget {
  const _TopAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
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
              'Review and submit request',
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
// #F5F5F5 bg · 72×10 px bar · #1D1B20 · radius 8 px · 8 px from bottom
class _BottomIndicator extends StatelessWidget {
  const _BottomIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      color: _kBgLight,
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
