import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/doctor.dart';
import '../../providers/auth_provider.dart';
import '../../core/api_service.dart';
import '../../services/appointment_service.dart';
import '../../services/user_service.dart';
import '../../utils/app_assets.dart';
import '../../widgets/doctor_appointment_card.dart';
import '../../widgets/figma_ui.dart';
import '../../widgets/web/adaptive_screen.dart';
import '../../widgets/web/web_page_header.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _lastName;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadDoctorName();
  }

  Future<void> _loadDoctorName() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final userData = await UserService(api).getUserData();
      if (!mounted) return;
      final fullName = '${userData.firstName} ${userData.lastName}'.trim();
      if (fullName.isNotEmpty) {
        context.read<AuthProvider>().setDisplayName(fullName);
      }
      if (userData.lastName.trim().isNotEmpty) {
        setState(() => _lastName = userData.lastName.trim());
      }
    } catch (_) {
      // Greeting falls back to the email prefix below.
    }
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final displayName = _lastName != null
        ? 'Dr. $_lastName'
        : (auth.userEmail?.split('@').first ?? 'Arzt');

    return AdaptiveScreen(
      title: 'Dashboard',
      showWebHeader: false,
      showBackOnMobile: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.schedule_outlined),
          tooltip: 'Verfügbarkeit',
          onPressed: () => context.push('/doctor/availability'),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (kIsWeb)
            WebPageHeader(
              title: 'Willkommen, $displayName',
              subtitle: 'Übersicht Ihrer heutigen Termine und Video-Konsultationen.',
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAppointments,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                        kIsWeb ? 0 : 8,
                        kIsWeb ? 32 : AppTheme.screenHorizontalPadding,
                        24,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (!kIsWeb) ...[
                          FigmaWelcomeCard(
                            name: displayName,
                            email: auth.userEmail ?? '',
                            onTap: () => context.push('/profile'),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Row(
                          children: [
                            const FigmaSectionTitle('Heutige Termine'),
                            if (!_isLoading && _appointments.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_appointments.length}',
                                  style: FigmaUi.rubik(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_appointments.isEmpty)
                          NeumorphicRaisedCard(
                            height: null,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                            onTap: () => context.push('/doctor/appointments'),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AppAssets.doctorRelaxed,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Keine Termine für heute',
                                  textAlign: TextAlign.center,
                                  style: FigmaUi.rubik(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sobald Patienten buchen, erscheinen Ihre heutigen Termine hier.',
                                  textAlign: TextAlign.center,
                                  style: FigmaUi.bodyLight(
                                    fontSize: 14,
                                    color: AppTheme.textColorSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ..._appointments.map(
                            (a) => Padding(
                              padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
                              child: DoctorAppointmentCard(
                                appointment: a,
                                onTap: () => context.push('/doctor/appointments/${a.id}'),
                                onJoinCall: a.canJoin
                                    ? () => context.push('/doctor/appointments/${a.id}/call')
                                    : null,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        const FigmaSectionTitle('RheumaCheck Fragebögen'),
                        const SizedBox(height: 12),
                        NeumorphicRaisedCard(
                          height: null,
                          padding: const EdgeInsets.all(18),
                          onTap: () => context.push('/doctor/questionnaires/B'),
                          child: Row(
                            children: [
                              const Icon(Icons.assignment_outlined, color: AppTheme.primaryBlue),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Bogen B', style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w500)),
                                    Text(
                                      'Standardmethode & Versorgungspfad',
                                      style: FigmaUi.bodyLight(fontSize: 13, color: AppTheme.textColorSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppTheme.textColorSecondary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        NeumorphicRaisedCard(
                          height: null,
                          padding: const EdgeInsets.all(18),
                          onTap: () => context.push('/doctor/questionnaires/D'),
                          child: Row(
                            children: [
                              const Icon(Icons.medical_information_outlined, color: AppTheme.primaryBlue),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Bogen D', style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w500)),
                                    Text(
                                      'Implementierbarkeit & Nutzen',
                                      style: FigmaUi.bodyLight(fontSize: 13, color: AppTheme.textColorSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppTheme.textColorSecondary),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
