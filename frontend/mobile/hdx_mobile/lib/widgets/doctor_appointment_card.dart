import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/doctor.dart';
import '../utils/gender_labels.dart';
import 'appointment_status_badge.dart';
import 'figma_ui.dart';

/// Raised appointment tile for the doctor portal (patient-centric labels).
class DoctorAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;
  final VoidCallback? onJoinCall;

  const DoctorAppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
    this.onJoinCall,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = appointment.appointmentTime;
    final dateStr =
        '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    final patientName = appointment.patientName ?? 'Patient';
    final genderLabel = formatGenderDe(appointment.patientGender);

    final nameStyle = FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor);
    final metaStyle = FigmaUi.rubik(fontSize: 12, fontWeight: FontWeight.w300, color: AppTheme.primaryBlue);

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
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  appointment.isOnline ? Icons.videocam_outlined : Icons.person_outline,
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
                              patientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: nameStyle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(genderLabel, style: metaStyle),
                          const SizedBox(width: 12),
                          Text(dateStr, style: metaStyle),
                          const SizedBox(width: 8),
                          Text(timeStr, style: metaStyle),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            patientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: nameStyle,
                          ),
                          const SizedBox(height: 4),
                          Text('$genderLabel · $dateStr  $timeStr', style: metaStyle),
                        ],
                      ),
              ),
              const SizedBox(width: 12),
              AppointmentStatusBadge(appointment: appointment),
              const SizedBox(width: 8),
              if (appointment.canJoin && onJoinCall != null)
                IconButton(
                  icon: const Icon(Icons.play_circle_fill, size: 22, color: AppTheme.successColor),
                  tooltip: 'Videoanruf starten',
                  onPressed: onJoinCall,
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textColorSecondary),
            ],
          );
        },
      ),
    );
  }
}
