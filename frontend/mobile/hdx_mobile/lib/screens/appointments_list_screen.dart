import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';
import '../services/appointment_service.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
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
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _appointments.where((a) => a.isUpcoming).toList();
    final past = _appointments.where((a) => !a.isUpcoming).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Termine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Neuer Termin',
            onPressed: () => context.push('/doctors'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _appointments.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('Keine Termine vorhanden')),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (upcoming.isNotEmpty) ...[
                        const Text(
                          'Bevorstehend',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...upcoming.map(_buildTile),
                        const SizedBox(height: 24),
                      ],
                      if (past.isNotEmpty) ...[
                        const Text(
                          'Vergangen',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...past.map(_buildTile),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _buildTile(Appointment appointment) {
    final formatted =
        DateFormat('dd.MM.yyyy HH:mm').format(appointment.appointmentTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: appointment.isOnline
              ? Colors.blue.withValues(alpha: 0.1)
              : Colors.green.withValues(alpha: 0.1),
          child: Icon(
            appointment.isOnline ? Icons.video_call : Icons.person,
            color: appointment.isOnline ? Colors.blue : Colors.green,
          ),
        ),
        title: Text(appointment.doctorName),
        subtitle: Text('$formatted • ${appointment.status}'),
        trailing: appointment.canJoin
            ? const Icon(Icons.play_circle_fill, color: Colors.green)
            : const Icon(Icons.chevron_right),
        onTap: () => context.push('/appointments/${appointment.id}'),
      ),
    );
  }
}
