import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ providers/habit_provider.dart';
import '../core/utils/color_helper.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/icon_helper.dart';
import '../data/ models/habit_model.dart';
import '../data/models/habit_model.dart';
import '../providers/habit_provider.dart';
import 'edit_habit_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  static const String routeName = '/habit-detail';

  const HabitDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitId = ModalRoute.of(context)?.settings.arguments as String?;
    final habitProvider = context.watch<HabitProvider>();

    if (habitId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Habit not found'),
        ),
      );
    }

    final habit = habitProvider.getHabitById(habitId);

    if (habit == null) {
      return const Scaffold(
        body: Center(
          child: Text('Habit not found'),
        ),
      );
    }

    final today = DateTime.now();
    final isCompletedToday = habitProvider.isHabitCompletedOnDate(habit.id, today);
    final completedDates = habitProvider
        .completions
        .where((c) => c.habitId == habit.id && c.completed)
        .map((c) => DateTime.parse(c.dateKey))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final habitColor = ColorHelper.colorFromValue(habit.colorValue);
    final habitIcon = IconHelper.iconFromCodePoint(habit.iconCodePoint);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () {
              Navigator.pushNamed(
                context,
                EditHabitScreen.routeName,
                arguments: habit.id,
              );
            },
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () => _showDeleteDialog(context, habitProvider, habit),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: habitColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      habitIcon,
                      size: 34,
                      color: habitColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          habit.description.trim().isEmpty
                              ? 'No description added'
                              : habit.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _DetailChip(
                              icon: Icons.category_outlined,
                              label: habit.category,
                            ),
                            _DetailChip(
                              icon: Icons.flag_outlined,
                              label: '${habit.targetValue} ${habit.targetUnit}',
                            ),
                            _DetailChip(
                              icon: Icons.repeat_rounded,
                              label: _frequencyLabel(habit),
                            ),
                            if (habit.reminderTime != null &&
                                habit.reminderTime!.isNotEmpty)
                              _DetailChip(
                                icon: Icons.alarm_rounded,
                                label: habit.reminderTime!,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  title: 'Current Streak',
                  value: '${habit.currentStreak}',
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  title: 'Best Streak',
                  value: '${habit.bestStreak}',
                  icon: Icons.emoji_events_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  title: 'Created',
                  value: AppDateUtils.formatReadableDate(habit.createdAt),
                  icon: Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  title: 'Today',
                  value: isCompletedToday ? 'Completed' : 'Pending',
                  icon: isCompletedToday
                      ? Icons.check_circle_rounded
                      : Icons.pending_actions_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                await habitProvider.toggleHabitCompletion(habit.id, today);
              },
              icon: Icon(
                isCompletedToday ? Icons.undo_rounded : Icons.check_rounded,
              ),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  isCompletedToday
                      ? 'Mark as Pending for Today'
                      : 'Mark Completed for Today',
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Recent Completion History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (completedDates.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'No completion history yet. Complete this habit to start building streaks.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          else
            ...completedDates.take(20).map(
                  (date) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.check_rounded),
                    ),
                    title: Text(AppDateUtils.formatReadableDate(date)),
                    subtitle: Text(
                      AppDateUtils.isSameDate(date, today)
                          ? 'Completed today'
                          : 'Completed successfully',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _frequencyLabel(HabitModel habit) {
    if (habit.frequency == 'Custom') {
      if (habit.customDays.isEmpty) return 'Custom';
      final labels = habit.customDays.map((d) {
        switch (d) {
          case 1:
            return 'Mon';
          case 2:
            return 'Tue';
          case 3:
            return 'Wed';
          case 4:
            return 'Thu';
          case 5:
            return 'Fri';
          case 6:
            return 'Sat';
          case 7:
            return 'Sun';
          default:
            return '';
        }
      }).where((e) => e.isNotEmpty).join(', ');
      return labels;
    }

    return habit.frequency;
  }

  void _showDeleteDialog(
      BuildContext context,
      HabitProvider habitProvider,
      HabitModel habit,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await habitProvider.deleteHabit(habit.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}