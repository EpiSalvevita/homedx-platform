import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/doctor.dart';
import '../../services/api_service.dart';
import '../../services/doctor_service.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/web/adaptive_screen.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  State<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  static const _weekdays = [1, 2, 3, 4, 5];
  static const _dayNames = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
  ];

  final Map<int, bool> _enabled = {for (final day in _weekdays) day: true};
  final Map<int, TextEditingController> _startControllers = {};
  final Map<int, TextEditingController> _endControllers = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    for (final day in _weekdays) {
      _startControllers[day] = TextEditingController(text: '09:00');
      _endControllers[day] = TextEditingController(text: '17:00');
    }
    _load();
  }

  @override
  void dispose() {
    for (final c in _startControllers.values) {
      c.dispose();
    }
    for (final c in _endControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = DoctorService(api);
      final rules = await service.getDoctorAvailability();
      for (final day in _weekdays) {
        _enabled[day] = false;
      }
      for (final rule in rules) {
        if (!_weekdays.contains(rule.dayOfWeek)) continue;
        _enabled[rule.dayOfWeek] = true;
        _startControllers[rule.dayOfWeek]!.text = rule.startTime;
        _endControllers[rule.dayOfWeek]!.text = rule.endTime;
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final rules = <DoctorAvailabilityRule>[];
    for (final day in _weekdays) {
      if (_enabled[day] == true) {
        rules.add(DoctorAvailabilityRule(
          dayOfWeek: day,
          startTime: _startControllers[day]!.text.trim(),
          endTime: _endControllers[day]!.text.trim(),
        ));
      }
    }

    bool ok = false;
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = DoctorService(api);
      ok = await service.setDoctorAvailability(rules);
    } catch (_) {
      ok = false;
    }
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Verfügbarkeit gespeichert' : 'Speichern fehlgeschlagen'),
          backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Verfügbarkeit',
      showWebHeader: false,
      showBackOnMobile: false,
      onBack: () => context.go('/doctor/dashboard'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 40, color: AppTheme.errorColor),
                        const SizedBox(height: 12),
                        Text(
                          'Verfügbarkeit konnte nicht geladen werden',
                          textAlign: TextAlign.center,
                          style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _loadError!,
                          textAlign: TextAlign.center,
                          style: FigmaUi.bodyLight(fontSize: 13, color: AppTheme.textColorSecondary),
                        ),
                        const SizedBox(height: 16),
                        NeumorphicPillButton(label: 'Erneut versuchen', expanded: false, onPressed: _load),
                      ],
                    ),
                  ),
                )
              : ListView(
              padding: EdgeInsets.fromLTRB(
                kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                kIsWeb ? 24 : 8,
                kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                24,
              ),
              children: [
                Text(
                  'Legen Sie fest, wann Patienten Termine bei Ihnen buchen können.',
                  style: FigmaUi.bodyLight(
                    fontSize: 14,
                    color: AppTheme.textColorSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                const FigmaSectionTitle('Wöchentliche Sprechzeiten'),
                const SizedBox(height: 12),
                if (kIsWeb)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoCol = constraints.maxWidth >= 700;
                      final days = _weekdays.map(_buildDayCard).toList();
                      if (twoCol) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Column(children: days.take(3).toList())),
                            const SizedBox(width: 16),
                            Expanded(child: Column(children: days.skip(3).toList())),
                          ],
                        );
                      }
                      return Column(children: days);
                    },
                  )
                else
                  ..._weekdays.map(_buildDayCard),
                const SizedBox(height: 24),
                NeumorphicPillButton(
                  label: _isSaving ? 'Speichern…' : 'Änderungen speichern',
                  leadingIcon: Icons.save_outlined,
                  loading: _isSaving,
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
    );
  }

  Widget _buildDayCard(int day) {
    final index = _weekdays.indexOf(day);
    final isEnabled = _enabled[day] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.infoInsetCardSpacing),
      child: NeumorphicRaisedCard(
        height: null,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dayNames[index],
                    style: FigmaUi.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: isEnabled,
                  activeThumbColor: AppTheme.primaryBlue,
                  onChanged: (v) => setState(() => _enabled[day] = v),
                ),
              ],
            ),
            if (isEnabled) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: NeumorphicInsetField(
                      controller: _startControllers[day]!,
                      label: 'Von',
                      hint: '09:00',
                      prefixIcon: Icons.schedule_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeumorphicInsetField(
                      controller: _endControllers[day]!,
                      label: 'Bis',
                      hint: '17:00',
                      prefixIcon: Icons.schedule_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
