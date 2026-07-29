import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/doctor.dart';
import '../appointment_status_badge.dart';
import '../doctor_appointment_card.dart';
import '../figma_ui.dart';

enum CalendarMode { week, month }

const _monthNames = [
  'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
  'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
];
const _weekdayShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _startOfWeek(DateTime d) =>
    _dateOnly(d).subtract(Duration(days: d.weekday - 1));

/// Google-Calendar-style week/month view for a doctor's appointments.
/// Weekdays only (Mon–Fri) in week mode, since the practice doesn't book
/// weekend slots; month mode shows the full calendar grid.
class DoctorAppointmentCalendar extends StatefulWidget {
  final List<Appointment> appointments;
  final ValueChanged<Appointment> onTapAppointment;

  const DoctorAppointmentCalendar({
    super.key,
    required this.appointments,
    required this.onTapAppointment,
  });

  @override
  State<DoctorAppointmentCalendar> createState() => _DoctorAppointmentCalendarState();
}

class _DoctorAppointmentCalendarState extends State<DoctorAppointmentCalendar> {
  CalendarMode _mode = CalendarMode.week;
  late DateTime _focusedDate;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _focusedDate = today;
    _selectedDay = today;
  }

  List<Appointment> _appointmentsOn(DateTime day) {
    final list = widget.appointments.where((a) => _isSameDay(a.appointmentTime, day)).toList();
    list.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
    return list;
  }

  void _goPrev() => setState(() {
        _focusedDate = _mode == CalendarMode.week
            ? _focusedDate.subtract(const Duration(days: 7))
            : DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
      });

  void _goNext() => setState(() {
        _focusedDate = _mode == CalendarMode.week
            ? _focusedDate.add(const Duration(days: 7))
            : DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
      });

  void _goToday() => setState(() {
        final today = _dateOnly(DateTime.now());
        _focusedDate = today;
        _selectedDay = today;
      });

  String get _rangeLabel {
    if (_mode == CalendarMode.week) {
      final start = _startOfWeek(_focusedDate);
      final end = start.add(const Duration(days: 4));
      if (start.month == end.month) {
        return '${start.day}.–${end.day}. ${_monthNames[end.month - 1]} ${end.year}';
      }
      return '${start.day}. ${_monthNames[start.month - 1]} – ${end.day}. ${_monthNames[end.month - 1]} ${end.year}';
    }
    return '${_monthNames[_focusedDate.month - 1]} ${_focusedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(),
        const SizedBox(height: 16),
        if (_mode == CalendarMode.week)
          _WeekView(
            weekStart: _startOfWeek(_focusedDate),
            appointmentsOn: _appointmentsOn,
            onTapAppointment: widget.onTapAppointment,
          )
        else
          _MonthView(
            month: _focusedDate,
            selectedDay: _selectedDay,
            appointmentsOn: _appointmentsOn,
            onSelectDay: (day) => setState(() => _selectedDay = day),
          ),
        if (_mode == CalendarMode.month) ...[
          const SizedBox(height: 20),
          _SelectedDayList(
            day: _selectedDay,
            appointments: _appointmentsOn(_selectedDay),
            onTapAppointment: widget.onTapAppointment,
          ),
        ],
      ],
    );
  }

  Widget _buildToolbar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 640;
        final modeToggle = SizedBox(
          width: 180,
          child: FigmaSegmentedTabs(
            labels: const ['Woche', 'Monat'],
            selectedIndex: _mode.index,
            selectedColor: AppTheme.accentBlue,
            onSelected: (i) => setState(() => _mode = CalendarMode.values[i]),
          ),
        );
        final nav = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavIconButton(icon: Icons.chevron_left, onTap: _goPrev),
            const SizedBox(width: 4),
            _HeuteButton(onTap: _goToday),
            const SizedBox(width: 4),
            _NavIconButton(icon: Icons.chevron_right, onTap: _goNext),
            const SizedBox(width: 12),
            Text(
              _rangeLabel,
              style: FigmaUi.rubik(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textColor),
            ),
          ],
        );

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [modeToggle, const SizedBox(height: 12), nav],
          );
        }
        return Row(
          children: [modeToggle, const Spacer(), nav],
        );
      },
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: AppTheme.textColor),
        ),
      ),
    );
  }
}

