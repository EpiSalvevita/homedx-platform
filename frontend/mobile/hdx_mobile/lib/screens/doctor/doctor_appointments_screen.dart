import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/doctor.dart';
import '../../services/api_service.dart';
import '../../services/appointment_service.dart';
import '../../widgets/web/adaptive_screen.dart';

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
    return AdaptiveScreen(
      title: 'Alle Termine',
      showBackOnMobile: false,
      onBack: () => context.go('/doctor/dashboard'),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : kIsWeb
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    children: [
                      Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.navy.withValues(alpha: 0.08)),
                        ),
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Patient')),
                            DataColumn(label: Text('Datum')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: _appointments.map((a) {
                            return DataRow(
                              onSelectChanged: (_) => context.push('/doctor/appointments/${a.id}'),
                              cells: [
                                DataCell(Text(a.patientName ?? 'Patient')),
                                DataCell(Text(DateFormat('dd.MM.yyyy HH:mm').format(a.appointmentTime))),
                                DataCell(Text(a.statusLabelDe)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final a = _appointments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(a.patientName ?? 'Patient'),
                          subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(a.appointmentTime)),
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
