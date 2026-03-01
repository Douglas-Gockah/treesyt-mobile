import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

// ─── Spec-exact colour tokens ─────────────────────────────────────────────────
const Color _kGreen       = Color(0xFF18A369); // Primary green
const Color _kBorder      = Color(0xFF79747E); // Input / upload border
const Color _kPlaceholder = Color(0xFFA8A8A8); // Placeholder text
const Color _kLabelText   = Color(0xFF1D1B20); // Question label
const Color _kInputText   = Color(0xFF171717); // Input text & option labels
const Color _kCbBorder    = Color(0xFFC5C5C5); // Unchecked radio / checkbox
const Color _kChipBg      = Color(0xFFE8F5F1); // Location chip background
const Color _kGreenLight  = Color(0xFFE8F5EE); // Captured-state background
const Color _kReqRed      = Color(0xFFD32F2F); // Required asterisk
const Color _kDivider     = Color(0xFFE5E5E5); // Between-item dividers
const Color _kTextSec     = Color(0xFF49454F); // Secondary / helper text
const Color _kFillOff     = Color(0xFFF5F5F5); // Read-only field fill

// ─── Shared input decoration ─────────────────────────────────────────────────
InputDecoration _inputDec({String? hint, Widget? suffix, bool disabled = false}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      fontSize: 16,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      color: _kPlaceholder,
    ),
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    filled: true,
    fillColor: disabled ? _kFillOff : Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: _kBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: _kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: _kGreen, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: _kBorder),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );
}

const TextStyle _inputStyle = TextStyle(
  fontSize: 16,
  fontFamily: 'Inter',
  fontWeight: FontWeight.w400,
  color: _kInputText,
);

// ─── Factory ──────────────────────────────────────────────────────────────────

