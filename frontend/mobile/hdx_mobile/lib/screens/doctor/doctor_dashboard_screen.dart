import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/doctor.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/appointment_service.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
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
      final now = DateTime.now();
      final today = appointments
          .where((a) =>
              a.isUpcoming &&
              a.appointmentTime.year == now.year &&
              a.appointmentTime.month == now.month &&
              a.appointmentTime.day == now.day)
          .toList();
      if (mounted) {
        setState(() {
          _appointments = today;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arzt-Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            tooltip: 'Verfügbarkeit',
            onPressed: () => context.push('/doctor/availability'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Heutige Termine',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_appointments.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Keine Termine für heute'),
                      ),
                    )
                  else
                    ..._appointments.map((a) {
                      final time =
                          DateFormat('HH:mm').format(a.appointmentTime);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(a.patientName ?? 'Patient'),
                          subtitle: Text('$time • ${a.status}'),
                          trailing: a.canJoin
                              ? IconButton(
                                  icon: const Icon(Icons.video_call,
                                      color: Colors.green),
                                  onPressed: () => context.push(
                                      '/doctor/appointments/${a.id}/call'),
                                )
                              : null,
                          onTap: () =>
                              context.push('/doctor/appointments/${a.id}'),
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.push('/doctor/appointments'),
                    child: const Text('Alle Termine anzeigen'),
                  ),
                ],
              ),
      ),
    );
  }
}
