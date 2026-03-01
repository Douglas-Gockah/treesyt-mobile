import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'farmer_selection_screen.dart';

// ─── Colours (spec-exact) ─────────────────────────────────────────────────────
const Color _kGreen       = Color(0xFF18A369);
const Color _kGreenLight  = Color(0xFFE8F5F1);  // community tag background
const Color _kDivider     = Color(0xFFE5E5E5);
const Color _kHomeBar     = Color(0xFF1D1B20);

// Status colours
const Color _kStatusGreen  = Color(0xFF18A369);
const Color _kStatusOrange = Color(0xFFF59E0B);
const Color _kStatusRed    = Color(0xFFEF4444);
const Color _kStatusGray   = Color(0xFF9CA3AF);

// ─── Group status enum ────────────────────────────────────────────────────────
enum _Status { submitted, pending, incomplete, processed }

extension _StatusX on _Status {
  Color get color => switch (this) {
    _Status.submitted  => _kStatusGreen,
    _Status.pending    => _kStatusOrange,
    _Status.incomplete => _kStatusRed,
    _Status.processed  => _kStatusGray,
  };

  String get label => switch (this) {
    _Status.submitted  => 'Request submitted',
    _Status.pending    => 'Tap to record request',
    _Status.incomplete => 'Tap to complete request',
    _Status.processed  => 'Processed',
  };
}

// ─── Data model ───────────────────────────────────────────────────────────────
class _Group {
  final String name;
  final String type;
  final _Status status;

  const _Group({required this.name, required this.type, required this.status});
}

const List<_Group> _kGroups = [
  _Group(name: 'Northern Star Farmers',      type: 'VSLA Group',    status: _Status.submitted),
  _Group(name: 'Jirapa Fields Cooperative',  type: 'VSLA Group',    status: _Status.pending),
  _Group(name: 'Afari simpa',                type: 'Farmer Group',  status: _Status.pending),
  _Group(name: 'Tumu Prosper Farmers Guild', type: 'Farmer Group',  status: _Status.incomplete),
  _Group(name: 'Northern Star Farmers',      type: 'VSLA Group',    status: _Status.submitted),
  _Group(name: 'Unity Fields Network',       type: 'VSLA Group',    status: _Status.processed),
  _Group(name: 'Tumu Prosper Farmers Guild', type: 'Farmer Group',  status: _Status.incomplete),
  _Group(name: 'Afari simpa',                type: 'Farmer Group',  status: _Status.pending),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class RecordSupportScreen extends StatefulWidget {
  const RecordSupportScreen({super.key});

  @override
  State<RecordSupportScreen> createState() => _RecordSupportScreenState();
}

class _RecordSupportScreenState extends State<RecordSupportScreen> {
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

  List<_Group> get _filtered => _kGroups
      .where(
        (g) =>
            g.name.toLowerCase().contains(_query) ||
            g.type.toLowerCase().contains(_query),
      )
      .toList();

  void _openGroupFarmers(BuildContext ctx, _Group group) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => FarmerSelectionScreen(groupName: group.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _filtered;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Non-scrollable header block ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // §4 Header text
                          const Text(
                            'Select group to record needs',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black,
                              letterSpacing: 0.1,
                              height: 20 / 14,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // §5 Filters button (left-aligned, inline)
                          const _FiltersButton(),

                          // §6 Community tag (16 px top + bottom margins)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: _CommunityTag(),
                          ),

                          // §7 Search bar
                          _GroupSearchBar(controller: _searchCtrl),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // §8 Scrollable farmer groups list
                    Expanded(
                      child: groups.isEmpty
                          ? const _EmptyState()
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: groups.length,
                              itemBuilder: (ctx, i) => _GroupRow(
                                group: groups[i],
                                onTap: () => _openGroupFarmers(ctx, groups[i]),
                              ),
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

// ─── §5 Filters button ────────────────────────────────────────────────────────
class _FiltersButton extends StatelessWidget {
  const _FiltersButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter/sliders icon — Icons.tune matches the 3-line-with-dot spec
            const Icon(Icons.tune, color: _kGreen, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Filters',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: _kGreen,
                height: 20 / 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── §6 Community tag pill ────────────────────────────────────────────────────
class _CommunityTag extends StatelessWidget {
  const _CommunityTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _kGreenLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Community: Achubunyor',
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: _kGreen,
          height: 20 / 14,
        ),
      ),
    );
  }
}

// ─── §7 Search bar ────────────────────────────────────────────────────────────
class _GroupSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _GroupSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.black,
          height: 20 / 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search group',
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF888888),
            height: 20 / 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF888888),
            size: 20,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 48,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
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

// ─── §8 Farmer group list row ─────────────────────────────────────────────────
class _GroupRow extends StatelessWidget {
  final _Group group;
  final VoidCallback onTap;

  const _GroupRow({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _kDivider, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: name + type + status (flex 1)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group name — Inter Medium 16 px
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                      letterSpacing: 0.15,
                      height: 24 / 16,
                    ),
                  ),

                  // Group type — Inter Regular 14 px #737373
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      group.type,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF737373),
                        letterSpacing: 0.25,
                        height: 20 / 14,
                      ),
                    ),
                  ),

                  // Status text — Inter Medium 14 px, colour by status
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      group.status.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: group.status.color,
                        letterSpacing: 0.25,
                        height: 20 / 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right: chevron — 24×24 container, 20 px icon, #D1D5DB
            const SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: Icon(
                  Icons.chevron_right,
                  color: Color(0xFFD1D5DB),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
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
            'No groups found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF737373),
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
          // Time
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
          // Camera cutout
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          // Status icons
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
          // Back button — 48×48
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
          // Title
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
          // Trailing placeholder
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}

// ─── Bottom indicator — 28 px (spec §10) ─────────────────────────────────────
// Home bar: 134×5 px, #1D1B20, border-radius 100, 8 px from bottom
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
