import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/questionnaire/questionnaire_models.dart';
import '../../questionnaires/questionnaire_branching.dart';
import '../../questionnaires/questionnaire_field_widgets.dart';
import '../../questionnaires/questionnaire_validator.dart';
import '../../services/api_service.dart';
import '../../services/questionnaire_service.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/web/adaptive_screen.dart';

class QuestionnaireFlowScreen extends StatefulWidget {
  final String moduleId;
  final bool isDoctor;
  final String? linkedRapidTestId;
  final String? returnRoute;

  const QuestionnaireFlowScreen({
    super.key,
    required this.moduleId,
    this.isDoctor = false,
    this.linkedRapidTestId,
    this.returnRoute,
  });

  @override
  State<QuestionnaireFlowScreen> createState() => _QuestionnaireFlowScreenState();
}

class _QuestionnaireFlowScreenState extends State<QuestionnaireFlowScreen> {
  QuestionnaireModule? _module;
  Map<String, dynamic> _answers = {};
  String? _submissionId;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showIntro = true;
  bool _dataConsent = false;
  int _stepIndex = 0;
  List<QuestionnaireStep> _steps = [];
  String? _error;

  bool get _isPatientModule => widget.moduleId == 'A' || widget.moduleId == 'C';

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
      final module = await service.getDefinition(widget.moduleId);
      if (module == null) throw Exception('Fragebogen nicht gefunden');

      QuestionnaireSubmission? existing;
      try {
        existing = await service.getSubmission(
          moduleId: widget.moduleId,
          linkedRapidTestId: widget.linkedRapidTestId,
        );
      } catch (_) {
        existing = null;
      }

