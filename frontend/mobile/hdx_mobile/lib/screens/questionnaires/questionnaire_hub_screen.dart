import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/questionnaire/questionnaire_models.dart';
import '../../services/api_service.dart';
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
        return 'Vor dem Test';
      case 'B':
        return 'Rheumanetzwerk';
      case 'C':
        return 'Nach Nutzung';
      case 'D':
        return 'Pilot / Implementierung';
      default:
        return moduleId;
    }
  }

  void _openModule(QuestionnaireModuleSummary module) {
    final base = widget.isDoctor ? '/doctor/questionnaires' : '/questionnaires';
    context.push('$base/${module.moduleId}');
  }

  String get _hubIntro => widget.isDoctor
      ? 'Im Rahmen von RheumaCheck erfassen diese Fragebögen strukturierte Angaben aus Sicht des Rheumanetzwerks und zur Implementierbarkeit in der Praxis. '
          'Ihre Antworten unterstützen die Begleitforschung und die Weiterentwicklung von HomeDX — sie ersetzen keine Diagnose und geben keine Behandlungsempfehlungen.'
      : 'Im Rahmen von RheumaCheck helfen diese Fragebögen, Ihre Angaben vor dem Test und Ihr Feedback nach der Nutzung strukturiert zu erfassen. '
          'So können wir HomeDX verbessern und die Versorgung besser verstehen. Die Fragebögen ersetzen keine ärztliche Diagnose.';

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Fragebögen',
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
                                title: 'Fragebögen konnten nicht geladen werden',
                                message: 'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
                                actionLabel: 'Erneut versuchen',
                                onAction: _load,
                              ),
                            )
                          else if (_modules.isEmpty)
                            const FigmaEmptyState(
                              icon: Icons.quiz_outlined,
                              title: 'Keine Fragebögen verfügbar',
                              message: 'Sobald Fragebögen freigeschaltet sind, erscheinen sie hier.',
                            )
                          else
                            ..._modules.map((m) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
                                  child: NeumorphicRaisedCard(
                                    height: null,
                                    padding: const EdgeInsets.all(22),
                                    onTap: () => _openModule(m),
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
                                                'Bogen ${m.moduleId}',
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
                                            if (m.hasSubmitted)
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
                                        if (m.purpose != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            m.purpose!,
                                            style: FigmaUi.bodyLight(
                                              fontSize: 15,
                                              color: AppTheme.textColorSecondary,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 14),
                                        Text(
                                          m.hasSubmitted
                                              ? 'Abgeschlossen'
                                              : m.hasDraft
                                                  ? 'Entwurf fortsetzen'
                                                  : 'Jetzt starten',
                                          style: FigmaUi.rubik(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryBlue,
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
