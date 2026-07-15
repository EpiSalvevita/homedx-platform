import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/doctor.dart';
import '../utils/gender_labels.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/appointment_service.dart';
import '../utils/test_type_labels.dart';
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
    final messageController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: AppTheme.surface,
        title: Text(
          'Termin stornieren',
          style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Möchten Sie diesen Termin wirklich stornieren? Sie können optional eine Nachricht an die andere Person senden.',
              style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w400, color: AppTheme.textColorSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              maxLength: 500,
              style: FigmaUi.rubik(fontSize: 17, color: AppTheme.textColor),
              decoration: InputDecoration(
                labelText: 'Nachricht (optional)',
                hintText: 'Grund für die Stornierung…',
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.navy.withValues(alpha: 0.12)),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(0, AppTheme.largeTouchTarget)),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Abbrechen',
              style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w500, color: AppTheme.textColor),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(0, AppTheme.largeTouchTarget)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Stornieren',
              style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      messageController.dispose();
      return;
    }

    final message = messageController.text;
    messageController.dispose();

    setState(() => _isCancelling = true);
    final api = Provider.of<ApiService>(context, listen: false);
    final service = AppointmentService(api);
    final ok = await service.cancelAppointment(widget.appointmentId, message: message);
    if (mounted) {
      setState(() => _isCancelling = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Termin storniert'), backgroundColor: AppTheme.successColor),
        );
        await _loadAppointment();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stornierung fehlgeschlagen'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildDetailCard(Appointment appointment, String formatted, {required bool isDoctor}) {
    final bodyStyle = FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w400, color: AppTheme.textColor);
    final labelStyle = FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textColorSecondary);
    final headline = isDoctor
        ? (appointment.patientName ?? 'Patient')
        : appointment.doctorName;

    return NeumorphicRaisedCard(
      height: null,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  headline,
                  style: FigmaUi.rubik(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.textColor),
                ),
              ),
              AppointmentStatusBadge(appointment: appointment),
            ],
          ),
          if (isDoctor && appointment.patientGender != null) ...[
            const SizedBox(height: 16),
            Text('Geschlecht', style: labelStyle),
            const SizedBox(height: 6),
            Text(formatGenderDe(appointment.patientGender), style: bodyStyle),
          ],
          if (!isDoctor && appointment.patientName != null) ...[
            const SizedBox(height: 16),
            Text('Patient', style: labelStyle),
            const SizedBox(height: 6),
            Text(appointment.patientName!, style: bodyStyle),
          ],
          if (!isDoctor && appointment.patientGender != null) ...[
            const SizedBox(height: 16),
            Text('Geschlecht', style: labelStyle),
            const SizedBox(height: 6),
            Text(formatGenderDe(appointment.patientGender), style: bodyStyle),
          ],
          const SizedBox(height: 16),
          Text('Termin', style: labelStyle),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 22, color: AppTheme.primaryBlue),
              const SizedBox(width: 10),
              Expanded(child: Text(formatted, style: bodyStyle)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Art', style: labelStyle),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                appointment.isOnline ? Icons.videocam_outlined : Icons.location_on_outlined,
                size: 22,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 10),
              Text(
                appointment.isOnline ? 'Online-Beratung' : 'Vor-Ort-Termin',
                style: bodyStyle,
              ),
            ],
          ),
          if (appointment.testTypeId != null && appointment.testTypeId!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Zugehöriger Test', style: labelStyle),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.science_outlined, size: 22, color: AppTheme.primaryBlue),
                const SizedBox(width: 10),
                Text(testTypeDisplayName(appointment.testTypeId), style: bodyStyle),
              ],
            ),
          ],
          if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Notizen', style: labelStyle),
            const SizedBox(height: 6),
            Text(appointment.notes!, style: bodyStyle),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(Appointment appointment, {required bool isDoctor}) {
    final callRoute = isDoctor
        ? '/doctor/appointments/${appointment.id}/call'
        : '/appointments/${appointment.id}/call';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (appointment.canJoin && appointment.isOnline) ...[
          NeumorphicPillButton(
            label: 'Videoanruf beitreten',
            leadingIcon: Icons.videocam_outlined,
            height: AppTheme.buttonHeightLarge,
            onPressed: () => context.push(callRoute),
          ),
          const SizedBox(height: 16),
        ],
        if (appointment.isUpcoming)
          Center(
            child: NeumorphicPillButton(
              label: 'Termin stornieren',
              height: AppTheme.buttonHeightLarge,
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
    final isDoctor = context.watch<AuthProvider>().isDoctor;

    return AdaptiveScreen(
      title: 'Termindetails',
      showWebHeader: false,
      onBack: () => context.pop(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointment == null
              ? Center(
                  child: Text(
                    'Termin nicht gefunden',
                    style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final appointment = _appointment!;
                    final formatted = DateFormat('EEEE, dd.MM.yyyy HH:mm', 'de_DE')
                        .format(appointment.appointmentTime);

                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                        kIsWeb ? 24 : 8,
                        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                        24,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 800,
                            minHeight: constraints.maxHeight - 32,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildDetailCard(appointment, formatted, isDoctor: isDoctor),
                              const SizedBox(height: 28),
                              _buildActions(appointment, isDoctor: isDoctor),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