/// Compact calendar toolbar control — avoids [NeumorphicPillButton]'s 18px label
/// which wraps when forced into the 36px nav row height.
class _HeuteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _HeuteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        onTap: onTap,
        child: SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                'Heute',
                maxLines: 1,
                softWrap: false,
                style: FigmaUi.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textColor,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LaidOutEvent {
  final Appointment appointment;
  final int column;
  final int totalColumns;

  const _LaidOutEvent({required this.appointment, required this.column, required this.totalColumns});
}

List<_LaidOutEvent> _layoutDay(List<Appointment> dayAppointments) {
  final sorted = [...dayAppointments]..sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
  final columnEnds = <DateTime>[];
  final assigned = <Appointment, int>{};

  for (final apt in sorted) {
    final start = apt.appointmentTime;
    final end = start.add(Duration(minutes: apt.durationMin));
    var col = columnEnds.indexWhere((endTime) => !endTime.isAfter(start));
    if (col == -1) {
      col = columnEnds.length;
      columnEnds.add(end);
    } else {
      columnEnds[col] = end;
    }
    assigned[apt] = col;
  }

  final totalColumns = columnEnds.isEmpty ? 1 : columnEnds.length;
  return sorted
      .map((apt) => _LaidOutEvent(appointment: apt, column: assigned[apt]!, totalColumns: totalColumns))
      .toList();
}

class _WeekView extends StatelessWidget {
  final DateTime weekStart;
  final List<Appointment> Function(DateTime day) appointmentsOn;
  final ValueChanged<Appointment> onTapAppointment;

  const _WeekView({
    required this.weekStart,
    required this.appointmentsOn,
    required this.onTapAppointment,
  });

  static const double _rowHeight = 60;
  static const double _gutterWidth = 52;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(5, (i) => weekStart.add(Duration(days: i)));
    final dayAppointments = {for (final d in days) d: appointmentsOn(d)};
    final today = _dateOnly(DateTime.now());

    var startHour = 8;
    var endHour = 18;
    for (final list in dayAppointments.values) {
      for (final a in list) {
        if (a.appointmentTime.hour < startHour) startHour = a.appointmentTime.hour;
        final end = a.appointmentTime.add(Duration(minutes: a.durationMin));
        final endHourCandidate = end.minute > 0 ? end.hour + 1 : end.hour;
        if (endHourCandidate > endHour) endHour = endHourCandidate;
      }
    }
    startHour = startHour.clamp(0, 22);
    endHour = endHour.clamp(startHour + 1, 24);
    final hours = List.generate(endHour - startHour, (i) => startHour + i);
    final gridHeight = hours.length * _rowHeight;

