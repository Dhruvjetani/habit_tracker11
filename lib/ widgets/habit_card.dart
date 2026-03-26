import 'package:flutter/material.dart';

import '../core/utils/color_helper.dart';
import '../core/utils/icon_helper.dart';
import '../data/ models/habit_model.dart';


class HabitCard extends StatelessWidget {
  final HabitModel habit;
  final bool isCompleted;
  final VoidCallback onToggleComplete;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggleComplete,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitColor = ColorHelper.colorFromValue(habit.colorValue);
    final habitIcon = IconHelper.iconFromCodePoint(habit.iconCodePoint);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  habitIcon,
                  color: habitColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            habit.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit?.call();
                            } else if (value == 'delete') {
                              onDelete?.call();
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (habit.description.trim().isNotEmpty) ...[
                      Text(
                        habit.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                    ],
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniInfoChip(
                          label: habit.category,
                          icon: Icons.category_outlined,
                        ),
                        _MiniInfoChip(
                          label: '${habit.targetValue} ${habit.targetUnit}',
                          icon: Icons.flag_outlined,
                        ),
                        _MiniInfoChip(
                          label: '${habit.currentStreak} day streak',
                          icon: Icons.local_fire_department_outlined,
                        ),
                        if (habit.reminderTime != null &&
                            habit.reminderTime!.isNotEmpty)
                          _MiniInfoChip(
                            label: habit.reminderTime!,
                            icon: Icons.alarm,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onToggleComplete,
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: isCompleted
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MiniInfoChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}