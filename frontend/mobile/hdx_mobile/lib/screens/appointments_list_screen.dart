import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';
import '../services/appointment_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/web/adaptive_screen.dart';
import '../widgets/appointment_status_badge.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = AppointmentService(api);
      final appointments = await service.listAppointments();
      if (!mounted) return;
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _appointments = [];
        _isLoading = false;
      });
    }
  }

  List<Appointment> get _upcoming => _appointments.where((a) => a.isUpcoming).toList();

  List<Appointment> get _past => _appointments.where((a) => !a.isUpcoming).toList();

  Widget _sectionTitle(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: FigmaUi.rubik(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textColorSecondary),
      ),
    );
  }

  Widget _appointmentCard(Appointment appointment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
      child: _AppointmentCard(
        appointment: appointment,
        onTap: () => context.push('/appointments/${appointment.id}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Meine Termine',
      showBackOnMobile: false,
      onBack: () => context.go('/home'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Neuer Termin',
          onPressed: () => context.push('/doctors'),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              'Tippen Sie auf einen Eintrag für Details.',
              style: FigmaUi.bodyLight(
                fontSize: 14,
                color: AppTheme.textColorSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_error != null)
              FigmaListCard(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.error_outline, color: AppTheme.errorColor),
                ),
                title: 'Termine konnten nicht geladen werden',
                subtitle: _error!,
              )
            else if (_appointments.isEmpty)
              FigmaEmptyState(
                icon: Icons.event_outlined,
                title: 'Noch keine Termine',
                message: 'Buchen Sie einen Termin bei einem Arzt, um ihn hier zu sehen.',
                actionLabel: 'Arzt finden',
                onAction: () => context.push('/doctors'),
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

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const _AppointmentCard({required this.appointment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateTime = appointment.appointmentTime;
    final dateStr =
        '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    final dateTimeLabel = '$dateStr  $timeStr';
    final dateStyle = FigmaUi.rubik(fontSize: 12, fontWeight: FontWeight.w300, color: AppTheme.primaryBlue);
    final nameStyle = FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor);

    return NeumorphicRaisedCard(
      onTap: onTap,
      height: null,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final inlineMeta = constraints.maxWidth >= 520;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  appointment.isOnline ? Icons.videocam_outlined : Icons.event_outlined,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: inlineMeta
                    ? Row(
                        children: [
                          Flexible(
                            child: Text(
                              appointment.doctorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: nameStyle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(dateStr, style: dateStyle),
                          const SizedBox(width: 8),
                          Text(timeStr, style: dateStyle),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            appointment.doctorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: nameStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(dateTimeLabel, style: dateStyle),
                        ],
                      ),
              ),
              const SizedBox(width: 12),
              AppointmentStatusBadge(appointment: appointment),
              const SizedBox(width: 8),
              if (appointment.canJoin)
                const Icon(Icons.play_circle_fill, size: 20, color: AppTheme.successColor)
              else
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textColorSecondary),
            ],
          );
        },
      ),
    );
  }
}
