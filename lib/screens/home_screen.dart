import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';
import 'forms_screen.dart';

// ─── Spec-exact colour palette ───────────────────────────────────────────────
const Color _kGreen       = Color(0xFF18A369);
const Color _kBgGray      = Color(0xFFFAFAFA);
const Color _kBorderGray  = Color(0xFFE5E5E5);
const Color _kTextPrimary = Color(0xFF171717);
const Color _kTextSec     = Color(0xFF737373);
const Color _kHomeBar     = Color(0xFF1D1B20);

// ─── Module data ─────────────────────────────────────────────────────────────
class _Module {
  final IconData icon;
  final String label;
  final bool highlighted;

  const _Module({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });
}

const List<_Module> _kModules = [
  _Module(icon: Icons.people_alt_outlined,     label: 'Profiling'),
  _Module(icon: Icons.park_outlined,           label: 'Green Tracker'),
  _Module(icon: Icons.agriculture_outlined,    label: 'Farmer Support'),
  _Module(icon: Icons.badge_outlined,          label: 'Trainings'),
  _Module(icon: Icons.shopping_cart_outlined,  label: 'Purchases'),
  _Module(icon: Icons.edit_document,           label: 'Forms'),
  _Module(
    icon: Icons.warehouse_outlined,
    label: 'Warehouse activity',
    highlighted: true,
  ),
];

// ─── Screen ──────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: _kGreen,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void _onModuleTap(_Module module) {
    if (module.label == 'Forms') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FormsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgGray,
      body: Column(
        children: [
          const _FakeStatusBar(),
          const _HomeAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const _WelcomeCard(),
                    const SizedBox(height: 16),
                    _MenuList(onTap: _onModuleTap),
                  ],
                ),
              ),
            ),
          ),
          _HomeBottomNav(
            index: _navIndex,
            onTap: (i) => setState(() => _navIndex = i),
          ),
        ],
      ),
    );
  }
}

// ─── Fake status bar (52 px, spec §1) ────────────────────────────────────────
class _FakeStatusBar extends StatelessWidget {
  const _FakeStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: _kGreen,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Left — time
          const Text(
            '9:30',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
          // Centre — camera cutout
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
          // Right — status icons
          const Icon(Icons.wifi, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          const Icon(Icons.signal_cellular_4_bar,
              color: Colors.white, size: 16),
          const SizedBox(width: 4),
          const Icon(Icons.battery_full, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}

// ─── Top app bar (64 px, spec §2) ────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: _kGreen,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          // Menu icon
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 24),
            onPressed: () {},
          ),
          // Title
          const Expanded(
            child: Text(
              'Home',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Profile avatar
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white24,
              child: const Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Welcome card (124 px, spec §3) ──────────────────────────────────────────
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 124,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hello Joseph',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 28 / 22,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Welcome to TreeSyt',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Menu list (spec §4) ─────────────────────────────────────────────────────
class _MenuList extends StatelessWidget {
  final void Function(_Module) onTap;

  const _MenuList({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _kBorderGray),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Column(
          children: [
            for (int i = 0; i < _kModules.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, thickness: 1, color: _kBorderGray),
              _MenuItemRow(
                module: _kModules[i],
                onTap: () => onTap(_kModules[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  final _Module module;
  final VoidCallback onTap;

  const _MenuItemRow({required this.module, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        color: module.highlighted ? _kBgGray : Colors.white,
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(module.icon, color: _kTextSec, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  module.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: _kTextPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: _kTextSec, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom navigation bar (spec §5) ─────────────────────────────────────────
class _HomeBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _HomeBottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1, color: _kBorderGray),
          SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavTab(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  active: index == 0,
                  onTap: () => onTap(0),
                ),
                _NavTab(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Insights',
                  active: index == 1,
                  onTap: () => onTap(1),
                ),
                _NavTab(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'Notifications',
                  active: index == 2,
                  onTap: () => onTap(2),
                ),
              ],
            ),
          ),
          // Home indicator bar (72×10 px, spec §5)
          Container(
            width: 72,
            height: 10,
            margin: const EdgeInsets.only(top: 9, bottom: 9),
            decoration: BoxDecoration(
              color: _kHomeBar,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? _kTextPrimary : _kTextSec;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: active ? 'Inter' : 'Roboto',
                fontWeight: active ? FontWeight.w400 : FontWeight.w500,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
