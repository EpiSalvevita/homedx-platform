import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/doctor.dart';
import '../utils/gender_labels.dart';
import '../services/api_service.dart';
import '../services/appointment_service.dart';
import '../widgets/appointment_status_badge.dart';
import '../widgets/figma_ui.dart';
import '../widgets/web/adaptive_screen.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  Appointment? _appointment;
  bool _isLoading = true;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    setState(() => _isLoading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = AppointmentService(api);
      final appointment = await service.getAppointment(widget.appointmentId);
      if (mounted) {
        setState(() {
          _appointment = appointment;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelAppointment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termin stornieren'),
        content: const Text('Möchten Sie diesen Termin wirklich stornieren?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stornieren'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    final api = Provider.of<ApiService>(context, listen: false);
    final service = AppointmentService(api);
    final ok = await service.cancelAppointment(widget.appointmentId);
    if (mounted) {
      setState(() => _isCancelling = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Termin storniert')),
        );
        await _loadAppointment();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stornierung fehlgeschlagen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailCard(Appointment appointment, String formatted) {
    final bodyStyle = FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textColor);
    final labelStyle = FigmaUi.rubik(fontSize: 13, fontWeight: FontWeight.w300, color: AppTheme.textColorSecondary);

    return NeumorphicRaisedCard(
      height: null,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appointment.doctorName,
                  style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                ),
              ),
              AppointmentStatusBadge(appointment: appointment),
            ],
          ),
          if (appointment.patientName != null) ...[
            const SizedBox(height: 12),
            Text('Patient', style: labelStyle),
            const SizedBox(height: 4),
            Text(appointment.patientName!, style: bodyStyle),
          ],
          if (appointment.patientGender != null) ...[
            const SizedBox(height: 12),
            Text('Geschlecht', style: labelStyle),
            const SizedBox(height: 4),
            Text(formatGenderDe(appointment.patientGender), style: bodyStyle),
          ],
          const SizedBox(height: 12),
          Text('Termin', style: labelStyle),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Expanded(child: Text(formatted, style: bodyStyle)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Art', style: labelStyle),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                appointment.isOnline ? Icons.videocam_outlined : Icons.location_on_outlined,
                size: 18,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                appointment.isOnline ? 'Online-Beratung' : 'Vor-Ort-Termin',
                style: bodyStyle,
              ),
            ],
          ),
          if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Notizen', style: labelStyle),
            const SizedBox(height: 4),
            Text(appointment.notes!, style: bodyStyle),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(Appointment appointment) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (appointment.canJoin && appointment.isOnline) ...[
          NeumorphicPillButton(
            label: 'Videoanruf beitreten',
            leadingIcon: Icons.videocam_outlined,
            height: 48,
            onPressed: () => context.push('/appointments/${appointment.id}/call'),
          ),
          const SizedBox(height: 12),
        ],
        if (appointment.isUpcoming)
          Center(
            child: NeumorphicPillButton(
              label: 'Termin stornieren',
              height: 48,
              expanded: false,
              loading: _isCancelling,
              backgroundColor: AppTheme.accentCoral,
              foregroundColor: AppTheme.navy,
              onPressed: _isCancelling ? null : _cancelAppointment,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Termindetails',
      onBack: () => context.pop(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointment == null
              ? Center(
                  child: Text(
                    'Termin nicht gefunden',
                    style: FigmaUi.rubik(color: AppTheme.textColor),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final appointment = _appointment!;
                    final formatted = DateFormat('EEEE, dd.MM.yyyy HH:mm', 'de_DE')
                        .format(appointment.appointmentTime);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.screenHorizontalPadding,
                        8,
                        AppTheme.screenHorizontalPadding,
                        24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (kIsWeb) ...[
                              Text(
                                'Termindetails',
                                textAlign: TextAlign.center,
                                style: FigmaUi.rubik(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            _buildDetailCard(appointment, formatted),
                            const SizedBox(height: 24),
                            _buildActions(appointment),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
