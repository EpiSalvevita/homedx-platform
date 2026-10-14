import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/questionnaire/questionnaire_models.dart';
import '../../questionnaires/questionnaire_answer_format.dart';
import '../../questionnaires/questionnaire_branching.dart';
import '../../questionnaires/questionnaire_demo.dart';
import '../../questionnaires/questionnaire_field_widgets.dart';
import '../../questionnaires/questionnaire_validator.dart';
import '../../core/api_service.dart';
import '../../services/questionnaire_service.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/web/adaptive_screen.dart';

/// Modules answered by patients. Follow-up (CFU) is patient-side too.
const _patientModuleIds = {'A', 'C', 'CFU'};

class QuestionnaireFlowScreen extends StatefulWidget {
  final String moduleId;
  final bool isDoctor;
  final String? linkedRapidTestId;
  final String? returnRoute;
  /// Injected in tests. The app uses the API-backed service when this is null.
  final QuestionnaireService? service;

  const QuestionnaireFlowScreen({
    super.key,
    required this.moduleId,
    this.isDoctor = false,
    this.linkedRapidTestId,
    this.returnRoute,
    this.service,
  });

  @override
  State<QuestionnaireFlowScreen> createState() => _QuestionnaireFlowScreenState();
}

class _QuestionnaireFlowScreenState extends State<QuestionnaireFlowScreen> {
  QuestionnaireModule? _module;
  Map<String, dynamic> _answers = {};
  String? _submissionId;
  String? _revision;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showIntro = true;
  bool _showOverview = false;
  /// A saved draft the person has not yet chosen to continue. Nothing is loaded
  /// or saved until they confirm.
  QuestionnaireSubmission? _pendingDraft;
  bool _dataConsent = false;
  int _stepIndex = 0;
  List<QuestionnaireStep> _steps = [];
  String? _error;

  bool get _isPatientModule => _patientModuleIds.contains(widget.moduleId);

  bool get _isDemo => kQuestionnaireDemoBuild;

  String get _hubRoute => widget.isDoctor ? '/doctor/questionnaires' : '/questionnaires';

  @override
  void initState() {
    super.initState();
    _load();
  }

  QuestionnaireService get _service =>
      widget.service ?? QuestionnaireService(Provider.of<ApiService>(context, listen: false));

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final module = await _service.getDefinition(widget.moduleId);

      QuestionnaireSubmission? existing;
      try {
        existing = await _service.getSubmission(
          moduleId: widget.moduleId,
          linkedRapidTestId: widget.linkedRapidTestId,
        );
      } catch (_) {
        existing = null;
      }

