import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/doctor.dart';
import '../../services/api_service.dart';
import '../../services/appointment_service.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final api = Provider.of<ApiService>(context, listen: false);
    final service = AppointmentService(api);
    final appointments = await service.listAppointments();
    if (mounted) {
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alle Termine')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  final a = _appointments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(a.patientName ?? 'Patient'),
                      subtitle: Text(DateFormat('dd.MM.yyyy HH:mm')
                          .format(a.appointmentTime)),
                      trailing: a.canJoin
                          ? const Icon(Icons.video_call, color: Colors.green)
                          : null,
                      onTap: () => context.push('/doctor/appointments/${a.id}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
