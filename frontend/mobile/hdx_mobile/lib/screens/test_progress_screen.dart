import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/cube_service.dart';
import '../widgets/neumorphic.dart';
import 'test_result_screen.dart';

/// Full-screen step-by-step measurement progress.
///
/// Shows the Cube SDK lifecycle phases with clear, large visuals:
///   1. Place white cassette
///   2. Place test cassette
///   3. Timer countdown
///   4. Evaluation
///   5. Reading results
class TestProgressScreen extends StatefulWidget {
  final CubeService cubeService;
  final String testTypeId;
  final String testTypeName;

  const TestProgressScreen({
    super.key,
    required this.cubeService,
    required this.testTypeId,
    required this.testTypeName,
  });

  @override
  State<TestProgressScreen> createState() => _TestProgressScreenState();
}

class _TestProgressScreenState extends State<TestProgressScreen>
    with SingleTickerProviderStateMixin {
  CubeMeasureStep _currentStep = CubeMeasureStep.starting;
  String _currentLabel = 'Messung wird vorbereitet...';
  int? _secondsLeft;
  String? _errorMessage;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _startMeasurement();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startMeasurement() async {
    final result = await widget.cubeService.runTestAndSubmit(
      testTypeId: widget.testTypeId,
      onStep: (update) {
        if (!mounted) return;
        setState(() {
          _currentStep = update.step;
          _currentLabel = update.label;
          _secondsLeft = update.secondsLeft;
        });
      },
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TestResultScreen(
            testTypeName: widget.testTypeName,
            result: result,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = result.error ?? 'Unbekannter Fehler';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testTypeName),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _errorMessage != null ? _buildError(theme) : _buildProgress(theme),
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicContainer(
            padding: const EdgeInsets.all(24),
            child: Icon(Icons.error_outline, size: 80, color: AppTheme.errorColor),
          ),
          const SizedBox(height: 32),
          Text(
            'Messung fehlgeschlagen',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textColorSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
          NeumorphicButton(
            isPrimary: true,
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _currentStep = CubeMeasureStep.starting;
                _currentLabel = 'Messung wird vorbereitet...';
                _secondsLeft = null;
              });
              _startMeasurement();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Colors.white),
                SizedBox(width: 12),
                Text('Erneut versuchen'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          NeumorphicButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Zurück zum Start'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildActiveStepCard(theme),
          const SizedBox(height: 32),
          Expanded(child: _buildStepsList(theme)),
        ],
      ),
    );
  }

  Widget _buildActiveStepCard(ThemeData theme) {
    final icon = _iconForStep(_currentStep);
    final color = _colorForStep(_currentStep);

    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + _pulseController.value * 0.08;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _currentLabel,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
              height: 1.3,
            ),
          ),
          if (_currentStep == CubeMeasureStep.timerRunning && _secondsLeft != null) ...[
            const SizedBox(height: 16),
            _buildTimerDisplay(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(ThemeData theme) {
    final secs = _secondsLeft ?? 0;
    final mins = secs ~/ 60;
    final rem = secs % 60;
    final timeStr = '${mins.toString().padLeft(2, '0')}:${rem.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Text(
          timeStr,
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            fontSize: 56,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'verbleibend',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textColorSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepsList(ThemeData theme) {
    final steps = _allSteps;
    final currentIdx = steps.indexWhere((s) => s.step == _currentStep);

    return ListView.builder(
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final s = steps[index];
        final isActive = index == currentIdx;
        final isCompleted = index < currentIdx;
        final isFuture = index > currentIdx;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF48BB78)
                      : isActive
                          ? AppTheme.primaryColor
                          : AppTheme.baseColor,
                  shape: BoxShape.circle,
                  border: isFuture
                      ? Border.all(color: AppTheme.darkShadow.withValues(alpha: 0.3), width: 2)
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : AppTheme.textColorSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  s.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isActive
                        ? AppTheme.textColor
                        : isFuture
                            ? AppTheme.textColorSecondary.withValues(alpha: 0.5)
                            : AppTheme.textColorSecondary,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _iconForStep(CubeMeasureStep step) {
    switch (step) {
      case CubeMeasureStep.starting:
        return Icons.play_circle_outline;
      case CubeMeasureStep.placeWhite:
        return Icons.credit_card;
      case CubeMeasureStep.placeTest:
        return Icons.science;
      case CubeMeasureStep.timerRunning:
        return Icons.timer;
      case CubeMeasureStep.evaluating:
        return Icons.analytics;
      case CubeMeasureStep.readingResults:
        return Icons.downloading;
      case CubeMeasureStep.submitting:
        return Icons.cloud_upload;
      case CubeMeasureStep.done:
        return Icons.check_circle;
      case CubeMeasureStep.error:
        return Icons.error_outline;
    }
  }

  Color _colorForStep(CubeMeasureStep step) {
    switch (step) {
      case CubeMeasureStep.starting:
        return AppTheme.primaryColor;
      case CubeMeasureStep.placeWhite:
        return const Color(0xFF6B8DD6);
      case CubeMeasureStep.placeTest:
        return const Color(0xFF8B5CF6);
      case CubeMeasureStep.timerRunning:
        return const Color(0xFFF59E0B);
      case CubeMeasureStep.evaluating:
        return const Color(0xFFEC4899);
      case CubeMeasureStep.readingResults:
        return const Color(0xFF10B981);
      case CubeMeasureStep.submitting:
        return AppTheme.primaryColor;
      case CubeMeasureStep.done:
        return const Color(0xFF48BB78);
      case CubeMeasureStep.error:
        return AppTheme.errorColor;
    }
  }

  List<_StepInfo> get _allSteps => const [
        _StepInfo(step: CubeMeasureStep.placeWhite, label: 'Weiße Kassette einlegen'),
        _StepInfo(step: CubeMeasureStep.placeTest, label: 'Testkassette einlegen'),
        _StepInfo(step: CubeMeasureStep.timerRunning, label: 'Inkubationszeit'),
        _StepInfo(step: CubeMeasureStep.evaluating, label: 'Messung auswerten'),
        _StepInfo(step: CubeMeasureStep.readingResults, label: 'Ergebnisse laden'),
        _StepInfo(step: CubeMeasureStep.submitting, label: 'Ergebnisse übermitteln'),
      ];
}

class _StepInfo {
  final CubeMeasureStep step;
  final String label;
  const _StepInfo({required this.step, required this.label});
}
