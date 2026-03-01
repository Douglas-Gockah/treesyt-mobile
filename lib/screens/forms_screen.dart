import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../models/mock_data.dart';
import 'survey_screen.dart';

// ─── Spec-exact colour palette ───────────────────────────────────────────────
const Color _kGreen      = Color(0xFF18A369); // Primary green
const Color _kBgGray     = Color(0xFFFAFAFA); // Background gray (bottom indicator)
const Color _kBorderGray = Color(0xFFE6E0E9); // Tab-section bottom border
const Color _kDivGray    = Color(0xFFE5E5E5); // Dividers between form items
const Color _kTabActive  = Color(0xFF1D1B20); // Active tab label / text primary
const Color _kTabInact   = Color(0xFF49454F); // Inactive tab label
const Color _kItemText   = Color(0xFF171717); // Form item title & subtitle
const Color _kHomeBar    = Color(0xFF1D1B20); // Bottom indicator pill

// ─── Screen ──────────────────────────────────────────────────────────────────
class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final forms = kMockForms;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _kGreen,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kGreen,
        body: Column(
          children: [
            // §1 — Status bar (0–52 px)
            const _FakeStatusBar(),
            // §2 — Top app bar (52–116 px)
            _FormsAppBar(),
            // White sheet fills remaining space (116 px onwards)
            Expanded(
              child: Container(
                color: Colors.white,
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // §3 — Tabs (48 px + 1 px divider)
                      const _FormsTabBar(),
                      // §4/5 — Scrollable content
                      Expanded(
                        child: TabBarView(
                          children: [
                            _FormsListTab(forms: forms),
                            const _GoogleFormsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // §6 — Bottom navigation indicator (28 px, #FAFAFA)
            const _BottomIndicator(),
          ],
        ),
      ),
    );
  }
}

// ─── §1  Fake status bar (52 px) ─────────────────────────────────────────────
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
              letterSpacing: 0.14,
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

// ─── §2  Top app bar (64 px) ─────────────────────────────────────────────────
class _FormsAppBar extends StatelessWidget {
  const _FormsAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: _kGreen,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Back button — 48×48 tappable area, 8 px icon padding
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              padding: const EdgeInsets.all(8),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          const SizedBox(width: 4),
          // Title
          const Expanded(
            child: Text(
              'Forms',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.15,
              ),
            ),
          ),
          // Trailing empty space to balance the leading icon (48 px)
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ─── §3  Tab bar (48 px + 1 px divider) ──────────────────────────────────────
class _FormsTabBar extends StatelessWidget {
  const _FormsTabBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 48,
          child: TabBar(
            labelColor: _kTabActive,
            unselectedLabelColor: _kTabInact,
            indicatorColor: _kGreen,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.tab,
            // Suppress TabBar's own bottom divider — we draw ours below
            dividerColor: Colors.transparent,
            labelPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.25,
              height: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.25,
              height: 1.5,
            ),
            tabs: const [
              Tab(text: 'Forms list'),
              Tab(text: 'Google forms'),
            ],
          ),
        ),
        // 1 px bottom divider (spec: #E6E0E9)
        const Divider(height: 1, thickness: 1, color: _kBorderGray),
      ],
    );
  }
}

// ─── §4/5  Forms list tab ────────────────────────────────────────────────────
class _FormsListTab extends StatelessWidget {
  final List<FormModel> forms;

  const _FormsListTab({required this.forms});

  @override
  Widget build(BuildContext context) {
    if (forms.isEmpty) return const _EmptyState();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: forms.length,
      // 16 px gap with 1 px divider centred inside it (7.5 + 1 + 7.5 = 16 px)
      separatorBuilder: (_, __) =>
          const Divider(height: 16, thickness: 1, color: _kDivGray),
      itemBuilder: (context, i) {
        final form = forms[i];
        return _FormItem(
          form: form,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SurveyScreen(form: form)),
          ),
        );
      },
    );
  }
}

// ─── Form item row ────────────────────────────────────────────────────────────
class _FormItem extends StatelessWidget {
  final FormModel form;
  final VoidCallback onTap;

  const _FormItem({required this.form, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final qCount = form.questionCount;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        // spec: 8px top, 16px bottom, 16px horizontal
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title — Inter Medium 16px, #171717, line-height 24, ls 0.15
            Text(
              form.title,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: _kItemText,
                height: 24 / 16,
                letterSpacing: 0.15,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle — Inter Regular 16px, #171717, line-height 24, ls 0.5
            Text(
              '$qCount ${qCount == 1 ? 'Question' : 'Questions'}',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: _kItemText,
                height: 24 / 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Google forms tab (placeholder) ──────────────────────────────────────────
class _GoogleFormsTab extends StatelessWidget {
  const _GoogleFormsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.open_in_browser, color: _kGreen, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Google forms linked yet!',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _kTabInact,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state (forms list) ─────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_outlined,
                color: _kGreen, size: 48),
          ),
          const SizedBox(height: 20),
          const Text(
            'No forms available yet!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _kTabInact,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── §6  Bottom navigation indicator (28 px, #FAFAFA) ────────────────────────
class _BottomIndicator extends StatelessWidget {
  const _BottomIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      color: _kBgGray,
      alignment: Alignment.center,
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
