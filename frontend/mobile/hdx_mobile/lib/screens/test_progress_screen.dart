import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../config/app_theme.dart';
import '../services/cube_service.dart';
import '../utils/constants.dart';
import '../utils/cube_test_config_assets.dart';
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

  /// Forwarded to [CubeService.runTestAndSubmit]. Defaults to true so the
  /// Cube SDK runs the standardized incubation timer baked into the cassette
  /// test configuration.
  final bool useTimer;

  /// When non-null, Cube evaluation uses this file (e.g. picked `.config` / `.bin`)
  /// instead of the cassette RFID calibration — same as the vendor app’s
  /// “Datei” / `OpenDocument` path.
  final String? cubeConfigAbsolutePath;

  /// Android `content://` or `file://` when the picker exposes a Uri rather than a path.
  final String? cubeConfigUri;

  const TestProgressScreen({
    super.key,
    required this.cubeService,
    required this.testTypeId,
    required this.testTypeName,
    this.useTimer = true,
    this.cubeConfigAbsolutePath,
    this.cubeConfigUri,
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
    widget.cubeService.startListening();
    if (kDebugMode) {
      debugPrint('TestProgressScreen: Cube EventChannel listen ensured');
    }
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

  Future<void> _leaveToHome() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test abbrechen?'),
        content: const Text(
          'Möchten Sie die Messung verlassen und zur Startseite zurückkehren?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Weiter'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Zur Startseite'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      context.go('/home');
    }
  }

  Future<void> _startMeasurement() async {
    final hasPickedFile = (widget.cubeConfigAbsolutePath != null &&
            widget.cubeConfigAbsolutePath!.trim().isNotEmpty) ||
        (widget.cubeConfigUri != null &&
            widget.cubeConfigUri!.trim().isNotEmpty);
    final configAssetName = hasPickedFile
        ? null
        : cubeConfigAssetBasenameForTestType(widget.testTypeId);

    developer.log(
      'TestProgress: runTestAndSubmit testTypeId=${widget.testTypeId} useTimer=${widget.useTimer} '
      'asset=$configAssetName path=${widget.cubeConfigAbsolutePath} uri=${widget.cubeConfigUri}',
      name: 'HDX_CUBE',
    );

    final result = await widget.cubeService.runTestAndSubmit(
      testTypeId: widget.testTypeId,
      useTimer: widget.useTimer,
      configAssetName: configAssetName,
      configAbsolutePath: widget.cubeConfigAbsolutePath,
      configUri: widget.cubeConfigUri,
      onStep: (update) {
        if (AppConstants.cubeVerboseLogging) {
          developer.log(
            'TestProgress: onStep step=${update.step.name} label="${update.label}" '
            'secs=${update.secondsLeft} test=${widget.testTypeId}',
            name: 'HDX_CUBE',
          );
        }
        if (!mounted) return;
        setState(() {
          _currentStep = update.step;
          _currentLabel = update.label;
          _secondsLeft = update.secondsLeft;
        });
      },
    );

    if (!mounted) return;

    developer.log(
      'TestProgress: runTestAndSubmit finished success=${result.success} error=${result.error} testId=${result.testId}',
      name: 'HDX_CUBE',
    );

    if (result.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TestResultScreen(
            testTypeName: widget.testTypeName,
            result: result,
            testTypeId: widget.testTypeId,
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leaveToHome();
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(widget.testTypeName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _leaveToHome,
        ),
      ),
      body: SafeArea(
        child: _errorMessage != null ? _buildError(theme) : _buildProgress(theme),
      ),
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
            onPressed: () => context.go('/home'),
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
                      ? AppTheme.successColor
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
                      ? const Icon(Icons.check, color: AppTheme.onMint, size: 22)
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
        return AppTheme.accentBlue;
      case CubeMeasureStep.placeTest:
        return AppTheme.navy;
      case CubeMeasureStep.timerRunning:
        return AppTheme.accentCoral;
      case CubeMeasureStep.evaluating:
        return AppTheme.primaryBlue;
      case CubeMeasureStep.readingResults:
        return AppTheme.accentMint;
      case CubeMeasureStep.submitting:
        return AppTheme.primaryColor;
      case CubeMeasureStep.done:
        return AppTheme.successColor;
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
