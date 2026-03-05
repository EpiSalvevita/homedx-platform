import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialization;

  const AppointmentBookingScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
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
  final String _appointmentType = 'online'; // Default to online

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
    setState(() {
      _isLoading = true;
    });

    try {
      final doctorService = DoctorService();
      final slots = await doctorService.getAvailableSlots(widget.doctorId);

      if (mounted) {
        setState(() {
          _availableSlots = slots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Termine: $e'),
            backgroundColor: Colors.red,
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
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final doctorService = DoctorService();

      final success = await doctorService.bookAppointment(
        doctorId: widget.doctorId,
        appointmentTime: _selectedSlot!.dateTime,
        type: _appointmentType,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        setState(() {
          _isBooking = false;
        });

        if (success) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Termin gebucht'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ihr Termin wurde erfolgreich gebucht.'),
                  const SizedBox(height: 16),
                  Text(
                    'Arzt: ${widget.doctorName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Datum: ${DateFormat('dd.MM.yyyy HH:mm').format(_selectedSlot!.dateTime)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Typ: Online-Beratung',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/');
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Buchen des Termins'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termin buchen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Zurück',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.person,
                          size: 35,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.doctorName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.specialization,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Appointment Type
              const Text(
                'Beratungstyp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.video_call, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Online-Beratung'),
                    ],
                  ),
                  subtitle: const Text('Videoanruf'),
                  value: 'online',
                  groupValue: _appointmentType,
                  onChanged: null, // Only online for now
                ),
              ),

              const SizedBox(height: 24),

              // Available Slots
              const Text(
                'Verfügbare Termine',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_availableSlots.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Keine verfügbaren Termine',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bitte versuchen Sie es später erneut',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildTimeSlots(),

              const SizedBox(height: 24),

              // Notes
              const Text(
                'Notizen (optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Fügen Sie hier zusätzliche Informationen hinzu...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Book Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isBooking || _selectedSlot == null
                      ? null
                      : _bookAppointment,
                  icon: _isBooking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.calendar_today),
                  label: Text(_isBooking ? 'Wird gebucht...' : 'Termin buchen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    // Group slots by date
    final Map<String, List<AvailabilitySlot>> groupedSlots = {};
    for (var slot in _availableSlots) {
      final dateKey = DateFormat('yyyy-MM-dd').format(slot.dateTime);
      if (!groupedSlots.containsKey(dateKey)) {
        groupedSlots[dateKey] = [];
      }
      groupedSlots[dateKey]!.add(slot);
    }

    return Column(
      children: groupedSlots.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        final slots = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                DateFormat('EEEE, dd.MM.yyyy', 'de_DE').format(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) {
                final isSelected = _selectedSlot?.id == slot.id;
                return ChoiceChip(
                  label: Text(DateFormat('HH:mm').format(slot.dateTime)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSlot = selected ? slot : null;
                    });
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}

