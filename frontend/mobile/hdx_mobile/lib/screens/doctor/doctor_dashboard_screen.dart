import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/doctor.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/appointment_service.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/web/adaptive_screen.dart';

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
    if (mounted) context.go('/login/doctor');
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Dashboard',
      showBackOnMobile: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.schedule),
          tooltip: 'Verfügbarkeit',
          onPressed: () => context.push('/doctor/availability'),
        ),
        if (!kIsWeb)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
      ],
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  Text(
                    'Heutige Termine',
                    style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                  ),
                  const SizedBox(height: 12),
                  if (_appointments.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Keine Termine für heute', style: FigmaUi.rubik(color: AppTheme.textColorSecondary)),
                      ),
                    )
                  else if (kIsWeb)
                    _buildWebTable()
                  else
                    ..._appointments.map(_buildMobileTile),
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

  Widget _buildWebTable() {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.navy.withValues(alpha: 0.08)),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Zeit')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Aktion')),
        ],
        rows: _appointments.map((a) {
          final time = DateFormat('HH:mm').format(a.appointmentTime);
          return DataRow(
            onSelectChanged: (_) => context.push('/doctor/appointments/${a.id}'),
            cells: [
              DataCell(Text(a.patientName ?? 'Patient')),
              DataCell(Text(time)),
              DataCell(Text(a.statusLabelDe)),
              DataCell(
                a.canJoin
                    ? IconButton(
                        icon: const Icon(Icons.video_call, color: Colors.green),
                        onPressed: () => context.push('/doctor/appointments/${a.id}/call'),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileTile(Appointment a) {
    final time = DateFormat('HH:mm').format(a.appointmentTime);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(a.patientName ?? 'Patient'),
        subtitle: Text('$time • ${a.statusLabelDe}'),
        trailing: a.canJoin
            ? IconButton(
                icon: const Icon(Icons.video_call, color: Colors.green),
                onPressed: () => context.push('/doctor/appointments/${a.id}/call'),
              )
            : null,
        onTap: () => context.push('/doctor/appointments/${a.id}'),
      ),
    );
  }
}