      if (!mounted) return;
      setState(() {
        _module = module;
        if (existing != null) {
          _answers = Map<String, dynamic>.from(existing.answers);
          _submissionId = existing.id;
          _showIntro = existing.isDraft;
          _dataConsent = existing.consentStatus == 'yes' || !_isPatientModule;
        }
        _answers.putIfAbsent(
          kQuestionnaireFormDepthKey,
          () => kQuestionnaireFormDepthKurz,
        );
        _rebuildSteps();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _rebuildSteps() {
    if (_module == null) return;
    _steps = buildQuestionnaireSteps(_module!, _answers);
    if (_stepIndex >= _steps.length) {
      _stepIndex = _steps.isEmpty ? 0 : _steps.length - 1;
    }
  }

  void _onAnswerChanged(String fieldId, dynamic value) {
    setState(() {
      _answers[fieldId] = value;
      _rebuildSteps();
    });
  }

  Future<void> _saveDraft() async {
    if (_module == null) return;
    setState(() => _isSaving = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = QuestionnaireService(api);
      final saved = await service.saveDraft(
        moduleId: widget.moduleId,
        answers: _answers,
        submissionId: _submissionId,
        linkedRapidTestId: widget.linkedRapidTestId,
        consentStatus: _consentStatusValue(),
      );
      if (saved != null && mounted) {
        setState(() => _submissionId = saved.id);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _consentStatusValue() {
    if (!_isPatientModule) return 'not_applicable';
    return _dataConsent ? 'yes' : 'no';
  }

  Future<void> _submit() async {
    if (_module == null) return;
    final errors = validateQuestionnaireSubmit(_module!, _answers);
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first), backgroundColor: AppTheme.errorColor),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = QuestionnaireService(api);
      final result = await service.submit(
        moduleId: widget.moduleId,
        answers: _answers,
        submissionId: _submissionId,
        linkedRapidTestId: widget.linkedRapidTestId,
        consentStatus: _consentStatusValue(),
      );
      if (!mounted) return;
      if (result != null) {
        final base = widget.isDoctor ? '/doctor/questionnaires' : '/questionnaires';
        context.go('$base/${widget.moduleId}/done${widget.returnRoute != null ? '?return=${Uri.encodeComponent(widget.returnRoute!)}' : ''}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _nextStep() {
    if (_module == null || _steps.isEmpty) return;
    final errors = validateQuestionnaireStep(_module!, _steps[_stepIndex].fields, _answers);
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first), backgroundColor: AppTheme.errorColor),
      );
      return;
    }
    _saveDraft();
    if (_stepIndex >= _steps.length - 1) {
      _submit();
      return;
    }
    setState(() => _stepIndex++);
  }

  void _prevStep() {
    if (_stepIndex > 0) {
      setState(() => _stepIndex--);
    }
  }

  void _setFormDepth(String depth) {
    setState(() {
      _answers[kQuestionnaireFormDepthKey] = normalizeFormDepth(depth);
      _stepIndex = 0;
      _rebuildSteps();
    });
  }

  Widget _buildDepthSwitch({required bool compact}) {
    final depth = formDepthFromAnswers(_answers);
    final selected = depth == kQuestionnaireFormDepthVoll ? 1 : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Fragebogenlänge',
          style: FigmaUi.rubik(
            fontSize: compact ? 15 : 17,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        FigmaSegmentedTabs(
          labels: const ['Kurzversion', 'Vollversion'],
          selectedIndex: selected,
          onSelected: (i) => _setFormDepth(
            i == 1 ? kQuestionnaireFormDepthVoll : kQuestionnaireFormDepthKurz,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          depth == kQuestionnaireFormDepthVoll
              ? 'Vollversion: alle Fragen aus dem PDF-Fachpaket (länger).'
              : 'Kurzversion: Kernfragen für Pilot und App (kürzer).',
          style: FigmaUi.bodyLight(
            fontSize: 15,
            color: AppTheme.textColorSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isPatientModule) ...[
          FigmaInsetInfoCard(
            icon: Icons.info_outline,
            title:
                'Dieser Fragebogen ersetzt keine ärztliche Diagnose. Bei akuten oder starken Beschwerden wenden Sie sich bitte an eine Ärztin oder einen Arzt.',
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _dataConsent,
            onChanged: (v) => setState(() => _dataConsent = v ?? false),
            title: Text(
              'Ich willige ein, dass meine Antworten zur Auswertung des RheumaCheck-Projekts gespeichert werden.',
              style: FigmaUi.rubik(fontSize: 17, color: AppTheme.textColor),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ] else
          FigmaInsetInfoCard(
            icon: Icons.medical_information_outlined,
            title:
                'Dieser Fragebogen dient der Forschung und Pilotierung von RheumaCheck. Es werden keine Diagnosen abgegeben.',
          ),
        const SizedBox(height: 24),
        _buildDepthSwitch(compact: false),
        const SizedBox(height: 28),
        NeumorphicPillButton(
          label: 'Fragebogen starten',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Schritt ${step.index} von ${step.total}',
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
        const SizedBox(height: 16),
        _buildDepthSwitch(compact: true),
        const SizedBox(height: 20),
        Text(
          step.sectionTitle,
          style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor),
        ),
        const SizedBox(height: 18),
        ...step.fields.map(
          (field) => QuestionnaireFieldWidget(
            field: field,
            value: _answers[field.id],
            onChanged: _onAnswerChanged,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_stepIndex > 0)
              Expanded(
                child: NeumorphicPillButton(
                  label: 'Zurück',
                  height: AppTheme.buttonHeightLarge,
                  backgroundColor: AppTheme.surface,
                  foregroundColor: AppTheme.textColor,
                  onPressed: _prevStep,
                ),
              ),
            if (_stepIndex > 0) const SizedBox(width: 12),
            Expanded(
              child: NeumorphicPillButton(
                label: _stepIndex >= _steps.length - 1 ? 'Absenden' : 'Weiter',
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
    final hubRoute = widget.isDoctor ? '/doctor/questionnaires' : '/questionnaires';

    return AdaptiveScreen(
      title: _module?.title ?? 'Fragebogen ${widget.moduleId}',
      showWebHeader: false,
      onBack: () => context.go(hubRoute),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? FigmaEmptyState(
                  icon: Icons.error_outline,
                  title: 'Fragebogen konnte nicht geladen werden',
                  message: 'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
                  actionLabel: 'Erneut versuchen',
                  onAction: _load,
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
                      child: _showIntro ? _buildIntro() : _buildStep(),
                    ),
                  ),
                ),
    );
  }
}
