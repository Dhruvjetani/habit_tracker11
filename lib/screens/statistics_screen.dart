import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ providers/habit_provider.dart';
import '../ widgets/stat_card.dart';
import '../providers/habit_provider.dart';
import '../widgets/stat_card.dart';

class StatisticsScreen extends StatelessWidget {
  static const String routeName = '/statistics';

  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final weeklySummary = habitProvider.getWeeklySummary();
    final monthlySummary = habitProvider.getMonthlySummary();
    final overallRate = habitProvider.getOverallCompletionRate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              StatCard(
                title: 'Total Habits',
                value: '${habitProvider.activeHabits.length}',
                icon: Icons.track_changes_rounded,
              ),
              StatCard(
                title: 'Total Completions',
                value: '${habitProvider.getTotalCompletions()}',
                icon: Icons.check_circle_rounded,
              ),
              StatCard(
                title: 'Longest Streak',
                value: '${habitProvider.getLongestStreakAcrossHabits()} days',
                icon: Icons.local_fire_department_rounded,
              ),
              StatCard(
                title: 'Completion Rate',
                value: '${(overallRate * 100).toStringAsFixed(1)}%',
                icon: Icons.pie_chart_rounded,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SummarySection(
            title: 'Weekly Summary',
            subtitle: 'Completed habits over the last 7 days',
            values: weeklySummary,
          ),
          const SizedBox(height: 20),
          _SummarySection(
            title: 'Monthly Summary',
            subtitle: 'Completed habits over recent months',
            values: monthlySummary,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Insight',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: overallRate.clamp(0, 1),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _buildInsightText(
                      habitProvider.activeHabits.length,
                      overallRate,
                      habitProvider.getLongestStreakAcrossHabits(),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildInsightText(
      int totalHabits,
      double completionRate,
      int longestStreak,
      ) {
    if (totalHabits == 0) {
      return 'Create your first habit to start tracking statistics and progress insights.';
    }

    if (completionRate >= 0.8) {
      return 'Excellent consistency. You are maintaining strong discipline, and your longest streak is $longestStreak days.';
    }

    if (completionRate >= 0.5) {
      return 'Good progress. You are building momentum well. Keep pushing to improve your daily completion rate.';
    }

    return 'You are getting started. Try focusing on fewer habits first and build consistency step by step.';
  }
}

class _SummarySection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Map<String, int> values;

  const _SummarySection({
    required this.title,
    required this.subtitle,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = values.values.isEmpty
        ? 1
        : values.values.reduce((a, b) => a > b ? a : b).clamp(1, 999999);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            ...values.entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(entry.key)),
                        Text(
                          '${entry.value}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: entry.value / maxValue,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}