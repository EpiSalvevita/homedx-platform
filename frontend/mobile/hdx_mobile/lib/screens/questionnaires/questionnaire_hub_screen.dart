import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../l10n/l10n_ext.dart';
import '../../models/questionnaire/questionnaire_models.dart';
import '../../core/api_service.dart';
import '../../services/questionnaire_service.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/web/adaptive_screen.dart';

class QuestionnaireHubScreen extends StatefulWidget {
  final bool isDoctor;

  const QuestionnaireHubScreen({super.key, this.isDoctor = false});

  @override
  State<QuestionnaireHubScreen> createState() => _QuestionnaireHubScreenState();
}

class _QuestionnaireHubScreenState extends State<QuestionnaireHubScreen> {
  List<QuestionnaireModuleSummary> _modules = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = QuestionnaireService(api);
      final modules = await service.listModules();
      if (mounted) {
        setState(() {
          _modules = modules;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _moduleBadge(String moduleId) {
    switch (moduleId) {
      case 'A':
        return context.l10n.questBadgeBeforeTest;
      case 'B':
        return context.l10n.questBadgeNetwork;
      case 'C':
        return context.l10n.questBadgeAfterUse;
      case 'CFU':
        return context.l10n.questBadgeFollowUp;
      case 'D':
        return context.l10n.questBadgePilot;
      default:
        return moduleId;
    }
  }

  void _openModule(QuestionnaireModuleSummary module) {
    if (!module.isAssignable) return;
    final base = widget.isDoctor ? '/doctor/questionnaires' : '/questionnaires';
    context.push('$base/${module.moduleId}');
  }

  String get _hubIntro => widget.isDoctor
      ? context.l10n.questHubIntroDoctor
      : context.l10n.questHubIntroPatient;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: context.l10n.questTitle,
      showWebHeader: false,
      showBackOnMobile: false,
      onBack: () => context.go(widget.isDoctor ? '/doctor/dashboard' : '/home'),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.fromLTRB(
                  kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                  kIsWeb ? 24 : 8,
                  kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                  24,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _hubIntro,
                            style: FigmaUi.bodyLight(
                              fontSize: 17,
                              color: AppTheme.textColorSecondary,
                            ).copyWith(height: 1.45),
                          ),
                          const SizedBox(height: 24),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: FigmaEmptyState(
                                icon: Icons.error_outline,
                                title: context.l10n.questLoadError,
                                message: context.l10n.checkConnectionRetry,
                                actionLabel: context.l10n.retry,
                                onAction: _load,
                              ),
                            )
                          else if (_modules.isEmpty)
                            FigmaEmptyState(
                              icon: Icons.quiz_outlined,
                              title: context.l10n.questEmpty,
                              message: context.l10n.questEmptyMessage,
                            )
                          else
                            ..._modules.map((m) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
                                  child: NeumorphicRaisedCard(
                                    height: null,
                                    padding: const EdgeInsets.all(22),
                                    onTap: m.isAssignable ? () => _openModule(m) : null,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryLight,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                context.l10n.questModuleLabel(m.moduleId),
                                                style: FigmaUi.rubik(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primaryBlue,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                _moduleBadge(m.moduleId),
                                                style: FigmaUi.bodyLight(
                                                  fontSize: 15,
                                                  color: AppTheme.textColorSecondary,
                                                ),
                                              ),
                                            ),
                                            if (!m.isAssignable)
                                              const Icon(Icons.schedule, color: AppTheme.textColorSecondary, size: 26)
                                            else if (m.hasSubmitted)
                                              const Icon(Icons.check_circle, color: AppTheme.successColor, size: 26)
                                            else if (m.hasDraft)
                                              const Icon(Icons.edit_note, color: AppTheme.primaryBlue, size: 26)
                                            else
                                              const Icon(Icons.arrow_forward_ios, size: 18, color: AppTheme.textColorSecondary),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          m.title,
                                          style: FigmaUi.rubik(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textColor,
                                          ),
                                        ),
                                        if (m.targetGroup.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            m.targetGroup,
                                            style: FigmaUi.bodyLight(
                                              fontSize: 15,
                                              color: AppTheme.textColorSecondary,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 14),
                                        Text(
                                          !m.isAssignable
                                              ? context.l10n.questNotAssigned
                                              : m.hasSubmitted
                                                  ? context.l10n.statusCompleted
                                                  : m.hasDraft
                                                      ? context.l10n.questResume
                                                      : context.l10n.questStartNow,
                                          style: FigmaUi.rubik(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: m.isAssignable
                                                ? AppTheme.primaryBlue
                                                : AppTheme.textColorSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
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
