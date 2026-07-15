import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';
import '../services/doctor_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/web/adaptive_screen.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialization;

  final String? testTypeId;
  final String? testTypeName;

  const AppointmentBookingScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    this.testTypeId,
    this.testTypeName,
  });

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  List<AvailabilitySlot> _availableSlots = [];
  bool _isLoading = true;
  bool _isBooking = false;
  AvailabilitySlot? _selectedSlot;
  final TextEditingController _notesController = TextEditingController();
  final String _appointmentType = 'online';

  @override
  void initState() {
    super.initState();
    _loadAvailableSlots();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableSlots() async {
    setState(() => _isLoading = true);

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final doctorService = DoctorService(api);
      final slots = await doctorService.getAvailableSlots(widget.doctorId);

      if (mounted) {
        setState(() {
          _availableSlots = slots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Termine: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wählen Sie einen Termin aus'),
          backgroundColor: AppTheme.accentCoral,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final doctorService = DoctorService(api);

      final result = await doctorService.bookAppointment(
        doctorId: widget.doctorId,
        appointmentTime: _selectedSlot!.dateTime,
        type: _appointmentType,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        testTypeId: widget.testTypeId,
      );

      if (!mounted) return;
      setState(() => _isBooking = false);

      if (result.success) {
        final appointmentId = result.appointmentId;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: AppTheme.surface,
            title: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppTheme.successColor),
                const SizedBox(width: 10),
                Text(
                  'Termin gebucht',
                  style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ihr Termin wurde erfolgreich gebucht.',
                  style: FigmaUi.bodyLight(fontSize: 17, color: AppTheme.textColorSecondary),
                ),
                const SizedBox(height: 16),
                _dialogDetailRow('Arzt', widget.doctorName),
                const SizedBox(height: 8),
                _dialogDetailRow(
                  'Datum',
                  DateFormat('dd.MM.yyyy HH:mm').format(_selectedSlot!.dateTime),
                ),
                const SizedBox(height: 8),
                _dialogDetailRow('Typ', 'Online-Beratung'),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, AppTheme.largeTouchTarget),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  if (appointmentId != null) {
                    context.go('/appointments/$appointmentId');
                  } else {
                    context.go('/appointments');
                  }
                },
                child: Text(
                  'OK',
                  style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Buchen des Termins'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Widget _dialogDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: FigmaUi.bodyLight(fontSize: 17, color: AppTheme.textColorSecondary),
        children: [
          TextSpan(
            text: '$label: ',
            style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w500, color: AppTheme.textColor),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = kIsWeb ? 32.0 : AppTheme.screenHorizontalPadding;

    return AdaptiveScreen(
      title: 'Termin buchen',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/doctors');
        }
      },
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontalPadding, kIsWeb ? 8 : 0, horizontalPadding, 32),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.testTypeName?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: FigmaInsetInfoCard(
                      icon: Icons.medical_services_outlined,
                      title: 'Termin nach ${widget.testTypeName}',
                    ),
                  ),
                NeumorphicRaisedCard(
                  height: null,
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.person_outline, size: 30, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.doctorName,
                              style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.specialization,
                              style: FigmaUi.bodyLight(fontSize: 17, color: AppTheme.textColorSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Beratungstyp',
                  style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor),
                ),
                const SizedBox(height: 12),
                NeumorphicRaisedCard(
                  height: null,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.videocam_outlined, color: AppTheme.primaryBlue, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Online-Beratung',
                              style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                            ),
                            Text(
                              'Videoanruf über HomeDX',
                              style: FigmaUi.bodyLight(fontSize: 15, color: AppTheme.textColorSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 26),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Verfügbare Termine',
                  style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor),
                ),
                const SizedBox(height: 12),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_availableSlots.isEmpty)
                  NeumorphicRaisedCard(
                    height: null,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.event_busy_outlined, color: AppTheme.primaryBlue, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Keine verfügbaren Termine',
                          textAlign: TextAlign.center,
                          style: FigmaUi.rubik(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bitte versuchen Sie es später erneut.',
                          textAlign: TextAlign.center,
                          style: FigmaUi.bodyLight(fontSize: 17, color: AppTheme.textColorSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  _buildTimeSlots(),
                const SizedBox(height: 28),
                Text(
                  'Notizen (optional)',
                  style: FigmaUi.rubik(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textColor),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: FigmaUi.rubik(fontSize: 17, color: AppTheme.textColor),
                  decoration: InputDecoration(
                    hintText: 'Zusätzliche Informationen für den Arzt…',
                    hintStyle: FigmaUi.bodyLight(fontSize: 17, color: AppTheme.textColorSecondary),
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.navy.withValues(alpha: 0.12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(18),
                  ),
                ),
                const SizedBox(height: 32),
                NeumorphicPillButton(
                  label: _isBooking ? 'Wird gebucht…' : 'Termin buchen',
                  leadingIcon: Icons.calendar_today_outlined,
                  height: AppTheme.buttonHeightLarge,
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  loading: _isBooking,
                  onPressed: _isBooking || _selectedSlot == null ? null : _bookAppointment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    final groupedSlots = <String, List<AvailabilitySlot>>{};
    for (final slot in _availableSlots) {
      final dateKey = DateFormat('yyyy-MM-dd').format(slot.dateTime);
      groupedSlots.putIfAbsent(dateKey, () => []).add(slot);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: groupedSlots.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        final slots = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, dd.MM.yyyy', 'de_DE').format(date),
                style: FigmaUi.rubik(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textColor),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  children: slots.map((slot) {
                    final isSelected = _selectedSlot?.id == slot.id;
                    return _TimeSlotChip(
                      label: DateFormat('HH:mm').format(slot.dateTime),
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedSlot = isSelected ? null : slot;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TimeSlotChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBlue : AppTheme.background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected ? null : AppTheme.neumorphicRaised,
          ),
          child: Text(
            label,
            style: FigmaUi.rubik(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppTheme.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
