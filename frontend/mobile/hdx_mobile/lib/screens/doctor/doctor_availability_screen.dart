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

/// A single Von/Bis time range within a day, backed by its own controllers
/// so multiple ranges can coexist per weekday.
class _TimeRange {
  final int id;
  final TextEditingController startController;
  final TextEditingController endController;

  _TimeRange({required this.id, String start = '09:00', String end = '17:00'})
      : startController = TextEditingController(text: start),
        endController = TextEditingController(text: end);

  void dispose() {
    startController.dispose();
    endController.dispose();
  }
}

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
  final Map<int, List<_TimeRange>> _ranges = {
    for (final day in _weekdays) day: <_TimeRange>[],
  };
  int _nextRangeId = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    for (final day in _weekdays) {
      _ranges[day]!.add(_TimeRange(id: _nextRangeId++));
    }
    _load();
  }

  @override
  void dispose() {
    for (final ranges in _ranges.values) {
      for (final range in ranges) {
        range.dispose();
      }
    }
    super.dispose();
  }

  int? _parseTimeToMinutes(String value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return hour * 60 + minute;
  }

  bool _isValidRange(String start, String end) {
    final startMin = _parseTimeToMinutes(start);
    final endMin = _parseTimeToMinutes(end);
    if (startMin == null || endMin == null) return false;
    return endMin > startMin;
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
        for (final range in _ranges[day]!) {
          range.dispose();
        }
        _ranges[day] = [];
        _enabled[day] = false;
      }

      for (final rule in rules) {
        if (!_weekdays.contains(rule.dayOfWeek)) continue;
        _enabled[rule.dayOfWeek] = true;
        _ranges[rule.dayOfWeek]!.add(_TimeRange(
          id: _nextRangeId++,
          start: rule.startTime,
          end: rule.endTime,
        ));
      }

      for (final day in _weekdays) {
        if (_ranges[day]!.isEmpty) {
          _ranges[day]!.add(_TimeRange(id: _nextRangeId++));
        }
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

  void _addRange(int day) {
    setState(() {
      _ranges[day]!.add(_TimeRange(id: _nextRangeId++));
    });
  }

  void _removeRange(int day, int id) {
    setState(() {
      final list = _ranges[day]!;
      if (list.length <= 1) return;
      final index = list.indexWhere((r) => r.id == id);
      if (index != -1) {
        list.removeAt(index).dispose();
      }
    });
  }

  Future<void> _save() async {
    for (final day in _weekdays) {
      if (_enabled[day] != true) continue;
      for (final range in _ranges[day]!) {
        final start = range.startController.text.trim();
        final end = range.endController.text.trim();
        if (!_isValidRange(start, end)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ungültiges Zeitfenster an ${_dayNames[_weekdays.indexOf(day)]}: "$start" – "$end". "Bis" muss nach "Von" liegen.',
              ),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        }
      }
    }

    setState(() => _isSaving = true);
    final rules = <DoctorAvailabilityRule>[];
    for (final day in _weekdays) {
      if (_enabled[day] == true) {
        for (final range in _ranges[day]!) {
          rules.add(DoctorAvailabilityRule(
            dayOfWeek: day,
            startTime: range.startController.text.trim(),
            endTime: range.endController.text.trim(),
          ));
        }
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
                  'Legen Sie fest, wann Patienten Termine bei Ihnen buchen können. Sie können pro Tag mehrere Zeitfenster hinzufügen, z. B. vormittags und nachmittags.',
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
    final ranges = _ranges[day]!;

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
              for (final range in ranges)
                Padding(
                  key: ValueKey(range.id),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: NeumorphicInsetField(
                          controller: range.startController,
                          label: 'Von',
                          hint: '09:00',
                          prefixIcon: Icons.schedule_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeumorphicInsetField(
                          controller: range.endController,
                          label: 'Bis',
                          hint: '17:00',
                          prefixIcon: Icons.schedule_outlined,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: ranges.length > 1
                            ? AppTheme.errorColor
                            : AppTheme.textColorSecondary.withValues(alpha: 0.35),
                        tooltip: 'Zeitfenster entfernen',
                        onPressed: ranges.length > 1 ? () => _removeRange(day, range.id) : null,
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _addRange(day),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Zeitfenster hinzufügen'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
