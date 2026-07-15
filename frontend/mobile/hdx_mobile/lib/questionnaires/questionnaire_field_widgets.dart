import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/questionnaire/questionnaire_models.dart';
import '../widgets/figma_ui.dart';

typedef AnswerChanged = void Function(String fieldId, dynamic value);

class QuestionnaireFieldWidget extends StatelessWidget {
  final QuestionnaireField field;
  final dynamic value;
  final AnswerChanged onChanged;

  const QuestionnaireFieldWidget({
    super.key,
    required this.field,
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
            field.label,
            style: FigmaUi.rubik(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.textColor,
            ),
          ),
          if (field.required)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Pflichtfeld',
                style: FigmaUi.bodyLight(fontSize: 12, color: AppTheme.textColorSecondary),
              ),
            ),
          const SizedBox(height: 12),
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    switch (field.type) {
      case 'single_choice':
        return _SingleChoiceInput(
          options: field.options,
          value: value?.toString(),
          onChanged: (v) => onChanged(field.id, v),
        );
      case 'multi_choice':
        return _MultiChoiceInput(
          options: field.options,
          values: value is List ? List<String>.from(value.map((e) => e.toString())) : <String>[],
          onChanged: (v) => onChanged(field.id, v),
        );
      case 'likert_5':
        return _LikertInput(
          value: value is int ? value : int.tryParse('$value'),
          onChanged: (v) => onChanged(field.id, v),
        );
      case 'nrs_0_10':
        return _NrsInput(
          value: value is int ? value : int.tryParse('$value'),
          onChanged: (v) => onChanged(field.id, v),
        );
      case 'text':
        return _TextInput(
          value: value?.toString() ?? '',
          onChanged: (v) => onChanged(field.id, v),
        );
      default:
        return _TextInput(
          value: value?.toString() ?? '',
          onChanged: (v) => onChanged(field.id, v),
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
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final selected = value == opt;
        return ChoiceChip(
          label: Text(opt),
          selected: selected,
          onSelected: (_) => onChanged(opt),
          selectedColor: AppTheme.primaryBlue,
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppTheme.textColor,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }
}

class _MultiChoiceInput extends StatelessWidget {
  final List<String> options;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  const _MultiChoiceInput({
    required this.options,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final selected = values.contains(opt);
        return FilterChip(
          label: Text(opt),
          selected: selected,
          onSelected: (v) {
            final next = List<String>.from(values);
            if (v) {
              next.add(opt);
            } else {
              next.remove(opt);
            }
            onChanged(next);
          },
          selectedColor: AppTheme.primaryLight,
          checkmarkColor: AppTheme.primaryBlue,
        );
      }).toList(),
    );
  }
}

class _LikertInput extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  const _LikertInput({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        final selected = value == n;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 4 ? 6 : 0),
            child: InkWell(
              onTap: () => onChanged(n),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryBlue : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected ? null : AppTheme.neumorphicRaised,
                ),
                child: Center(
                  child: Text(
                    '$n',
                    style: FigmaUi.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppTheme.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _NrsInput extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  const _NrsInput({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: (value ?? 0).toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: '${value ?? 0}',
          activeColor: AppTheme.primaryBlue,
          onChanged: (v) => onChanged(v.round()),
        ),
        Text(
          'Aktuell: ${value ?? 0}',
          style: FigmaUi.bodyLight(fontSize: 14, color: AppTheme.textColorSecondary),
        ),
      ],
    );
  }
}

class _TextInput extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _TextInput({required this.value, required this.onChanged});

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
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.navy.withValues(alpha: 0.12)),
        ),
      ),
    );
  }
}
