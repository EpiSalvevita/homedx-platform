import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../l10n/marketing_strings.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/neumorphic.dart';
import 'marketing_section.dart';

/// Three-step “how it works” block (shared by landing About section).
class HowItWorksSection extends StatelessWidget {
  final bool isWide;

  const HowItWorksSection({super.key, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final strings = MarketingStrings.of(context);
    final steps = [
      _StepData('1', strings.step1Title, strings.step1Body, AppTheme.accentBlue),
      _StepData('2', strings.step2Title, strings.step2Body, AppTheme.accentMint),
      _StepData('3', strings.step3Title, strings.step3Body, AppTheme.accentCoral),
    ];

    return MarketingSection(
      title: strings.howItWorksTitle,
      subtitle: strings.howItWorksSubtitle,
      child: isWide
          ? IntrinsicHeight(
              child: Row(
                // Stretch so shorter copy still fills the tallest step card.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _StepCard(step: steps[i], fillHeight: true),
                    ),
                  ],
                ],
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _StepCard(step: steps[i]),
                ],
              ],
            ),
    );
  }
}

class _StepData {
  final String number;
  final String title;
  final String body;
  final Color color;

  const _StepData(this.number, this.title, this.body, this.color);
}

class _StepCard extends StatelessWidget {
  final _StepData step;
  /// When true (wide row), grow to the tallest sibling so card backgrounds match.
  final bool fillHeight;

  const _StepCard({required this.step, this.fillHeight = false});

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      width: double.infinity,
      height: fillHeight ? double.infinity : null,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              step.number,
              style: FigmaUi.rubik(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.title,
            style: FigmaUi.rubik(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.body,
            style: FigmaUi.bodyLight(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
