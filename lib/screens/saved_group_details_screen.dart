import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'farmer_selection_screen.dart' show SelectedFarmer;

// ─── Colours (spec-exact) ─────────────────────────────────────────────────────
const Color _kGreen        = Color(0xFF18A369);
const Color _kDivider      = Color(0xFFE5E5E5);
const Color _kHomeBar      = Color(0xFF1D1B20);
const Color _kTextDark     = Color(0xFF171717);
const Color _kTextGray     = Color(0xFF696969);
const Color _kTextLtGray   = Color(0xFFA3A3A3);
const Color _kSearchBorder = Color(0xFFD0D5DD);

// ─── Screen ───────────────────────────────────────────────────────────────────
/// Confirmation / review screen showing the farmers the user just selected.
///
/// Navigation:
///   "Edit list"      → Navigator.pop — returns to [FarmerSelectionScreen]
///                      with its state (checked farmers) still intact.
///   "Select support" → pushes the next step in the flow (stub for now).
class SavedGroupDetailsScreen extends StatefulWidget {
  final String groupName;
  final List<SelectedFarmer> selectedFarmers;
  final int totalFarmers;

  const SavedGroupDetailsScreen({
    super.key,
    required this.groupName,
    required this.selectedFarmers,
    required this.totalFarmers,
  });

  @override
  State<SavedGroupDetailsScreen> createState() =>
      _SavedGroupDetailsScreenState();
}

class _SavedGroupDetailsScreenState extends State<SavedGroupDetailsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
      () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SelectedFarmer> get _filtered => widget.selectedFarmers
      .where(
        (f) =>
            f.name.toLowerCase().contains(_query) ||
            f.farmerId.toLowerCase().contains(_query),
      )
      .toList();

  // "Edit list" — pop back to FarmerSelectionScreen (its _selected state
  // is still alive on the Navigator stack, so the user sees their previous
  // choices already ticked).
  void _editList() => Navigator.pop(context);

  // "Select support" — proceed to next step (stub until that screen exists).
  void _selectSupport() {
    debugPrint(
      '[SavedGroupDetails] Proceeding — '
      '${widget.selectedFarmers.length} farmers in ${widget.groupName}',
    );
    // TODO: Navigator.push to SupportSelectionScreen
  }

  @override
  Widget build(BuildContext context) {
    final farmers = _filtered;

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
                    // ── Non-scrollable header block ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Column(
                        children: [
                          // §4 Group name — centred, Inter Medium 16 px
                          Text(
                            widget.groupName,
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

                          const SizedBox(height: 24),

                          // Selection counter — centred inline
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.selectedFarmers.length} of '
                                '${widget.totalFarmers}',
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

                          // §5 Divider with 16 px vertical margins
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: _kDivider,
                            ),
                          ),

                          // §6 Search bar — 44 px
                          _SearchBar(controller: _searchCtrl),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Hairline divider above list
                    const Divider(height: 1, thickness: 1, color: _kDivider),

                    // §7 Scrollable selected-farmers list
                    Expanded(
                      child: farmers.isEmpty
                          ? const _EmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                16,
                              ),
                              itemCount: farmers.length,
                              itemBuilder: (_, i) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: i < farmers.length - 1 ? 16 : 0,
                                ),
                                child: _FarmerCard(farmer: farmers[i]),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // §9 Two fixed bottom buttons
            _BottomButtons(
              onEdit: _editList,
              onProceed: _selectSupport,
            ),

            // §10 Bottom indicator · 28 px
            const _BottomIndicator(),
          ],
        ),
      ),
    );
  }
}

// ─── §7 Farmer display card (no checkbox — review only) ───────────────────────
class _FarmerCard extends StatelessWidget {
  final SelectedFarmer farmer;

  const _FarmerCard({required this.farmer});

  @override
  Widget build(BuildContext context) {
    final parts = farmer.name.split(' ');
    final initials = parts.take(2).map((w) => w[0].toUpperCase()).join();

    return SizedBox(
      height: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile avatar — 56 px circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: farmer.avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Name + Farmer ID (vertical stack, flex 1)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Farmer name — Inter Regular 16 px
                Text(
                  farmer.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                    letterSpacing: 0.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                // Farmer ID — Inter Regular 14 px, #A3A3A3
                Text(
                  'Farmers ID: ${farmer.farmerId}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: _kTextLtGray,
                    letterSpacing: 0.1,
                    height: 21 / 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── §6 Search bar ────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Search farmer',
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: _kTextLtGray,
            height: 20 / 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: _kTextGray,
            size: 20,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kSearchBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kSearchBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kGreen, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─── §9 Two-button footer ─────────────────────────────────────────────────────
class _BottomButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onProceed;

  const _BottomButtons({required this.onEdit, required this.onProceed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Edit list" — outlined secondary button
          _OutlinedButton(label: 'Edit list', onTap: onEdit),
          const SizedBox(height: 8),
          // "Select support" — filled primary button
          _FilledButton(label: 'Select support', onTap: onProceed),
        ],
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlinedButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kGreen),
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
                color: _kGreen,
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

class _FilledButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilledButton({required this.label, required this.onTap});

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

// ─── Empty search state ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, color: Color(0xFF9CA3AF), size: 48),
          SizedBox(height: 16),
          Text(
            'No farmers found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF696969),
            ),
          ),
        ],
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
// Bar: 134×5 px, #1D1B20, radius 100, 8 px from bottom
class _BottomIndicator extends StatelessWidget {
  const _BottomIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      color: Colors.white,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: 134,
        height: 5,
        decoration: BoxDecoration(
          color: _kHomeBar,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
