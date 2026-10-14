import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../l10n/l10n_ext.dart';
import '../models/questionnaire/questionnaire_models.dart';
import '../widgets/figma_ui.dart';

typedef AnswerChanged = void Function(String itemId, dynamic value);

/// Renders one V04 question. Response kinds come from responseContract.kind.
/// Nothing is pre-selected: an unanswered scale is null, never 0.
class QuestionnaireFieldWidget extends StatelessWidget {
  final QuestionnaireItem item;
  final dynamic value;
  final AnswerChanged onChanged;

  const QuestionnaireFieldWidget({
    super.key,
    required this.item,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.text,
            style: FigmaUi.rubik(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.textColor,
            ),
          ),
          if (item.help != null) ...[
            const SizedBox(height: 4),
            Text(
              item.help!,
              style: FigmaUi.bodyLight(fontSize: 14, color: AppTheme.textColorSecondary),
            ),
          ],
          if (item.required)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                context.l10n.questRequiredMarker,
                style: FigmaUi.bodyLight(fontSize: 14, color: AppTheme.textColorSecondary),
              ),
            ),
          const SizedBox(height: 14),
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    switch (item.type) {
      case 'single':
      case 'scale_agree':
      case 'scale_1_5':
        return _SingleChoiceInput(
          options: item.options,
          value: value is String ? value as String : null,
          onChanged: (v) => onChanged(item.id, v),
        );
      case 'multi':
      case 'bodymap_multi':
      case 'lab_multi':
      case 'multi_with_detail':
        return _MultiChoiceInput(
          options: item.options,
          exclusiveOptions: item.exclusiveOptions,
          values: value is List ? value.map<String>((e) => e.toString()).toList() : <String>[],
          onChanged: (v) => onChanged(item.id, v),
        );
      case 'rank_top3':
      case 'rank_top5':
        return _RankInput(
          options: item.options,
          maximum: item.responseContract.maximumSelected ?? item.options.length,
          values: value is List ? value.map<String>((e) => e.toString()).toList() : <String>[],
          onChanged: (v) => onChanged(item.id, v),
        );
      case 'matrix_presence':
      case 'matrix_importance':
        return _MatrixInput(
          rows: item.options,
          ratings: item.responseContract.ratings,
          values: value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{},
          onChanged: (v) => onChanged(item.id, v),
        );
      case 'scale_0_10':
        return _ScaleInput(
          value: value is int ? value : null,
          lowLabel: item.options.isNotEmpty ? item.options.first : null,
          highLabel: item.options.length > 1 ? item.options[1] : null,
          onChanged: (v) => onChanged(item.id, v),
        );
      case 'textarea':
      case 'version':
        return _TextInput(
          value: value?.toString() ?? '',
          maxLength: item.responseContract.maximumLength,
          onChanged: (v) => onChanged(item.id, v),
        );
      case 'review':
        // UI control only. Never stored, never rendered as a question.
        return const SizedBox.shrink();
      default:
        return Text(
          context.l10n.questUnsupportedQuestion,
          style: FigmaUi.bodyLight(fontSize: 15, color: AppTheme.errorColor),
        );
    }
  }
}

class _SingleChoiceInput extends StatelessWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;

  const _SingleChoiceInput({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final selected = value == opt;
        return ChoiceChip(
          label: Text(opt),
          selected: selected,
          onSelected: (_) => onChanged(opt),
          selectedColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          labelStyle: FigmaUi.rubik(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : AppTheme.textColor,
          ),
        );
      }).toList(),
    );
  }
}

class _MultiChoiceInput extends StatelessWidget {
  final List<String> options;
  final List<String> exclusiveOptions;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  const _MultiChoiceInput({
    required this.options,
    required this.exclusiveOptions,
    required this.values,
    required this.onChanged,
  });

  /// Explicit exclusiveOptions only. Wording is never used to infer exclusivity.
  List<String> _toggle(String option, bool checked) {
    final isExclusive = exclusiveOptions.contains(option);
    if (!checked) return values.where((v) => v != option).toList();
    if (isExclusive) return [option];
    return [
      ...values.where((v) => !exclusiveOptions.contains(v) && v != option),
      option,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final selected = values.contains(opt);
        return FilterChip(
          label: Text(opt),
          selected: selected,
          onSelected: (v) => onChanged(_toggle(opt, v)),
          selectedColor: AppTheme.primaryLight,
          checkmarkColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          labelStyle: FigmaUi.rubik(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: AppTheme.textColor,
          ),
        );
      }).toList(),
    );
  }
}

class _RankInput extends StatelessWidget {
  final List<String> options;
  final int maximum;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  const _RankInput({
    required this.options,
    required this.maximum,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final full = values.length >= maximum;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.questRankHint(maximum),
          style: FigmaUi.bodyLight(fontSize: 14, color: AppTheme.textColorSecondary),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final position = values.indexOf(opt);
            final selected = position >= 0;
            return FilterChip(
              avatar: selected
                  ? CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue,
                      child: Text(
                        '${position + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  : null,
              label: Text(opt),
              selected: selected,
              onSelected: (v) {
                if (v && full) return;
                onChanged(v
                    ? [...values, opt]
                    : values.where((x) => x != opt).toList());
              },
              selectedColor: AppTheme.primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MatrixInput extends StatelessWidget {
  final List<String> rows;
  final List<String> ratings;
  final Map<String, dynamic> values;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _MatrixInput({
    required this.rows,
    required this.ratings,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows.map((row) {
        final current = values[row] as String?;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row,
                style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textColor),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ratings.map((r) {
                  final selected = current == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: selected,
                    onSelected: (_) => onChanged({...values, row: r}),
                    selectedColor: AppTheme.primaryBlue,
                    labelStyle: FigmaUi.rubik(
                      fontSize: 14,
                      color: selected ? Colors.white : AppTheme.textColor,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ScaleInput extends StatelessWidget {
  final int? value;
  final String? lowLabel;
  final String? highLabel;
  final ValueChanged<int> onChanged;

  const _ScaleInput({
    required this.value,
    required this.lowLabel,
    required this.highLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(11, (n) {
            final selected = value == n;
            return ChoiceChip(
              label: Text('$n'),
              selected: selected,
              onSelected: (_) => onChanged(n),
              selectedColor: AppTheme.primaryBlue,
              labelStyle: FigmaUi.rubik(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : AppTheme.textColor,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        if (lowLabel != null || highLabel != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  lowLabel ?? '',
                  style: FigmaUi.bodyLight(fontSize: 13, color: AppTheme.textColorSecondary),
                ),
              ),
              Expanded(
                child: Text(
                  highLabel ?? '',
                  textAlign: TextAlign.end,
                  style: FigmaUi.bodyLight(fontSize: 13, color: AppTheme.textColorSecondary),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TextInput extends StatefulWidget {
  final String value;
  final int? maxLength;
  final ValueChanged<String> onChanged;

  const _TextInput({required this.value, required this.maxLength, required this.onChanged});

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _TextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: 4,
      maxLength: widget.maxLength,
      style: FigmaUi.rubik(fontSize: 17, color: AppTheme.textColor),
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.background,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.navy.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
      ),
    );
  }
}