      if (!mounted) return;
      setState(() {
        _module = module;
        // A saved draft with answers is offered first, never loaded silently.
        if (existing != null && existing.isDraft && existing.answers.isNotEmpty) {
          _pendingDraft = existing;
        } else if (existing != null) {
          _applyDraft(module, existing);
        }
        _rebuildSteps();
        _isLoading = false;
      });
    } on QuestionnaireApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = _messageFor(e);
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

  void _applyDraft(QuestionnaireModule module, QuestionnaireSubmission draft) {
    _answers = pruneAnswers(module, Map<String, dynamic>.from(draft.answers));
    _submissionId = draft.id;
    _revision = draft.revision;
    _showIntro = draft.isDraft;
    _dataConsent = draft.consentStatus == 'yes' || !_isPatientModule;
  }

  void _resumePendingDraft() {
    final draft = _pendingDraft;
    if (draft == null || _module == null) return;
    setState(() {
      _applyDraft(_module!, draft);
      _pendingDraft = null;
      _rebuildSteps();
    });
  }

  /// A notice that grows with its text. FigmaInsetInfoCard has a fixed height for
  /// a title-only card, so long questionnaire text overflowed on narrow screens.
  Widget _buildNotice(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.neumorphicRaised,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumePrompt() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNotice(Icons.edit_note, l10n.questResumePromptTitle),
        const SizedBox(height: 12),
        Text(
          l10n.questResumePromptBody,
          style: FigmaUi.bodyLight(fontSize: 16, color: AppTheme.textColorSecondary),
        ),
        const SizedBox(height: 28),
        NeumorphicPillButton(
          label: l10n.questResumeConfirm,
          height: AppTheme.buttonHeightLarge,
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          onPressed: _resumePendingDraft,
        ),
        const SizedBox(height: 12),
        NeumorphicPillButton(
          label: l10n.questResumeBack,
          height: AppTheme.buttonHeightLarge,
          backgroundColor: AppTheme.surface,
          foregroundColor: AppTheme.textColor,
          onPressed: () => context.go(_hubRoute),
        ),
      ],
    );
  }

  void _rebuildSteps() {
    if (_module == null) return;
    _steps = buildQuestionnaireSteps(_module!, _answers);
    if (_stepIndex >= _steps.length) {
      _stepIndex = _steps.isEmpty ? 0 : _steps.length - 1;
    }
  }

  void _onAnswerChanged(String itemId, dynamic value) {
    setState(() {
      _answers[itemId] = value;
      // Hiding a question drops its answer, the same way the server does.
      _answers = pruneAnswers(_module!, _answers);
      _rebuildSteps();
    });
  }

  String? _consentStatusValue() {
    if (!_isPatientModule) return 'not_applicable';
    return _dataConsent ? 'yes' : 'no';
  }

  String _messageFor(QuestionnaireApiException e) {
    final l10n = context.l10n;
    switch (e.code) {
      case 'REVISION_CONFLICT':
        return l10n.questRevisionConflict;
      case 'NOT_ASSIGNED':
        return l10n.questNotAssignedMessage;
      case 'CONSENT_REQUIRED':
        return l10n.questConsentRequired;
      case 'VALIDATION':
        if (e.validation.contains('CONSENT_REQUIRED')) return l10n.questConsentRequired;
        return l10n.questCheckAnswers;
      default:
        return l10n.questSaveFailed;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  Future<bool> _saveDraft() async {
    if (_module == null) return false;
    if (_isDemo) return true;
    setState(() => _isSaving = true);
    try {
      final saved = await _service.saveDraft(
        moduleId: widget.moduleId,
        answers: pruneAnswers(_module!, _answers),
        submissionId: _submissionId,
        expectedUpdatedAt: _revision,
        linkedRapidTestId: widget.linkedRapidTestId,
        consentStatus: _consentStatusValue(),
      );
      if (!mounted) return false;
      setState(() {
        _submissionId = saved.id;
        _revision = saved.revision;
      });
      return true;
    } on QuestionnaireApiException catch (e) {
      if (mounted) _showError(_messageFor(e));
      return false;
    } catch (_) {
      if (mounted) _showError(context.l10n.questSaveFailed);
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _submit() async {
    if (_module == null) return;
    final l10n = context.l10n;
    if (_isPatientModule && !_dataConsent) {
      _showError(l10n.questConsentRequired);
      return;
    }
    final errors = validateQuestionnaireSubmit(l10n, _module!, _answers);
    if (errors.isNotEmpty) {
      _showError(errors.first);
      return;
    }

    final returnQuery =
        widget.returnRoute != null ? 'return=${Uri.encodeComponent(widget.returnRoute!)}' : '';
    if (_isDemo) {
      // Demo: nothing is sent. The completion page reads these in-memory answers.
      final answers = pruneAnswers(_module!, _answers);
      context.go(
        '$_hubRoute/${widget.moduleId}/done?demo=1${returnQuery.isEmpty ? '' : '&$returnQuery'}',
        extra: answers,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final submitted = await _service.submit(
        moduleId: widget.moduleId,
        answers: pruneAnswers(_module!, _answers),
        submissionId: _submissionId,
        expectedUpdatedAt: _revision,
        linkedRapidTestId: widget.linkedRapidTestId,
        consentStatus: _consentStatusValue(),
      );
      if (!mounted) return;
      final query = [
        'submissionId=${Uri.encodeComponent(submitted.id)}',
        if (returnQuery.isNotEmpty) returnQuery,
      ].join('&');
      context.go('$_hubRoute/${widget.moduleId}/done?$query');
    } on QuestionnaireApiException catch (e) {
      if (mounted) _showError(_messageFor(e));
    } catch (_) {
      if (mounted) _showError(context.l10n.questSaveFailed);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _nextStep() async {
    if (_module == null || _steps.isEmpty) return;
    final errors = validateQuestionnaireStep(
      context.l10n,
      _steps[_stepIndex].items,
      _answers,
    );
    if (errors.isNotEmpty) {
      _showError(errors.first);
      return;
    }
    // The last step opens the overview. Submitting happens there.
    if (_stepIndex >= _steps.length - 1) {
      setState(() => _showOverview = true);
      return;
    }
    if (!await _saveDraft()) return;
    if (!mounted) return;
    setState(() {
      _stepIndex++;
      _rebuildSteps();
    });
  }

  void _prevStep() {
    if (_stepIndex > 0) {
      setState(() => _stepIndex--);
    }
  }

  void _editStep(int index) {
    setState(() {
      _showOverview = false;
      _stepIndex = index;
    });
  }

  void _applyDemoAnswers() {
    if (_module == null) return;
    setState(() {
      _answers = syntheticDemoAnswers(_module!);
      _rebuildSteps();
    });
  }

  Widget _buildDemoBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentMint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        context.l10n.questDemoBanner,
        style: FigmaUi.rubik(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.onMint),
      ),
    );
  }

  Widget _buildDemoPrefill() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeumorphicPillButton(
        label: context.l10n.questDemoPrefill,
        height: AppTheme.buttonHeightLarge,
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textColor,
        onPressed: _applyDemoAnswers,
      ),
    );
  }

  Widget _buildOverview() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.questOverviewTitle,
          style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.questOverviewHint,
          style: FigmaUi.bodyLight(fontSize: 15, color: AppTheme.textColorSecondary),
        ),
        const SizedBox(height: 18),
        for (final step in _steps) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  step.section.title,
                  style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textColor),
                ),
              ),
              TextButton(
                onPressed: () => _editStep(step.index - 1),
                child: Text(l10n.questEditSection),
              ),
            ],
          ),
          for (final item in step.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.text, style: FigmaUi.bodyLight(fontSize: 15, color: AppTheme.textColorSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    formatAnswer(item, _answers[item.id]).isEmpty
                        ? l10n.questNotAnswered
                        : formatAnswer(item, _answers[item.id]),
                    style: FigmaUi.rubik(fontSize: 16, color: AppTheme.textColor),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: NeumorphicPillButton(
                label: l10n.questBack,
                height: AppTheme.buttonHeightLarge,
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.textColor,
                onPressed: () => setState(() {
                  _showOverview = false;
                  _stepIndex = _steps.isEmpty ? 0 : _steps.length - 1;
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NeumorphicPillButton(
                label: l10n.questSendAnswers,
                height: AppTheme.buttonHeightLarge,
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                loading: _isSaving,
                onPressed: _isSaving ? null : _submit,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isDemo) ...[_buildDemoBanner(), _buildDemoPrefill()],
        if (_isPatientModule) ...[
          _buildNotice(Icons.info_outline, context.l10n.questIntroPatientNotice),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _dataConsent,
            onChanged: (v) => setState(() => _dataConsent = v ?? false),
            title: Text(
              context.l10n.questConsentCheckbox,
              style: FigmaUi.rubik(fontSize: 17, color: AppTheme.textColor),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ] else
          _buildNotice(Icons.medical_information_outlined, context.l10n.questIntroResearchNotice),
        const SizedBox(height: 28),
        NeumorphicPillButton(
          label: context.l10n.questStart,
          height: AppTheme.buttonHeightLarge,
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          onPressed: (_isPatientModule && !_dataConsent)
              ? null
              : () => setState(() => _showIntro = false),
        ),
      ],
    );
  }

  Widget _buildStep() {
    final step = _steps[_stepIndex];
    final isLast = _stepIndex >= _steps.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isDemo) ...[_buildDemoBanner(), _buildDemoPrefill()],
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.questStepProgress('${step.index}', '${step.total}'),
                style: FigmaUi.bodyLight(fontSize: 17, color: AppTheme.textColorSecondary),
              ),
            ),
            if (_isSaving)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: step.total == 0 ? 0 : step.index / step.total,
          backgroundColor: AppTheme.primaryLight,
          color: AppTheme.primaryBlue,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 20),
        Text(
          step.section.title,
          style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor),
        ),
        if (step.section.intro != null) ...[
          const SizedBox(height: 8),
          Text(
            step.section.intro!,
            style: FigmaUi.bodyLight(fontSize: 15, color: AppTheme.textColorSecondary),
          ),
        ],
        const SizedBox(height: 18),
        ...step.items.map(
          (item) => QuestionnaireFieldWidget(
            item: item,
            value: _answers[item.id],
            onChanged: _onAnswerChanged,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_stepIndex > 0)
              Expanded(
                child: NeumorphicPillButton(
                  label: context.l10n.questBack,
                  height: AppTheme.buttonHeightLarge,
                  backgroundColor: AppTheme.surface,
                  foregroundColor: AppTheme.textColor,
                  onPressed: _prevStep,
                ),
              ),
            if (_stepIndex > 0) const SizedBox(width: 12),
            Expanded(
              child: NeumorphicPillButton(
                label: isLast ? context.l10n.questOpenOverview : context.l10n.questNext,
                height: AppTheme.buttonHeightLarge,
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                loading: _isSaving,
                onPressed: _isSaving ? null : _nextStep,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: _module?.title ?? context.l10n.questFallbackTitle(widget.moduleId),
      showWebHeader: false,
      onBack: () => context.go(_hubRoute),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? FigmaEmptyState(
                  icon: Icons.error_outline,
                  title: context.l10n.questLoadFailed,
                  message: _error ?? context.l10n.checkConnectionRetry,
                  actionLabel: context.l10n.retry,
                  onAction: _load,
                )
              : _steps.isEmpty && !_showIntro
                  ? FigmaEmptyState(
                      icon: Icons.task_alt,
                      title: context.l10n.questNoQuestions,
                      message: context.l10n.questNoQuestionsMessage,
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                        kIsWeb ? 24 : 8,
                        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                        24,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: _pendingDraft != null
                              ? _buildResumePrompt()
                              : _showIntro
                                  ? _buildIntro()
                                  : _showOverview
                                      ? _buildOverview()
                                      : _buildStep(),
                        ),
                      ),
                    ),
    );
  }
}
