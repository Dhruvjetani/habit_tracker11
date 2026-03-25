import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../ providers/habit_provider.dart';
import '../ widgets/empty_state_widget.dart';
import '../core/utils/date_utils.dart';
import '../providers/habit_provider.dart';
import '../widgets/empty_state_widget.dart';

class HistoryScreen extends StatefulWidget {
  static const String routeName = '/history';

  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final theme = Theme.of(context);

    final completedHabits = habitProvider.getCompletedHabitsOnSelectedDay(_selectedDay);
    final allScheduledHabits = habitProvider.getHabitsForDate(_selectedDay);
    final pendingHabits = habitProvider.getPendingHabitsForDate(_selectedDay);
    final completionDates = habitProvider.getCompletionDatesForCalendar();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) =>
                    AppDateUtils.isSameDate(day, _selectedDay),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = AppDateUtils.dateOnly(selectedDay);
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) {
                  final normalized = AppDateUtils.dateOnly(day);
                  final hasCompletion = completionDates.any(
                        (date) => AppDateUtils.isSameDate(date, normalized),
                  );
                  return hasCompletion ? ['done'] : [];
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppDateUtils.formatReadableDate(_selectedDay),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _HistoryStatBox(
                          title: 'Scheduled',
                          value: '${allScheduledHabits.length}',
                          icon: Icons.event_note_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HistoryStatBox(
                          title: 'Completed',
                          value: '${completedHabits.length}',
                          icon: Icons.check_circle_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HistoryStatBox(
                          title: 'Pending',
                          value: '${pendingHabits.length}',
                          icon: Icons.pending_actions_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Completed Habits',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (completedHabits.isEmpty)
            const EmptyStateWidget(
              icon: Icons.calendar_today_rounded,
              title: 'No completed habits',
              subtitle: 'No habit was marked as completed on this date.',
            )
          else
            ...completedHabits.map(
                  (habit) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(habit.colorValue).withOpacity(0.15),
                      child: Icon(
                        IconData(
                          habit.iconCodePoint,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Color(habit.colorValue),
                      ),
                    ),
                    title: Text(habit.title),
                    subtitle: Text(
                      habit.description.trim().isEmpty
                          ? '${habit.targetValue} ${habit.targetUnit}'
                          : habit.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.check_circle_rounded),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Pending Habits',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (allScheduledHabits.isEmpty)
            const EmptyStateWidget(
              icon: Icons.event_busy_rounded,
              title: 'No scheduled habits',
              subtitle: 'No habits were scheduled for the selected date.',
            )
          else if (pendingHabits.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'Great job! All scheduled habits were completed on this day.',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            )
          else
            ...pendingHabits.map(
                  (habit) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(habit.colorValue).withOpacity(0.15),
                      child: Icon(
                        IconData(
                          habit.iconCodePoint,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Color(habit.colorValue),
                      ),
                    ),
                    title: Text(habit.title),
                    subtitle: Text('${habit.targetValue} ${habit.targetUnit}'),
                    trailing: const Icon(Icons.radio_button_unchecked_rounded),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryStatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _HistoryStatBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}