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
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps
                  .map(
                    (step) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _StepCard(step: step),
                      ),
                    ),
                  )
                  .toList(),
            )
          : Column(
              children: steps
                  .map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StepCard(step: step),
                    ),
                  )
                  .toList(),
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

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
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
