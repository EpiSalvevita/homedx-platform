import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../core/api_service.dart';
import '../../models/questionnaire/questionnaire_models.dart';
import '../../questionnaires/questionnaire_answer_format.dart';
import '../../questionnaires/questionnaire_branching.dart';
import '../../services/questionnaire_service.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/web/adaptive_screen.dart';

/// Completion page. It shows what the person entered, never a score or a diagnosis.
/// Real submissions are read back from the server by submissionId. The demo build
/// passes its in-memory answers instead.
class QuestionnaireDoneScreen extends StatefulWidget {
  final String moduleId;
  final bool isDoctor;
  final String? returnRoute;
  final String? submissionId;
  final Map<String, dynamic>? demoAnswers;

  const QuestionnaireDoneScreen({
    super.key,
    required this.moduleId,
    this.isDoctor = false,
    this.returnRoute,
    this.submissionId,
    this.demoAnswers,
  });

  @override
  State<QuestionnaireDoneScreen> createState() => _QuestionnaireDoneScreenState();
}

class _QuestionnaireDoneScreenState extends State<QuestionnaireDoneScreen> {
  QuestionnaireModule? _module;
  Map<String, dynamic> _answers = {};
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final service = QuestionnaireService(Provider.of<ApiService>(context, listen: false));
      final module = await service.getDefinition(widget.moduleId);
      Map<String, dynamic> answers;
      if (widget.demoAnswers != null) {
        answers = Map<String, dynamic>.from(widget.demoAnswers!);
      } else if (widget.submissionId != null) {
        final submission = await service.getSubmission(submissionId: widget.submissionId);
        answers = submission == null ? {} : Map<String, dynamic>.from(submission.answers);
      } else {
        answers = {};
      }
      if (!mounted) return;
      setState(() {
        _module = module;
        _answers = pruneAnswers(module, answers);
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  Widget _buildAnswerOverview(BuildContext context) {
    final module = _module!;
    final steps = buildQuestionnaireSteps(module, _answers);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.questDoneYourAnswers,
          style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textColor),
        ),
        const SizedBox(height: 12),
        for (final step in steps) ...[
          Text(
            step.section.title,
            style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 6),
          for (final item in step.items)
            if (isAnswered(_answers[item.id]))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.text, style: FigmaUi.bodyLight(fontSize: 14, color: AppTheme.textColorSecondary)),
                    Text(
                      formatAnswer(item, _answers[item.id]),
                      style: FigmaUi.rubik(fontSize: 15, color: AppTheme.textColor),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hubRoute = widget.isDoctor ? '/doctor/questionnaires' : '/questionnaires';
    final returnRoute = widget.returnRoute;

    return AdaptiveScreen(
      title: context.l10n.questDoneTitle,
      showWebHeader: false,
      onBack: () => context.go(hubRoute),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                    kIsWeb ? 48 : 24,
                    kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                    24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: NeumorphicRaisedCard(
                      height: null,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
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
                          ),
                          const SizedBox(height: 20),
                          Text(
                            context.l10n.questThanks,
                            textAlign: TextAlign.center,
                            style: FigmaUi.rubik(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.l10n.questDoneMessage(widget.moduleId),
                            textAlign: TextAlign.center,
                            style: FigmaUi.bodyLight(
                              fontSize: 17,
                              color: AppTheme.textColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.questDoneNextStep,
                            textAlign: TextAlign.center,
                            style: FigmaUi.bodyLight(fontSize: 15, color: AppTheme.textColorSecondary),
                          ),
                          if (_module != null) ...[
                            const SizedBox(height: 24),
                            _buildAnswerOverview(context),
                          ] else if (_failed) ...[
                            const SizedBox(height: 16),
                            Text(
                              context.l10n.questOverviewUnavailable,
                              textAlign: TextAlign.center,
                              style: FigmaUi.bodyLight(fontSize: 15, color: AppTheme.textColorSecondary),
                            ),
                          ],
                          const SizedBox(height: 28),
                          NeumorphicPillButton(
                            label: context.l10n.questBackToList,
                            height: AppTheme.buttonHeightLarge,
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            onPressed: () => context.go(hubRoute),
                          ),
                          if (returnRoute != null && returnRoute.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            NeumorphicPillButton(
                              label: context.l10n.questContinue,
                              height: AppTheme.buttonHeightLarge,
                              backgroundColor: AppTheme.accentMint,
                              foregroundColor: AppTheme.onMint,
                              onPressed: () => context.go(returnRoute),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
