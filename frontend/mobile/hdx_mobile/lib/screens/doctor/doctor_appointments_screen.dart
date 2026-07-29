import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/doctor.dart';
import '../../core/api_service.dart';
import '../../services/appointment_service.dart';
import '../../widgets/doctor/doctor_appointment_calendar.dart';
import '../../widgets/doctor_appointment_card.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/web/adaptive_screen.dart';

enum _ViewMode { list, calendar }

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _error;
  _ViewMode _viewMode = _ViewMode.calendar;

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
      final service = AppointmentService(api);
      final appointments = await service.listAppointments();
      if (mounted) {
        setState(() {
          _appointments = appointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _appointments = [];
          _isLoading = false;
        });
      }
    }
  }

  List<Appointment> get _upcoming =>
      _appointments.where((a) => a.isUpcoming).toList();

  List<Appointment> get _past =>
      _appointments.where((a) => !a.isUpcoming).toList();

  Widget _sectionTitle(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: FigmaUi.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textColorSecondary,
        ),
      ),
    );
  }

  Widget _appointmentCard(Appointment appointment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
      child: DoctorAppointmentCard(
        appointment: appointment,
        onTap: () => context.push('/doctor/appointments/${appointment.id}'),
        onJoinCall: appointment.canJoin
            ? () => context.push('/doctor/appointments/${appointment.id}/call')
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Alle Termine',
      showWebHeader: false,
      showBackOnMobile: false,
      onBack: () => context.go('/doctor/dashboard'),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
            kIsWeb ? 24 : 8,
            kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
            24,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _viewMode == _ViewMode.list
                        ? 'Tippen Sie auf einen Eintrag für Details.'
                        : 'Tippen Sie auf einen Termin für Details.',
                    style: FigmaUi.bodyLight(
                      fontSize: 14,
                      color: AppTheme.textColorSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 176,
                  child: FigmaSegmentedTabs(
                    labels: const ['Liste', 'Kalender'],
                    selectedIndex: _viewMode.index,
                    selectedColor: AppTheme.accentBlue,
                    onSelected: (i) => setState(() => _viewMode = _ViewMode.values[i]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              FigmaListCard(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.error_outline, color: AppTheme.errorColor),
                ),
                title: 'Termine konnten nicht geladen werden',
                subtitle: _error!,
              )
            else if (_viewMode == _ViewMode.calendar)
              DoctorAppointmentCalendar(
                appointments: _appointments,
                onTapAppointment: (a) => context.push('/doctor/appointments/${a.id}'),
              )
            else if (_appointments.isEmpty)
              FigmaListCard(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_outlined, color: AppTheme.primaryBlue),
                ),
                title: 'Noch keine Termine',
                subtitle: 'Gebuchte Patiententermine erscheinen hier.',
              )
            else ...[
              if (_upcoming.isNotEmpty) ...[
                _sectionTitle('Bevorstehend'),
                ..._upcoming.map(_appointmentCard),
              ],
              if (_past.isNotEmpty) ...[
                if (_upcoming.isNotEmpty) const SizedBox(height: 4),
                _sectionTitle('Vergangen'),
                ..._past.map(_appointmentCard),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
