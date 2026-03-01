import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../widgets/question_renderer.dart';

// ─── Spec colour tokens ───────────────────────────────────────────────────────
const Color _kGreen   = Color(0xFF18A369);
const Color _kDivider = Color(0xFFE5E5E5);
const Color _kHomeBar = Color(0xFF1D1B20);
const Color _kReqRed  = Color(0xFFD32F2F);
const Color _kLabel   = Color(0xFF1D1B20);
const Color _kTextSec = Color(0xFF49454F);

// ─── Section data model ───────────────────────────────────────────────────────
class _SurveySection {
  final String title;
  final String description;
  final List<Question> questions;

  const _SurveySection({
    required this.title,
    required this.description,
    required this.questions,
  });
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class SurveyScreen extends StatefulWidget {
  final FormModel form;

  const SurveyScreen({super.key, required this.form});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final Map<String, dynamic> _answers = {};
  bool _saving = false;
  int _currentSection = 0;

  late final List<_SurveySection> _sections;

  /// Cumulative question count before each section (for global numbering).
  late final List<int> _sectionOffsets;

  // ── Init ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _sections = _parseSections();
    _computeOffsets();
  }

  // ── Parse: split questions at every QuestionType.section divider ───────────
  List<_SurveySection> _parseSections() {
    final sorted = widget.form.questions.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final sections = <_SurveySection>[];
    String curTitle = widget.form.title;
    String curDesc  = widget.form.description;
    final curQs     = <Question>[];

    for (final q in sorted) {
      if (q.type == QuestionType.section) {
        // Flush accumulated questions into a section
        if (curQs.isNotEmpty) {
          sections.add(_SurveySection(
            title: curTitle,
            description: curDesc,
            questions: List.from(curQs),
          ));
          curQs.clear();
        }
        // The section question itself becomes the next header
        curTitle = q.question;
        curDesc  = q.sectionDescription ?? '';
      } else {
        curQs.add(q);
      }
    }

    // Flush the last (or only) group
    if (curQs.isNotEmpty) {
      sections.add(_SurveySection(
        title: curTitle,
        description: curDesc,
        questions: List.from(curQs),
      ));
    }

    // Guard: if the form had only section-type questions and no others
    if (sections.isEmpty) {
      return [
        _SurveySection(
          title: widget.form.title,
          description: widget.form.description,
          questions: const [],
        )
      ];
    }

    return sections;
  }

