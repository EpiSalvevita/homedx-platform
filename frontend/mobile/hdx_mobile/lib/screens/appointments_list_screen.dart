import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

    return AdaptiveScreen(
      title: 'Meine Termine',
      showBackOnMobile: false,
      onBack: () => context.go('/home'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Neuer Termin',
          onPressed: () => context.push('/doctors'),
        ),
      ],
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
                : kIsWeb
                    ? _buildWebList(upcoming, past)
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (upcoming.isNotEmpty) ...[
                            const Text('Bevorstehend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...upcoming.map(_buildTile),
                            const SizedBox(height: 24),
                          ],
                          if (past.isNotEmpty) ...[
                            const Text('Vergangen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...past.map(_buildTile),
                          ],
                        ],
                      ),
      ),
    );
  }

  Widget _buildWebList(List<Appointment> upcoming, List<Appointment> past) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        if (upcoming.isNotEmpty) ...[
          Text('Bevorstehend', style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
          const SizedBox(height: 8),
          _buildWebTable(upcoming),
          const SizedBox(height: 24),
        ],
        if (past.isNotEmpty) ...[
          Text('Vergangen', style: FigmaUi.rubik(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textColor)),
          const SizedBox(height: 8),
          _buildWebTable(past),
        ],
      ],
    );
  }

  Widget _buildWebTable(List<Appointment> items) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.navy.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWebTableHeader(),
          ...items.map(_buildWebRow),
        ],
      ),
    );
  }

  Widget _buildWebTableHeader() {
    final headerStyle = FigmaUi.rubik(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppTheme.textColorSecondary,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.navy.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Arzt', style: headerStyle)),
          Expanded(flex: 3, child: Text('Datum', style: headerStyle)),
          Expanded(flex: 2, child: Text('Status', style: headerStyle)),
        ],
      ),
    );
  }

  Widget _buildWebRow(Appointment appointment) {
    final formatted = DateFormat('dd.MM.yyyy HH:mm').format(appointment.appointmentTime);
    final bodyStyle = FigmaUi.rubik(fontSize: 14, fontWeight: FontWeight.w400, color: AppTheme.textColor);

    return InkWell(
      onTap: () => context.push('/appointments/${appointment.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.navy.withValues(alpha: 0.06))),
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(appointment.doctorName, style: bodyStyle)),
            Expanded(flex: 3, child: Text(formatted, style: bodyStyle)),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppointmentStatusBadge(appointment: appointment),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(Appointment appointment) {
    final formatted = DateFormat('dd.MM.yyyy HH:mm').format(appointment.appointmentTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(appointment.doctorName),
        subtitle: Row(
          children: [
            Text(
              formatted,
              style: TextStyle(color: AppTheme.textColorSecondary, fontSize: 13),
            ),
            const SizedBox(width: 10),
            AppointmentStatusBadge(appointment: appointment),
          ],
        ),
        trailing: appointment.canJoin
            ? const Icon(Icons.play_circle_fill, color: Colors.green)
            : const Icon(Icons.chevron_right),
        onTap: () => context.push('/appointments/${appointment.id}'),
      ),
    );
  }
}
