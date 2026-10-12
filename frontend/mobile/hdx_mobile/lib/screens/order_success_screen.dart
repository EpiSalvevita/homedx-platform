import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import '../config/app_theme.dart';
import '../widgets/figma_ui.dart';

class OrderSuccessScreen extends StatelessWidget {
  final double amount;
  final String currency;
  final String? title;
  final String? subtitle;

  const OrderSuccessScreen({
    super.key,
    required this.amount,
    required this.currency,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final headingText = title ?? context.l10n.orderTitle;
    final subtitleText = subtitle ?? context.l10n.orderSubtitle;

    return FigmaScreen(
      header: FigmaBackHeader(title: headingText, showBack: false),
      bottomBar: FigmaBottomActionBar(
        buttonLabel: context.l10n.orderBackToHome,
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.neumorphicRaised,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(color: AppTheme.successColor.withValues(alpha: 0.25), shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_outline, size: 52, color: AppTheme.textColor),
                    ),
                    const SizedBox(height: 24),
                    Text(headingText, textAlign: TextAlign.center, style: FigmaUi.rubik(fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
                    const SizedBox(height: 12),
                    Text(subtitleText, textAlign: TextAlign.center, style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w300, color: AppTheme.textColorSecondary, height: 1.4)),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.orderTotal(amount.toStringAsFixed(2), currency),
                      style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
