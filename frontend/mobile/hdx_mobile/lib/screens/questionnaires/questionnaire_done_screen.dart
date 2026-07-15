import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/web/adaptive_screen.dart';

class QuestionnaireDoneScreen extends StatelessWidget {
  final String moduleId;
  final bool isDoctor;
  final String? returnRoute;

  const QuestionnaireDoneScreen({
    super.key,
    required this.moduleId,
    this.isDoctor = false,
    this.returnRoute,
  });

  @override
  Widget build(BuildContext context) {
    final hubRoute = isDoctor ? '/doctor/questionnaires' : '/questionnaires';

    return AdaptiveScreen(
      title: 'Fragebogen abgeschlossen',
      showWebHeader: false,
      onBack: () => context.go(hubRoute),
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
            kIsWeb ? 48 : 24,
            kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
            24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: NeumorphicRaisedCard(
              height: null,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 44,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Vielen Dank!',
                    style: FigmaUi.rubik(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bogen $moduleId wurde erfolgreich übermittelt. Ihre Antworten wurden gespeichert.',
                    textAlign: TextAlign.center,
                    style: FigmaUi.bodyLight(
                      fontSize: 17,
                      color: AppTheme.textColorSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  NeumorphicPillButton(
                    label: 'Zurück zu Fragebögen',
                    height: AppTheme.buttonHeightLarge,
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    onPressed: () => context.go(hubRoute),
                  ),
                  if (returnRoute != null && returnRoute!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    NeumorphicPillButton(
                      label: 'Weiter im Ablauf',
                      height: AppTheme.buttonHeightLarge,
                      backgroundColor: AppTheme.accentMint,
                      foregroundColor: AppTheme.onMint,
                      onPressed: () => context.go(returnRoute!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
