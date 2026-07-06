import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import '../utils/jalali_date.dart';

Future<TimeOfDay?> showReminderTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (context) => _ReminderTimePickerDialog(initialTime: initialTime),
  );
}

class _ReminderTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const _ReminderTimePickerDialog({required this.initialTime});

  @override
  State<_ReminderTimePickerDialog> createState() =>
      _ReminderTimePickerDialogState();
}

class _ReminderTimePickerDialogState extends State<_ReminderTimePickerDialog> {
  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;
  late final FocusNode _hourFocusNode;
  late final FocusNode _minuteFocusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _hourController = TextEditingController(
      text: widget.initialTime.hour.toString().padLeft(2, '0'),
    );
    _minuteController = TextEditingController(
      text: widget.initialTime.minute.toString().padLeft(2, '0'),
    );
    _hourFocusNode = FocusNode();
    _minuteFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _hourFocusNode.dispose();
    _minuteFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final hour = _parseNumber(_hourController.text);
    final minute = _parseNumber(_minuteController.text);

    if (hour == null || hour < 0 || hour > 23) {
      setState(() => _errorText = 'ساعت باید بین ۰ تا ۲۳ باشد');
      return;
    }

    if (minute == null || minute < 0 || minute > 59) {
      setState(() => _errorText = 'دقیقه باید بین ۰ تا ۵۹ باشد');
      return;
    }

    Navigator.of(context).pop(TimeOfDay(hour: hour, minute: minute));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'زمان یادآوری را وارد کن',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TimeColumn(
                        label: 'ساعت',
                        controller: _hourController,
                        focusNode: _hourFocusNode,
                        primary: primary,
                        autofocus: true,
                        onChanged: () => setState(() => _errorText = null),
                        onSubmitted: () => _minuteFocusNode.requestFocus(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text(
                          ':',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      _TimeColumn(
                        label: 'دقیقه',
                        controller: _minuteController,
                        focusNode: _minuteFocusNode,
                        primary: primary,
                        onChanged: () => setState(() => _errorText = null),
                        onSubmitted: _submit,
                      ),
                    ],
                  ),
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('انصراف'),
                    ),
                    const SizedBox(width: 18),
                    TextButton(onPressed: _submit, child: const Text('تأیید')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color primary;
  final bool autofocus;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _TimeColumn({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.primary,
    this.autofocus = false,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 86,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.number,
              textInputAction: label == 'ساعت'
                  ? TextInputAction.next
                  : TextInputAction.done,
              maxLength: 2,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹]')),
              ],
              onChanged: (_) => onChanged(),
              onTap: () {
                controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.text.length,
                );
              },
              onSubmitted: (_) => onSubmitted(),
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: primary.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

int? _parseNumber(String value) {
  final normalized = _toEnglishDigits(value.trim());
  if (normalized.isEmpty) return null;
  return int.tryParse(normalized);
}

String _toEnglishDigits(String value) {
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  var result = value;
  for (var i = 0; i < persian.length; i++) {
    result = result.replaceAll(persian[i], i.toString());
  }
  return result;
}