    final nowOffset = () {
      final now = DateTime.now();
      if (now.hour < startHour || now.hour >= endHour) return null;
      return (now.hour - startHour) * _rowHeight + (now.minute / 60) * _rowHeight;
    }();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.activityCardRadius),
        boxShadow: AppTheme.neumorphicRaised,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SizedBox(width: _gutterWidth),
              ...days.map((d) => Expanded(child: _WeekDayHeader(day: d, isToday: _isSameDay(d, today)))),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: gridHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _gutterWidth,
                  child: Column(
                    children: hours
                        .map((h) => SizedBox(
                              height: _rowHeight,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8, top: 2),
                                  child: Text(
                                    '${h.toString().padLeft(2, '0')}:00',
                                    style: FigmaUi.rubik(fontSize: 11, fontWeight: FontWeight.w400, color: AppTheme.textColorSecondary),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                ...days.map((d) => Expanded(
                      child: _DayColumn(
                        day: d,
                        isToday: _isSameDay(d, today),
                        hours: hours,
                        rowHeight: _rowHeight,
                        startHour: startHour,
                        events: _layoutDay(dayAppointments[d]!),
                        nowOffset: _isSameDay(d, today) ? nowOffset : null,
                        onTapAppointment: onTapAppointment,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDayHeader extends StatelessWidget {
  final DateTime day;
  final bool isToday;

  const _WeekDayHeader({required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _weekdayShort[day.weekday - 1],
          style: FigmaUi.rubik(fontSize: 12, fontWeight: FontWeight.w400, color: AppTheme.textColorSecondary),
        ),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isToday ? AppTheme.accentBlue : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${day.day}',
            style: FigmaUi.rubik(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isToday ? Colors.white : AppTheme.textColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final List<int> hours;
  final double rowHeight;
  final int startHour;
  final List<_LaidOutEvent> events;
  final double? nowOffset;
  final ValueChanged<Appointment> onTapAppointment;

  const _DayColumn({
    required this.day,
    required this.isToday,
    required this.hours,
    required this.rowHeight,
    required this.startHour,
    required this.events,
    required this.nowOffset,
    required this.onTapAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final divider = AppTheme.navy.withValues(alpha: 0.07);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isToday ? AppTheme.primaryLight.withValues(alpha: 0.35) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          Column(
            children: hours
                .map((h) => Container(
                      height: rowHeight,
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: divider))),
                    ))
                .toList(),
          ),
          if (nowOffset != null)
            Positioned(
              top: nowOffset,
              left: 0,
              right: 0,
              child: Container(height: 2, color: AppTheme.accentCoral),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: events.map((e) {
                  final start = e.appointment.appointmentTime;
                  final top = (start.hour - startHour) * rowHeight + (start.minute / 60) * rowHeight;
                  final height = (e.appointment.durationMin / 60) * rowHeight;
                  final colWidth = constraints.maxWidth / e.totalColumns;
                  return Positioned(
                    top: top,
                    left: e.column * colWidth,
                    width: colWidth - 3,
                    height: height.clamp(24, double.infinity),
                    child: _EventBlock(appointment: e.appointment, onTap: () => onTapAppointment(e.appointment)),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EventBlock extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const _EventBlock({required this.appointment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = appointmentStatusColors(appointment.status);
    final time = appointment.appointmentTime;
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$timeStr ${appointment.patientName ?? 'Patient'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FigmaUi.rubik(fontSize: 11, fontWeight: FontWeight.w500, color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDay;
  final List<Appointment> Function(DateTime day) appointmentsOn;
  final ValueChanged<DateTime> onSelectDay;

  const _MonthView({
    required this.month,
    required this.selectedDay,
    required this.appointmentsOn,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final gridStart = _startOfWeek(firstOfMonth);
    final today = _dateOnly(DateTime.now());
    final totalCells = 42; // 6 weeks, always enough to cover any month
    final days = List.generate(totalCells, (i) => gridStart.add(Duration(days: i)));

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.activityCardRadius),
        boxShadow: AppTheme.neumorphicRaised,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: _weekdayShort
                .map((label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: FigmaUi.rubik(fontSize: 12, fontWeight: FontWeight.w400, color: AppTheme.textColorSecondary),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final inMonth = day.month == month.month;
              final dayAppointments = appointmentsOn(day);
              return _MonthCell(
                day: day,
                inMonth: inMonth,
                isToday: _isSameDay(day, today),
                isSelected: _isSameDay(day, selectedDay),
                appointments: dayAppointments,
                onTap: () => onSelectDay(day),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonthCell extends StatelessWidget {
  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final List<Appointment> appointments;
  final VoidCallback onTap;

  const _MonthCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.appointments,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleChips = appointments.take(2).toList();
    final overflow = appointments.length - visibleChips.length;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: isSelected ? AppTheme.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: AppTheme.accentBlue, width: 1.4) : null,
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.accentBlue : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${day.day}',
                    style: FigmaUi.rubik(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isToday
                          ? Colors.white
                          : inMonth
                              ? AppTheme.textColor
                              : AppTheme.textColorSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                ...visibleChips.map((a) {
                  final (background, foreground) = appointmentStatusColors(a.status);
                  final time = a.appointmentTime;
                  final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      timeStr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FigmaUi.rubik(fontSize: 9, fontWeight: FontWeight.w500, color: foreground),
                    ),
                  );
                }),
                if (overflow > 0)
                  Text(
                    '+$overflow mehr',
                    style: FigmaUi.rubik(fontSize: 9, fontWeight: FontWeight.w400, color: AppTheme.textColorSecondary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedDayList extends StatelessWidget {
  final DateTime day;
  final List<Appointment> appointments;
  final ValueChanged<Appointment> onTapAppointment;

  const _SelectedDayList({
    required this.day,
    required this.appointments,
    required this.onTapAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final label = '${_weekdayLong(day.weekday)}, ${day.day}. ${_monthNames[day.month - 1]} ${day.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FigmaSectionTitle(label),
        const SizedBox(height: 12),
        if (appointments.isEmpty)
          FigmaListCard(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.event_available_outlined, color: AppTheme.primaryBlue),
            ),
            title: 'Keine Termine an diesem Tag',
            subtitle: 'Wählen Sie einen anderen Tag im Kalender.',
          )
        else
          ...appointments.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.testResultCardSpacing),
                child: DoctorAppointmentCard(
                  appointment: a,
                  onTap: () => onTapAppointment(a),
                ),
              )),
      ],
    );
  }

  static String _weekdayLong(int weekday) {
    const names = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];
    return names[weekday - 1];
  }
}