  void _computeOffsets() {
    _sectionOffsets = [];
    int offset = 0;
    for (final s in _sections) {
      _sectionOffsets.add(offset);
      offset += s.questions.length;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  bool _isEmpty(dynamic v) {
    if (v == null) return true;
    if (v is String) return v.trim().isEmpty;
    if (v is List) return v.isEmpty;
    return false;
  }

  /// Required questions unanswered in the visible section only.
  List<Question> _missingInSection(int sectionIndex) {
    return _sections[sectionIndex]
        .questions
        .where((q) => q.required && _isEmpty(_answers[q.id]))
        .toList();
  }

  /// Required questions unanswered across the whole form (used on final save).
  List<Question> _missingAllRequired() {
    return widget.form.questions
        .where((q) => q.required && _isEmpty(_answers[q.id]))
        .toList();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _goNext() {
    final missing = _missingInSection(_currentSection);
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${missing.length} required '
            '${missing.length == 1 ? 'question' : 'questions'} '
            'need an answer before continuing.',
          ),
          backgroundColor: _kReqRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _currentSection++);
  }

  void _goPrev() {
    if (_currentSection > 0) {
      setState(() => _currentSection--);
    } else {
      Navigator.maybePop(context);
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    final missing = _missingAllRequired();
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${missing.length} required '
            '${missing.length == 1 ? 'question' : 'questions'} '
            'still need an answer.',
          ),
          backgroundColor: _kReqRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final response = SurveyResponse(
      id: const Uuid().v4(),
      formId: widget.form.id,
      formTitle: widget.form.title,
      savedAt: DateTime.now(),
      synced: false,
      answers: Map<String, dynamic>.from(_answers),
    );

    await StorageService.instance.saveResponse(response);
    setState(() => _saving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Survey saved offline. Will sync when connected.'),
        backgroundColor: _kGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isFirst      = _currentSection == 0;
    final isLast       = _currentSection == _sections.length - 1;
    final section      = _sections[_currentSection];
    final offset       = _sectionOffsets[_currentSection];
    final totalSections = _sections.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _kGreen,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kGreen,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            // §1  Status bar (52 px)
            const _FakeStatusBar(),

            // §2  App bar (64 px) — back arrow navigates sections or exits
            _SurveyAppBar(
              title: widget.form.title,
              onBack: _goPrev,
            ),

            // §3  White content area
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section header (progress + title + description)
                    _SectionHeader(
                      sectionTitle: section.title,
                      description: section.description,
                      currentIndex: _currentSection,
                      totalSections: totalSections,
                    ),

                    // Scrollable question list — ValueKey forces scroll-to-top
                    // on every section switch
                    Expanded(
                      child: ListView.separated(
                        key: ValueKey(_currentSection),
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: section.questions.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: _kDivider,
                        ),
                        itemBuilder: (ctx, i) {
                          final q = section.questions[i];
                          return QuestionRenderer(
                            question: q,
                            index: offset + i + 1, // global question number
                            value: _answers[q.id],
                            onChanged: (v) =>
                                setState(() => _answers[q.id] = v),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // §4/5  Navigation bar + home indicator
            _NavBar(
              isFirst: isFirst,
              isLast: isLast,
              saving: _saving,
              onBack: _goPrev,
              onNext: isLast ? _save : _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// §1  Fake status bar (52 px)
// ═══════════════════════════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════════════════════════
// §2  Survey app bar (64 px) — title = form title, back navigates sections
// ═══════════════════════════════════════════════════════════════════════════════
class _SurveyAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _SurveyAppBar({required this.title, required this.onBack});

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
              padding: const EdgeInsets.all(8),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.15,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Section header — progress dots + section title + description
// ═══════════════════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String sectionTitle;
  final String description;
  final int currentIndex;
  final int totalSections;

  const _SectionHeader({
    required this.sectionTitle,
    required this.description,
    required this.currentIndex,
    required this.totalSections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Progress row (only for multi-section forms) ──────────────────
          if (totalSections > 1) ...[
            Row(
              children: [
                // Animated dots
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(totalSections, (i) {
                        final isActive = i == currentIndex;
                        final isPast   = i < currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: isActive ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: (isActive || isPast)
                                ? _kGreen
                                : _kDivider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Counter  "2 of 5"
                Text(
                  '${currentIndex + 1} of $totalSections',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    color: _kTextSec,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // ── Section title ────────────────────────────────────────────────
          Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: _kLabel,
              height: 1.3,
            ),
          ),

          // ── Section description (optional) ───────────────────────────────
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: _kTextSec,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 12),
          // Full-width divider separating the header from the first question
          const Divider(height: 1, thickness: 1, color: _kDivider),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Navigation bar + home indicator
//
// Layout:
//   • Single-section forms  : just [SAVE SURVEY]
//   • First section          : just [NEXT →]
//   • Middle sections        : [← BACK]   [NEXT →]
//   • Last section           : [← BACK]   [SAVE SURVEY]
// ═══════════════════════════════════════════════════════════════════════════════
class _NavBar extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool saving;
  final VoidCallback onBack;

  /// Called for both "Next" and "Save" — the parent decides the action.
  final VoidCallback onNext;

  const _NavBar({
    required this.isFirst,
    required this.isLast,
    required this.saving,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top border
          const Divider(height: 1, thickness: 1, color: _kDivider),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                // Back button — hidden on the very first section
                if (!isFirst) ...[
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: saving ? null : onBack,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kGreen,
                          side: const BorderSide(color: _kGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text(
                          'BACK',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Next / Save button
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: saving ? null : onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            _kGreen.withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isLast ? 'SAVE SURVEY' : 'NEXT',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.25,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Home indicator pill
          Container(
            height: 28,
            color: Colors.white,
            alignment: Alignment.center,
            child: Container(
              width: 72,
              height: 10,
              decoration: BoxDecoration(
                color: _kHomeBar,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
