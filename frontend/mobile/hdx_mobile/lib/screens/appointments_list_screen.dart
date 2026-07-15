import 'package:flutter/foundation.dart';
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        label,
        style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textColor),
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
          icon: const Icon(Icons.add, size: 28),
          tooltip: 'Neuer Termin',
          iconSize: 28,
          constraints: const BoxConstraints(
            minWidth: AppTheme.largeTouchTarget,
            minHeight: AppTheme.largeTouchTarget,
          ),
          onPressed: () => context.push('/doctors'),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
            kIsWeb ? 24 : AppTheme.screenHorizontalPadding,
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
                      'Tippen Sie auf einen Eintrag für Details.',
                      style: FigmaUi.bodyLight(
                        fontSize: 17,
                        color: AppTheme.textColorSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      FigmaEmptyState(
                        icon: Icons.error_outline,
                        title: 'Termine konnten nicht geladen werden',
                        message: 'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
                        actionLabel: 'Erneut versuchen',
                        onAction: _loadAppointments,
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
                        if (_upcoming.isNotEmpty) const SizedBox(height: 8),
                        _sectionTitle('Vergangen'),
                        ..._past.map(_appointmentCard),
                      ],
                    ],
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
    final dateStyle = FigmaUi.rubik(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppTheme.textColorSecondary,
    );
    final nameStyle = FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textColor);

    return NeumorphicRaisedCard(
      onTap: onTap,
      height: null,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final inlineMeta = constraints.maxWidth >= 520;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  appointment.isOnline ? Icons.videocam_outlined : Icons.event_outlined,
                  color: AppTheme.primaryBlue,
                  size: 26,
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
                          const SizedBox(height: 6),
                          Text(dateTimeLabel, style: dateStyle),
                        ],
                      ),
              ),
              const SizedBox(width: 12),
              AppointmentStatusBadge(appointment: appointment),
              const SizedBox(width: 8),
              if (appointment.canJoin)
                const Icon(Icons.play_circle_fill, size: 26, color: AppTheme.successColor)
              else
                const Icon(Icons.arrow_forward_ios, size: 18, color: AppTheme.textColorSecondary),
            ],
          );
        },
      ),
    );
  }
}
