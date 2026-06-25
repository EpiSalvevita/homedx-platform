import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/doctor.dart';
import '../utils/gender_labels.dart';
import '../services/api_service.dart';
import '../services/appointment_service.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Termindetails')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final appointment = _appointment;
    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Termindetails')),
        body: const Center(child: Text('Termin nicht gefunden')),
      );
    }

    final formatted =
        DateFormat('EEEE, dd.MM.yyyy HH:mm', 'de_DE').format(appointment.appointmentTime);

    return Scaffold(
      appBar: AppBar(title: const Text('Termindetails')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (appointment.patientName != null) ...[
                      const SizedBox(height: 8),
                      Text('Patient: ${appointment.patientName}'),
                    ],
                    if (appointment.patientGender != null) ...[
                      const SizedBox(height: 8),
                      Text('Geschlecht: ${formatGenderDe(appointment.patientGender)}'),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(formatted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          appointment.isOnline
                              ? Icons.video_call
                              : Icons.location_on,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(appointment.isOnline
                            ? 'Online-Beratung'
                            : 'Vor-Ort-Termin'),
                      ],
                    ),
                    if (appointment.notes != null &&
                        appointment.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Notizen: ${appointment.notes}'),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (appointment.canJoin && appointment.isOnline)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.push('/appointments/${appointment.id}/call'),
                  icon: const Icon(Icons.video_call),
                  label: const Text('Videoanruf beitreten'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            if (appointment.isUpcoming) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isCancelling ? null : _cancelAppointment,
                  child: Text(_isCancelling
                      ? 'Wird storniert...'
                      : 'Termin stornieren'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
