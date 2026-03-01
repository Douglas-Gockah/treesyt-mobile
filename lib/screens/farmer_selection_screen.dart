import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'saved_group_details_screen.dart';

// ─── Public model passed to the review screen ─────────────────────────────────
class SelectedFarmer {
  final String name;
  final String farmerId;
  final Color avatarColor;

  const SelectedFarmer({
    required this.name,
    required this.farmerId,
    required this.avatarColor,
  });
}

// ─── Colours (spec-exact) ─────────────────────────────────────────────────────
const Color _kGreen        = Color(0xFF18A369);
const Color _kDivider      = Color(0xFFE5E5E5);
const Color _kHomeBar      = Color(0xFF1D1B20);
const Color _kTextDark     = Color(0xFF171717);
const Color _kTextGray     = Color(0xFF696969);
const Color _kTextLtGray   = Color(0xFFA3A3A3);
const Color _kTextMedGray  = Color(0xFF262626);
const Color _kSearchBorder = Color(0xFFD0D5DD);
const Color _kCbBorder     = Color(0xFF696969);
const Color _kDisabledBg   = Color(0xFFF5F5F5);
const Color _kDisabledText = Color(0xFF737373);

// ─── Farmer data (11 spec-exact entries) ─────────────────────────────────────
class _Farmer {
  final String name;
  final String farmerId;
  const _Farmer(this.name, this.farmerId);
}

const List<_Farmer> _kFarmers = [
  _Farmer('Akansele Ayebase',     'TS1092'),
  _Farmer('Akunpule Ajuah',       'TS1092'),
  _Farmer('Akanji Cynthia',       'TS1092'),
  _Farmer('Amantoge Akassalingo', 'TS1092'),
  _Farmer('Akansube Achiibuke',   'TS1092'),
  _Farmer('Aganbogiba Anchor',    'TS1092'),
  _Farmer('Beatrice Tampuli',     'TS1092'),
  _Farmer('Musah Abu',            'TS1092'),
  _Farmer('Serwaa Ampofo',        'TS1092'),
  _Farmer('Mustafi Caleb',        'TS1092'),
  _Farmer('Winifred Adoo',        'TS1092'),
];

// Avatar background colours — one per farmer slot
const List<Color> _kAvatarBg = [
  Color(0xFF4A90D9),   // Akansele   — blue
  Color(0xFF27AE60),   // Akunpule   — green
  Color(0xFFE74C3C),   // Akanji     — red
  Color(0xFF8E44AD),   // Amantoge   — purple
  Color(0xFFF39C12),   // Akansube   — amber
  Color(0xFF16A085),   // Aganbogiba — teal
  Color(0xFFE91E63),   // Beatrice   — pink
  Color(0xFF1565C0),   // Musah      — dark blue
  Color(0xFF43A047),   // Serwaa     — mid green
  Color(0xFFD84315),   // Mustafi    — deep orange
  Color(0xFF6A1B9A),   // Winifred   — deep purple
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class FarmerSelectionScreen extends StatefulWidget {
  final String groupName;

  const FarmerSelectionScreen({super.key, required this.groupName});

  @override
  State<FarmerSelectionScreen> createState() => _FarmerSelectionScreenState();
}

class _FarmerSelectionScreenState extends State<FarmerSelectionScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  final Set<int> _selected = {}; // indices into _kFarmers

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

  // Indices of farmers matching current search query
  List<int> get _visibleIdx => List.generate(_kFarmers.length, (i) => i)
      .where(
        (i) =>
            _kFarmers[i].name.toLowerCase().contains(_query) ||
            _kFarmers[i].farmerId.toLowerCase().contains(_query),
      )
      .toList();

  bool get _allVisible =>
      _visibleIdx.isNotEmpty && _visibleIdx.every(_selected.contains);

  bool get _partialVisible =>
      _visibleIdx.any(_selected.contains) &&
      !_visibleIdx.every(_selected.contains);

  void _toggleAll() {
    final vis = _visibleIdx;
    setState(() {
      if (_allVisible) {
        _selected.removeAll(vis);
      } else {
        _selected.addAll(vis);
      }
    });
  }

  void _toggle(int i) => setState(() {
        _selected.contains(i) ? _selected.remove(i) : _selected.add(i);
      });

  void _save() {
    if (_selected.isEmpty) return;
    // Build ordered list (by original farmer index) for the review screen
    final ordered = (_selected.toList()..sort())
        .map(
          (i) => SelectedFarmer(
            name: _kFarmers[i].name,
            farmerId: _kFarmers[i].farmerId,
            avatarColor: _kAvatarBg[i],
          ),
        )
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedGroupDetailsScreen(
          groupName: widget.groupName,
          selectedFarmers: ordered,
          totalFarmers: _kFarmers.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vis = _visibleIdx;

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // §4 Page header
                          const Text(
                            'Select interested farmers',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: _kTextMedGray,
                              letterSpacing: 0.5,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // §5 Group name — centred, Inter Medium 16 px
                          Center(
                            child: Text(
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
                          ),

                          const SizedBox(height: 24), // gap: 24 px

                          // Selection counter — centred inline
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_selected.length} of ${_kFarmers.length}',
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
                          ),

                          // §6 Divider with 16 px vertical margins
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: _kDivider,
                            ),
                          ),

                          // §7 Search bar — 44 px, border #D0D5DD
                          _FarmerSearchBar(controller: _searchCtrl),

                          const SizedBox(height: 16),

                          // §8 Farmer list header
                          _ListHeader(
                            allSelected: _allVisible,
                            partial: _partialVisible,
                            onSelectAll: _toggleAll,
                          ),
                        ],
                      ),
                    ),

                    // Hairline divider above list
                    const Divider(height: 1, thickness: 1, color: _kDivider),

                    // §9 Scrollable farmer list
                    Expanded(
                      child: vis.isEmpty
                          ? const _EmptyList()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                16,
                              ),
                              itemCount: vis.length,
                              itemBuilder: (_, i) {
                                final idx = vis[i];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i < vis.length - 1 ? 8 : 0,
                                  ),
                                  child: _FarmerRow(
                                    farmer: _kFarmers[idx],
                                    avatarColor: _kAvatarBg[idx],
                                    checked: _selected.contains(idx),
                                    onTap: () => _toggle(idx),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // §11 Fixed bottom button — white bg, 16 px padding, 44 px button
            _BottomButton(
              enabled: _selected.isNotEmpty,
              onPressed: _save,
            ),

            // §12 Bottom indicator — 28 px
            const _BottomIndicator(),
          ],
        ),
      ),
    );
  }
}

