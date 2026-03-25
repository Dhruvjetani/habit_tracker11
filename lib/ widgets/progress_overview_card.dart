import 'package:flutter/material.dart';

class ProgressOverviewCard extends StatelessWidget {
  final int total;
  final int completed;
  final int pending;
  final double progress;
  final String title;

  const ProgressOverviewCard({
    super.key,
    required this.total,
    required this.completed,
    required this.pending,
    required this.progress,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 14),
            Text(
              '$completed out of $total habits done today',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    label: 'Completed',
                    value: completed.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoChip(
                    label: 'Pending',
                    value: pending.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}