import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/doctor.dart';
import '../../services/api_service.dart';
import '../../services/doctor_service.dart';
import '../../widgets/web/adaptive_screen.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  State<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  static const _dayNames = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];

  final Map<int, bool> _enabled = {for (var i = 1; i <= 7; i++) i: i <= 5};
  final Map<int, TextEditingController> _startControllers = {};
  final Map<int, TextEditingController> _endControllers = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (var i = 1; i <= 7; i++) {
      _startControllers[i] = TextEditingController(text: '09:00');
      _endControllers[i] = TextEditingController(text: '17:00');
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
    setState(() => _isLoading = true);
    final api = Provider.of<ApiService>(context, listen: false);
    final service = DoctorService(api);
    final rules = await service.getDoctorAvailability();
    for (var i = 1; i <= 7; i++) {
      _enabled[i] = false;
    }
    for (final rule in rules) {
      _enabled[rule.dayOfWeek] = true;
      _startControllers[rule.dayOfWeek]!.text = rule.startTime;
      _endControllers[rule.dayOfWeek]!.text = rule.endTime;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final rules = <DoctorAvailabilityRule>[];
    for (var i = 1; i <= 7; i++) {
      if (_enabled[i] == true) {
        rules.add(DoctorAvailabilityRule(
          dayOfWeek: i,
          startTime: _startControllers[i]!.text.trim(),
          endTime: _endControllers[i]!.text.trim(),
        ));
      }
    }

    final api = Provider.of<ApiService>(context, listen: false);
    final service = DoctorService(api);
    final ok = await service.setDoctorAvailability(rules);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Verfügbarkeit gespeichert' : 'Speichern fehlgeschlagen'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Verfügbarkeit',
      showBackOnMobile: false,
      onBack: () => context.go('/doctor/dashboard'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                const Text(
                  'Wöchentliche Sprechzeiten',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (kIsWeb)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoCol = constraints.maxWidth >= 700;
                      final days = List.generate(7, (index) => _buildDayCard(index + 1));
                      if (twoCol) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Column(children: days.take(4).toList())),
                            const SizedBox(width: 16),
                            Expanded(child: Column(children: days.skip(4).toList())),
                          ],
                        );
                      }
                      return Column(children: days);
                    },
                  )
                else
                  ...List.generate(7, (index) => _buildDayCard(index + 1)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? 'Speichern...' : 'Speichern'),
                ),
              ],
            ),
    );
  }

  Widget _buildDayCard(int day) {
    final index = day - 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_dayNames[index]),
              value: _enabled[day] ?? false,
              onChanged: (v) => setState(() => _enabled[day] = v),
            ),
            if (_enabled[day] == true)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startControllers[day],
                      decoration: const InputDecoration(labelText: 'Von', hintText: '09:00'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _endControllers[day],
                      decoration: const InputDecoration(labelText: 'Bis', hintText: '17:00'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