// ─── §8 Farmer list header ────────────────────────────────────────────────────
class _ListHeader extends StatelessWidget {
  final bool allSelected;
  final bool partial;
  final VoidCallback onSelectAll;

  const _ListHeader({
    required this.allSelected,
    required this.partial,
    required this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left — "Farmer list"
        const Expanded(
          child: Text(
            'Farmer list',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: _kTextGray,
              letterSpacing: 0.5,
              height: 1.5,
            ),
          ),
        ),

        // Right — "Select all" + checkbox (tap both)
        GestureDetector(
          onTap: onSelectAll,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              const Text(
                'Select all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: _kGreen,
                  letterSpacing: 0.15,
                  height: 24 / 16,
                ),
              ),
              const SizedBox(width: 4),
              // 48×48 container, 18×18 checkbox inside
              _SpecCheckbox(
                checked: allSelected,
                indeterminate: partial,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── §9 Individual farmer row (56 px tall) ────────────────────────────────────
class _FarmerRow extends StatelessWidget {
  final _Farmer farmer;
  final Color avatarColor;
  final bool checked;
  final VoidCallback onTap;

  const _FarmerRow({
    required this.farmer,
    required this.avatarColor,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Initials: first letter of each of the first two words
    final parts = farmer.name.split(' ');
    final initials =
        parts.take(2).map((w) => w[0].toUpperCase()).join();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 56,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile avatar — 56 px circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: avatarColor,
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

            // 16 px gap
            const SizedBox(width: 16),

            // Name + Farmer ID (vertical stack, flex 1)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Farmer name — Inter Regular 16 px, black
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
                  // 4 px gap
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

            // Right — 48×48 checkbox container
            _SpecCheckbox(checked: checked),
          ],
        ),
      ),
    );
  }
}

// ─── Custom spec-exact checkbox ───────────────────────────────────────────────
// Container: 48×48 px
// Inner box:  18×18 px, 2 px border, radius 2 px
// Checked     → green fill + white check
// Indeterminate → green fill + white dash (select-all partial state)
// Unchecked   → white fill + #696969 border
class _SpecCheckbox extends StatelessWidget {
  final bool checked;
  final bool indeterminate;

  const _SpecCheckbox({
    required this.checked,
    this.indeterminate = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = checked || indeterminate;

    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: active ? _kGreen : Colors.white,
            border: Border.all(
              color: active ? _kGreen : _kCbBorder,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: active
              ? Center(
                  child: Icon(
                    indeterminate ? Icons.remove : Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

// ─── §7 Search bar — 44 px, spec border/padding ───────────────────────────────
class _FarmerSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _FarmerSearchBar({required this.controller});

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

// ─── Empty list state ─────────────────────────────────────────────────────────
class _EmptyList extends StatelessWidget {
  const _EmptyList();

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
              color: _kTextGray,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── §11 Bottom button — fixed, white bg, 16 px padding, 44 px button ─────────
// Disabled  → #F5F5F5 bg, #737373 text @ 38% opacity, not tappable
// Active    → #18A369 bg, white text, tappable
class _BottomButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _BottomButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? _kGreen : _kDisabledBg,
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
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(6),
            child: Center(
              child: Text(
                'Save details',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 0.15,
                  height: 24 / 16,
                  color: enabled
                      ? Colors.white
                      : _kDisabledText.withOpacity(0.38),
                ),
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

// ─── Bottom indicator — 28 px (spec §12) ─────────────────────────────────────
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
