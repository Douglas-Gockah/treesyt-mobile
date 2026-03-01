import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Colours (spec-exact) ─────────────────────────────────────────────────────
const Color _kGreen        = Color(0xFF18A369);
const Color _kGreenDark    = Color(0xFF198246);
const Color _kGreenLight   = Color(0xFFE8F7F1);
const Color _kBgGray       = Color(0xFFFAFAFA);
const Color _kHomeBar      = Color(0xFF1D1B20);
const Color _kDivider      = Color(0xFFE5E5E5);
const Color _kTextDark     = Color(0xFF171717);
const Color _kTextMid      = Color(0xFF404040);
const Color _kTextGray     = Color(0xFF696969);
const Color _kTextLtGray   = Color(0xFFA3A3A3);

// ─── Dropdown amount options (GHS) ────────────────────────────────────────────
const List<int> _kAmounts = [50, 100, 150, 200, 250, 300, 400, 500];

// ─── Screen ───────────────────────────────────────────────────────────────────
class AssignCashSupportScreen extends StatefulWidget {
  final String groupName;
  final int selectedFarmers;
  final int totalFarmers;

  const AssignCashSupportScreen({
    super.key,
    this.groupName = 'Jirapa Fields Cooperative',
    this.selectedFarmers = 8,
    this.totalFarmers = 11,
  });

  @override
  State<AssignCashSupportScreen> createState() =>
      _AssignCashSupportScreenState();
}

class _AssignCashSupportScreenState extends State<AssignCashSupportScreen> {
  int _amountPerFarmer = 100;
  // Double-amount toggle: farmer returns 2 bags at recovery instead of 1.
  bool _doubleAmount = false;

  int get _totalAmount => _amountPerFarmer * widget.selectedFarmers;

  // Show bottom-sheet picker for the amount dropdown.
  Future<void> _pickAmount() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AmountPicker(
        amounts: _kAmounts,
        selected: _amountPerFarmer,
      ),
    );
    if (picked != null && picked != _amountPerFarmer) {
      setState(() => _amountPerFarmer = picked);
    }
  }

  void _proceed() {
    debugPrint(
      '[AssignCash] amount=$_amountPerFarmer'
      ' double=$_doubleAmount'
      ' total=$_totalAmount'
      ' farmers=${widget.selectedFarmers}',
    );
    // TODO: push confirmation screen
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // §4 Group summary card
                            _GroupSummaryCard(
                              groupName: widget.groupName,
                              selectedFarmers: widget.selectedFarmers,
                              totalFarmers: widget.totalFarmers,
                            ),

                            // §5 Divider
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: _kDivider,
                            ),

                            // §6 Request details header
                            const _RequestDetailsHeader(),

                            // §7 Cash support card
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              child: _CashSupportCard(
                                amount: _amountPerFarmer,
                                doubleAmount: _doubleAmount,
                                onAmountTap: _pickAmount,
                                onDoubleChanged: (v) =>
                                    setState(() => _doubleAmount = v),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // §9 Proceed button (always active — default 100)
                    _BottomButton(onTap: _proceed),

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

// ─── §4 Group summary card ────────────────────────────────────────────────────
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: [
          // Group name
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

          // "8 of 11 farmers selected"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$selectedFarmers of $totalFarmers',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: _kTextDark,
                  letterSpacing: 0.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 4),
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

          const SizedBox(height: 4),

          // Support type label
          const Text(
            'Cash',
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
    );
  }
}

// ─── §6 Request details header row ───────────────────────────────────────────
class _RequestDetailsHeader extends StatelessWidget {
  const _RequestDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Request details',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: _kTextMid,
                letterSpacing: 0.15,
                height: 24 / 16,
              ),
            ),
          ),
          Text(
            'Edit',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: _kTextLtGray,
              letterSpacing: 0.15,
              height: 24 / 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── §7 Cash support card ─────────────────────────────────────────────────────
class _CashSupportCard extends StatelessWidget {
  final int amount;
  final bool doubleAmount;
  final VoidCallback onAmountTap;
  final ValueChanged<bool> onDoubleChanged;

  const _CashSupportCard({
    required this.amount,
    required this.doubleAmount,
    required this.onAmountTap,
    required this.onDoubleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _kDivider),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Light-green header "Cash"
          Container(
            color: _kGreenLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'Cash',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: _kGreenDark,
                letterSpacing: 0.25,
                height: 1.5,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // §8 Amount per farmer dropdown field
                _AmountField(amount: amount, onTap: onAmountTap),

                const SizedBox(height: 16),

                // Divider between amount and double-amount toggle
                const Divider(height: 1, thickness: 1, color: _kDivider),

                const SizedBox(height: 16),

                // Double-amount toggle (new feature)
                _DoubleAmountRow(
                  value: doubleAmount,
                  onChanged: onDoubleChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── §8 Amount field ──────────────────────────────────────────────────────────
class _AmountField extends StatelessWidget {
  final int amount;
  final VoidCallback onTap;

  const _AmountField({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount per farmer',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: _kTextDark,
            letterSpacing: 0.25,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _kDivider),
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(16, 24, 40, 0.05),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                // Amount value
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      '$amount',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: _kTextDark,
                        letterSpacing: 0.25,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                // Chevron-down dropdown icon
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: _kTextGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Double-amount toggle row (new feature) ───────────────────────────────────
//
// Allows the farmer to indicate they want double the selected amount,
// meaning they will return 2 bags (instead of 1) at the time of recovery.
class _DoubleAmountRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DoubleAmountRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Labels
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Double amount',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: _kTextDark,
                  letterSpacing: 0.25,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Farmer returns 2 bags at recovery',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: _kTextGray,
                  letterSpacing: 0.4,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Custom toggle (matches spec from SelectSupportScreen)
        _CustomToggle(value: value, onChanged: onChanged),
      ],
    );
  }
}

// ─── Custom toggle — matches SelectSupportScreen style ───────────────────────
// OFF: #F5F5F5 track, #A3A3A3 border, #737373 handle (left)
// ON:  #E8F5F1 track, #18A369 border + handle (right)
class _CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const offTrack   = Color(0xFFF5F5F5);
    const offBorder  = Color(0xFFA3A3A3);
    const offHandle  = Color(0xFF737373);
    const onTrack    = Color(0xFFE8F5F1);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? onTrack : offTrack,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: value ? _kGreen : offBorder,
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? _kGreen : offHandle,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Amount picker bottom sheet ───────────────────────────────────────────────
class _AmountPicker extends StatelessWidget {
  final List<int> amounts;
  final int selected;

  const _AmountPicker({required this.amounts, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            'Select amount',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: _kTextDark,
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: _kDivider),
        ...amounts.map(
          (amt) => InkWell(
            onTap: () => Navigator.pop(context, amt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: amt == selected
                    ? const Color(0xFFE8F7F1)
                    : Colors.transparent,
                border: const Border(
                  bottom: BorderSide(color: _kDivider, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$amt',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: amt == selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 16,
                        color: amt == selected ? _kGreenDark : _kTextDark,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                  if (amt == selected)
                    const Icon(Icons.check, color: _kGreen, size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── §9 Proceed button ────────────────────────────────────────────────────────
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
              'Assign support',
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
// #FAFAFA bg · 72×10 px bar · #1D1B20 · radius 8 px · 8 px from bottom
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