/// Factory widget — picks the correct input widget for a [Question].
class QuestionRenderer extends StatelessWidget {
  final Question question;
  final int index;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const QuestionRenderer({
    super.key,
    required this.question,
    required this.index,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // §3 spec: 16 px horizontal, 8 px vertical gives ≈16 px gap between items
      // when combined with the 1 px Divider separator in the ListView.
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuestionLabel(
            index: index,
            text: question.question,
            required: question.required,
          ),
          const SizedBox(height: 8), // label margin-bottom per spec
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    switch (question.type) {
      // ── Text ───────────────────────────────────────────────────────────────
      case QuestionType.shortText:
        return _ShortTextInput(
          value: value,
          onChanged: onChanged,
          hint: 'Enter your answer',
        );

      case QuestionType.longText:
        return _LongTextInput(value: value, onChanged: onChanged);

      // ── Numeric ────────────────────────────────────────────────────────────
      case QuestionType.number:
        return _NumberInput(value: value, onChanged: onChanged, decimal: false);

      case QuestionType.decimal:
        return _NumberInput(value: value, onChanged: onChanged, decimal: true);

      // ── Choice ─────────────────────────────────────────────────────────────
      case QuestionType.multipleChoice:
        return _MultipleChoiceInput(
          options: question.options,
          value: value,
          onChanged: onChanged,
        );

      case QuestionType.checkbox:
        return _CheckboxInput(
          options: question.options,
          value: value,
          onChanged: onChanged,
        );

      case QuestionType.yesNo:
        return _YesNoInput(value: value, onChanged: onChanged);

      // ── Date / time ────────────────────────────────────────────────────────
      case QuestionType.date:
        return _DateInput(value: value, onChanged: onChanged, context: context);

      case QuestionType.datetime:
        return _DateTimeInput(
            value: value, onChanged: onChanged, context: context);

      case QuestionType.time:
        return _TimeInput(
            value: value, onChanged: onChanged, context: context);

      // ── Dropdowns ──────────────────────────────────────────────────────────
      case QuestionType.month:
        return _DropdownTrigger(
          placeholder: 'Select month',
          selected: value?.toString(),
          options: question.options,
          onChanged: onChanged,
        );

      case QuestionType.dayOfWeek:
        return _DropdownTrigger(
          placeholder: 'Select day',
          selected: value?.toString(),
          options: question.options,
          onChanged: onChanged,
        );

      // ── Special text ───────────────────────────────────────────────────────
      case QuestionType.autoId:
        return _AutoIdInput(
          prefix: question.idPrefix ?? '',
          value: value,
          onInit: onChanged,
        );

      case QuestionType.farmerName:
        return _FarmerNameInput(value: value, onChanged: onChanged);

      // ── Media / hardware ───────────────────────────────────────────────────
      case QuestionType.image:
        return _DashedTapButton(
          label: 'Tap to upload',
          icon: Icons.photo_camera_outlined,
          value: value,
          capturedLabel: 'Photo captured — tap to redo',
          onTap: () => onChanged('photo_captured'),
        );

      case QuestionType.audio:
        return _DashedTapButton(
          label: 'Tap to record',
          icon: Icons.mic_outlined,
          value: value,
          capturedLabel: 'Audio recorded — tap to redo',
          onTap: () => onChanged('audio_recorded'),
        );

      case QuestionType.location:
        return _LocationInput(value: value, onChanged: onChanged);

      case QuestionType.barcode:
        return _DashedTapButton(
          label: 'Tap to scan',
          icon: Icons.qr_code_scanner_outlined,
          value: value,
          capturedLabel: value?.toString() ?? 'Scanned',
          onTap: () => onChanged('BARCODE-SCANNED-12345'),
        );

      case QuestionType.video:
        return _DashedTapButton(
          label: 'Tap to record video',
          icon: Icons.videocam_outlined,
          value: value,
          capturedLabel: 'Video recorded — tap to redo',
          onTap: () => onChanged('video_recorded'),
        );

      case QuestionType.fileUpload:
        return _DashedTapButton(
          label: 'Tap to upload',
          icon: Icons.upload_file_outlined,
          value: value,
          capturedLabel: value?.toString() ?? 'File uploaded',
          onTap: () => onChanged('document_uploaded.pdf'),
        );

      case QuestionType.signature:
        return _DashedTapButton(
          label: 'Tap to scan',
          icon: Icons.document_scanner_outlined,
          value: value,
          capturedLabel: 'Document scanned — tap to redo',
          onTap: () => onChanged('signature_captured'),
        );

      // ── Scale / rating ─────────────────────────────────────────────────────
      case QuestionType.rating:
        return _RatingInput(
          maxRating: question.maxRating,
          value: value,
          onChanged: onChanged,
        );

      case QuestionType.ranking:
        return _RankingInput(
          options: question.options,
          value: value,
          onChanged: onChanged,
        );

      case QuestionType.likertScale:
        return _LikertScaleInput(value: value, onChanged: onChanged);

      case QuestionType.netPromoterScore:
        return _NpsInput(value: value, onChanged: onChanged);

      // ── Contact ────────────────────────────────────────────────────────────
      case QuestionType.contactInfo:
        return _ContactInfoInput(value: value, onChanged: onChanged);

      case QuestionType.email:
        return _EmailInput(value: value, onChanged: onChanged);

      // ── Finance ────────────────────────────────────────────────────────────
      case QuestionType.currency:
        return _CurrencyInput(
          symbol: question.currencySymbol ?? 'GHS',
          value: value,
          onChanged: onChanged,
        );

      // ── Computed ───────────────────────────────────────────────────────────
      case QuestionType.calculatedField:
        return _CalculatedFieldInput(
          formula: question.calculatedFormula ?? '',
          value: value,
        );

      // ── Layout ─────────────────────────────────────────────────────────────
      case QuestionType.section:
        return _SectionDivider(description: question.sectionDescription ?? '');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared label
// ═══════════════════════════════════════════════════════════════════════════════
class _QuestionLabel extends StatelessWidget {
  final int index;
  final String text;
  final bool required;

  const _QuestionLabel({
    required this.index,
    required this.text,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500, // Inter Medium
          color: _kLabelText,
          height: 1.5,
        ),
        children: [
          TextSpan(text: '$index. $text'),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: _kReqRed),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Short text  (Q4, Q6)
// ═══════════════════════════════════════════════════════════════════════════════
class _ShortTextInput extends StatefulWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String hint;
  final TextInputType keyboardType;

  const _ShortTextInput({
    required this.value,
    required this.onChanged,
    this.hint = 'Enter your answer',
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_ShortTextInput> createState() => _ShortTextInputState();
}

class _ShortTextInputState extends State<_ShortTextInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: widget.keyboardType,
      style: _inputStyle,
      decoration: _inputDec(hint: widget.hint),
      onChanged: widget.onChanged,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Long text  (Q5)
// ═══════════════════════════════════════════════════════════════════════════════
class _LongTextInput extends StatefulWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _LongTextInput({required this.value, required this.onChanged});

  @override
  State<_LongTextInput> createState() => _LongTextInputState();
}

class _LongTextInputState extends State<_LongTextInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      maxLines: null,
      minLines: 4, // ≈88 px at 16/24 line-height
      style: _inputStyle,
      decoration: _inputDec(hint: 'Enter feedback').copyWith(
        alignLabelWithHint: true,
      ),
      onChanged: widget.onChanged,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Number / decimal  (Q7, Q8)
// ═══════════════════════════════════════════════════════════════════════════════
class _NumberInput extends StatefulWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool decimal;

  const _NumberInput({
    required this.value,
    required this.onChanged,
    required this.decimal,
  });

  @override
  State<_NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<_NumberInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: TextInputType.numberWithOptions(
        decimal: widget.decimal,
        signed: false,
      ),
      inputFormatters: [
        if (widget.decimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      style: _inputStyle,
      decoration: _inputDec(
        hint: widget.decimal ? 'Enter amount (e.g., 50.00)' : 'Enter a number',
      ),
      onChanged: widget.onChanged,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Custom radio dot  (shared by multipleChoice, yesNo)
// ═══════════════════════════════════════════════════════════════════════════════
class _SpecRadio extends StatelessWidget {
  final bool selected;

  const _SpecRadio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _kGreen : Colors.white,
        border: selected ? null : Border.all(color: _kCbBorder, width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Custom checkbox  (shared by checkbox type)
// ═══════════════════════════════════════════════════════════════════════════════
class _SpecCheckbox extends StatelessWidget {
  final bool checked;

  const _SpecCheckbox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: checked ? _kGreen : Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: checked ? null : Border.all(color: _kCbBorder, width: 2),
      ),
      child: checked
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Multiple choice — vertical radio list  (Q1)
// ═══════════════════════════════════════════════════════════════════════════════
class _MultipleChoiceInput extends StatelessWidget {
  final List<String> options;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _MultipleChoiceInput({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final current = value as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((opt) {
        final selected = current == opt;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                _SpecRadio(selected: selected),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    opt,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      color: _kInputText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Checkbox — vertical multi-select list  (Q3)
// ═══════════════════════════════════════════════════════════════════════════════
class _CheckboxInput extends StatelessWidget {
  final List<String> options;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _CheckboxInput({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = (value as List<dynamic>?)?.cast<String>() ?? <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((opt) {
        final checked = selected.contains(opt);
        return GestureDetector(
          onTap: () {
            final next = List<String>.from(selected);
            if (checked) {
              next.remove(opt);
            } else {
              next.add(opt);
            }
            onChanged(next);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                _SpecCheckbox(checked: checked),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    opt,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      color: _kInputText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Yes / No  (Q2)
// ═══════════════════════════════════════════════════════════════════════════════
class _YesNoInput extends StatelessWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _YesNoInput({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final current = value as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ['Yes', 'No'].map((opt) {
        final selected = current == opt;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                _SpecRadio(selected: selected),
                const SizedBox(width: 12),
                Text(
                  opt,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: _kInputText,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Date picker  (Q9)
// ═══════════════════════════════════════════════════════════════════════════════
class _DateInput extends StatelessWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final BuildContext context;

  const _DateInput({
    required this.value,
    required this.onChanged,
    required this.context,
  });

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _kGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      onChanged(DateFormat('dd/MM/yyyy').format(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PickerField(
      placeholder: 'dd/mm/yyyy',
      displayText: value?.toString() ?? '',
      icon: Icons.calendar_today_outlined,
      onTap: _pick,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Date + time picker
// ═══════════════════════════════════════════════════════════════════════════════
class _DateTimeInput extends StatelessWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final BuildContext context;

  const _DateTimeInput({
    required this.value,
    required this.onChanged,
    required this.context,
  });

  Future<void> _pick() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _kGreen),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _kGreen),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    final combined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    onChanged(DateFormat('dd/MM/yyyy HH:mm').format(combined));
  }

  @override
  Widget build(BuildContext context) {
    return _PickerField(
      placeholder: 'dd/mm/yyyy hh:mm',
      displayText: value?.toString() ?? '',
      icon: Icons.calendar_today_outlined,
      onTap: _pick,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Time picker  (Q11)
// ═══════════════════════════════════════════════════════════════════════════════
class _TimeInput extends StatelessWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final BuildContext context;

  const _TimeInput({
    required this.value,
    required this.onChanged,
    required this.context,
  });

  Future<void> _pick() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _kGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      onChanged(picked.format(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PickerField(
      placeholder: 'Select time',
      displayText: value?.toString() ?? '',
      icon: Icons.access_time_outlined,
      onTap: _pick,
    );
  }
}

// ─── Shared picker trigger field ─────────────────────────────────────────────
//  Used by date, datetime, time (icon on right, 56 px height, spec §QUESTION 9/10/11)
class _PickerField extends StatelessWidget {
  final String placeholder;
  final String displayText;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.placeholder,
    required this.displayText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final empty = displayText.isEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _kBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                empty ? placeholder : displayText,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  color: empty ? _kPlaceholder : _kInputText,
                ),
              ),
            ),
            Icon(icon, color: _kBorder, size: 24),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Generic dropdown trigger  (Q12 month, Q13 day-of-week, re-used)
// ═══════════════════════════════════════════════════════════════════════════════
class _DropdownTrigger extends StatelessWidget {
  final String placeholder;
  final String? selected;
  final List<String> options;
  final ValueChanged<dynamic> onChanged;

  const _DropdownTrigger({
    required this.placeholder,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  void _showSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(height: 8),
          ...options.map((opt) => ListTile(
                title: Text(
                  opt,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: _kInputText,
                  ),
                ),
                trailing: selected == opt
                    ? const Icon(Icons.check, color: _kGreen)
                    : null,
                onTap: () {
                  onChanged(opt);
                  Navigator.pop(ctx);
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empty = selected == null || selected!.isEmpty;
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _kBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                empty ? placeholder : selected!,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  color: empty ? _kPlaceholder : _kInputText,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: _kBorder, size: 24),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Auto ID — read-only, generates on first render  (Q6)
// ═══════════════════════════════════════════════════════════════════════════════
class _AutoIdInput extends StatefulWidget {
  final String prefix;
  final dynamic value;
  final ValueChanged<dynamic> onInit;

  const _AutoIdInput({
    required this.prefix,
    required this.value,
    required this.onInit,
  });

  @override
  State<_AutoIdInput> createState() => _AutoIdInputState();
}

class _AutoIdInputState extends State<_AutoIdInput> {
  late String _id;

  @override
  void initState() {
    super.initState();
    if (widget.value != null && widget.value.toString().isNotEmpty) {
      _id = widget.value.toString();
    } else {
      final raw = const Uuid().v4().replaceAll('-', '').toUpperCase();
      _id = '#${widget.prefix}${raw.substring(0, 10)}';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onInit(_id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kFillOff,
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.tag, size: 18, color: _kTextSec),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _id,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: _kInputText,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Dashed border painter
// ═══════════════════════════════════════════════════════════════════════════════
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({
    this.color = _kBorder,
    this.radius = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashLen = 5.0;
    const gapLen = 4.0;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(radius),
    );

    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, (d + dashLen).clamp(0.0, metric.length)),
          paint,
        );
        d += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Dashed tap button  (Q14 image, Q15 audio, Q17 signature, fileUpload, barcode)
// ═══════════════════════════════════════════════════════════════════════════════
class _DashedTapButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final dynamic value;
  final String capturedLabel;
  final VoidCallback onTap;

  const _DashedTapButton({
    required this.label,
    required this.icon,
    required this.value,
    required this.capturedLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final captured = value != null && value.toString().isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        foregroundPainter: _DashedBorderPainter(
          color: captured ? _kGreen : _kBorder,
        ),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: captured ? _kGreenLight : Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  captured ? capturedLabel : label,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: captured ? _kGreen : _kPlaceholder,
                  ),
                ),
              ),
              Icon(
                captured ? Icons.check_circle_outline : icon,
                color: captured ? _kGreen : _kBorder,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Location input with removable chip  (Q16)
// ═══════════════════════════════════════════════════════════════════════════════
class _LocationInput extends StatelessWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _LocationInput({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value.toString().isNotEmpty;
    return GestureDetector(
      onTap: () {
        if (!hasValue) onChanged('location_captured');
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _kBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: hasValue
                  // Removable chip/tag (spec §QUESTION 16)
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kChipBg,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Tap to scan',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              color: _kGreen,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => onChanged(null),
                            child: const Text(
                              '×',
                              style: TextStyle(
                                fontSize: 18,
                                color: _kBorder,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Text(
                      'Tap to capture location',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: _kPlaceholder,
                      ),
                    ),
            ),
            const Icon(Icons.location_on_outlined, color: _kBorder, size: 24),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Rating (star selector)
// ═══════════════════════════════════════════════════════════════════════════════
class _RatingInput extends StatelessWidget {
  final int maxRating;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _RatingInput({
    required this.maxRating,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final current = (value is int) ? value as int : 0;
    return Row(
      children: List.generate(maxRating, (i) {
        final star = i + 1;
        final filled = star <= current;
        return GestureDetector(
          onTap: () => onChanged(star),
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: filled ? const Color(0xFFF59E0B) : _kBorder,
              size: 38,
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Farmer name — autocomplete / multi-select  (Q18)
// ═══════════════════════════════════════════════════════════════════════════════
class _FarmerNameInput extends StatefulWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _FarmerNameInput({required this.value, required this.onChanged});

  @override
  State<_FarmerNameInput> createState() => _FarmerNameInputState();
}

class _FarmerNameInputState extends State<_FarmerNameInput> {
  // Mock farmer list — replace with API lookup in production
  static const _farmers = [
    'Kofi Mensah',
    'Ama Asante',
    'Kweku Boateng',
    'Abena Owusu',
    'Yaw Darko',
  ];

  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: _selected ?? ''),
      optionsBuilder: (text) {
        if (text.text.isEmpty) return const [];
        return _farmers.where(
          (f) => f.toLowerCase().contains(text.text.toLowerCase()),
        );
      },
      onSelected: (farmer) {
        _selected = farmer;
        widget.onChanged(farmer);
      },
      fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
        return TextField(
          controller: ctrl,
          focusNode: focusNode,
          style: _inputStyle,
          decoration: _inputDec(
            hint: 'Type to select name',
            suffix: const Icon(
              Icons.keyboard_arrow_down,
              color: _kBorder,
              size: 24,
            ),
          ),
          onSubmitted: (_) => onSubmit(),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Ranking (reorderable list with up/down arrows)
// ═══════════════════════════════════════════════════════════════════════════════
class _RankingInput extends StatefulWidget {
  final List<String> options;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _RankingInput({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_RankingInput> createState() => _RankingInputState();
}

class _RankingInputState extends State<_RankingInput> {
  late List<String> _ranked;

  @override
  void initState() {
    super.initState();
    _ranked = (widget.value is List)
        ? List<String>.from(widget.value as List)
        : List<String>.from(widget.options);
  }

  void _swap(int a, int b) {
    setState(() {
      final tmp = _ranked[a];
      _ranked[a] = _ranked[b];
      _ranked[b] = tmp;
    });
    widget.onChanged(List<String>.from(_ranked));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_ranked.length, (i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _kBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // Rank number badge
              Container(
                width: 36,
                height: 52,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _kChipBg,
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(3)),
                ),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kGreen,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _ranked[i],
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: _kInputText,
                  ),
                ),
              ),
              // Up / down arrows
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: i > 0 ? () => _swap(i, i - 1) : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        size: 22,
                        color: i > 0 ? _kTextSec : _kDivider,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: i < _ranked.length - 1
                        ? () => _swap(i, i + 1)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 22,
                        color:
                            i < _ranked.length - 1 ? _kTextSec : _kDivider,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Likert scale (1–5 with end labels)
// ═══════════════════════════════════════════════════════════════════════════════
class _LikertScaleInput extends StatelessWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _LikertScaleInput({required this.value, required this.onChanged});

  static const _labels = [
    'Strongly\nDisagree',
    'Disagree',
    'Neutral',
    'Agree',
    'Strongly\nAgree',
  ];

  @override
  Widget build(BuildContext context) {
    final current = value?.toString();
    return Row(
      children: List.generate(5, (i) {
        final v = '${i + 1}';
        final selected = current == v;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(v),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? _kGreen : const Color(0xFFF0F0F0),
                    border: Border.all(
                      color: selected ? _kGreen : _kDivider,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    v,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _kTextSec,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.25,
                    color: selected ? _kGreen : _kTextSec,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Net Promoter Score (0–10)
// ═══════════════════════════════════════════════════════════════════════════════
class _NpsInput extends StatelessWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _NpsInput({required this.value, required this.onChanged});

  Color _colorFor(int n) {
    if (n <= 6) return const Color(0xFFEF4444);
    if (n <= 8) return const Color(0xFFF59E0B);
    return _kGreen;
  }

  @override
  Widget build(BuildContext context) {
    final current = value is int ? value as int : -1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(11, (i) {
            final selected = current == i;
            final color = _colorFor(i);
            return GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected ? color : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: selected ? color : _kDivider,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$i',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : _kTextSec,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '0 – Not at all likely',
              style: TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
            ),
            Text(
              '10 – Extremely likely',
              style: TextStyle(fontSize: 11, color: _kGreen),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Contact info (name + phone + email)
// ═══════════════════════════════════════════════════════════════════════════════
class _ContactInfoInput extends StatefulWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _ContactInfoInput({required this.value, required this.onChanged});

  @override
  State<_ContactInfoInput> createState() => _ContactInfoInputState();
}

class _ContactInfoInputState extends State<_ContactInfoInput> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final parsed = (widget.value is Map)
        ? Map<String, String>.from(widget.value as Map)
        : <String, String>{};
    _nameCtrl  = TextEditingController(text: parsed['name']  ?? '');
    _phoneCtrl = TextEditingController(text: parsed['phone'] ?? '');
    _emailCtrl = TextEditingController(text: parsed['email'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged({
      'name':  _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          style: _inputStyle,
          decoration: _inputDec(hint: 'Full name'),
          onChanged: (_) => _notify(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          style: _inputStyle,
          decoration: _inputDec(hint: 'Phone number'),
          onChanged: (_) => _notify(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: _inputStyle,
          decoration: _inputDec(hint: 'Email address'),
          onChanged: (_) => _notify(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Email input
// ═══════════════════════════════════════════════════════════════════════════════
class _EmailInput extends StatefulWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _EmailInput({required this.value, required this.onChanged});

  @override
  State<_EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends State<_EmailInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: TextInputType.emailAddress,
      style: _inputStyle,
      decoration: _inputDec(hint: 'name@example.com'),
      onChanged: widget.onChanged,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Currency field
// ═══════════════════════════════════════════════════════════════════════════════
class _CurrencyInput extends StatefulWidget {
  final String symbol;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _CurrencyInput({
    required this.symbol,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_CurrencyInput> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<_CurrencyInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      style: _inputStyle,
      decoration: _inputDec(hint: '0.00').copyWith(
        prefix: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            widget.symbol,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _kTextSec,
            ),
          ),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Calculated field (read-only formula display)
// ═══════════════════════════════════════════════════════════════════════════════
class _CalculatedFieldInput extends StatelessWidget {
  final String formula;
  final dynamic value;

  const _CalculatedFieldInput({required this.formula, required this.value});

  @override
  Widget build(BuildContext context) {
    final display = (value != null && value.toString().isNotEmpty)
        ? value.toString()
        : '— (auto-calculated)';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: _kFillOff,
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, size: 18, color: _kTextSec),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  display,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: _kInputText,
                  ),
                ),
              ),
            ],
          ),
          if (formula.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Formula: $formula',
              style: const TextStyle(
                fontSize: 11,
                color: _kTextSec,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Section divider / header
// ═══════════════════════════════════════════════════════════════════════════════
class _SectionDivider extends StatelessWidget {
  final String description;

  const _SectionDivider({required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: _kGreen, thickness: 1.5),
        if (description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: _kTextSec,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
