import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ providers/app_provider.dart';
import '../ providers/habit_provider.dart';
import '../ widgets/empty_state_widget.dart';
import '../ widgets/habit_card.dart';
import '../ widgets/progress_overview_card.dart';
import '../ widgets/section_header.dart';
import '../data/ models/habit_model.dart';
import 'add_habit_screen.dart';
import 'edit_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DashboardTab(),
      const HistoryScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AddHabitScreen.routeName);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Habit'),
      )
          : null,
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final theme = Theme.of(context);

    if (habitProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final today = DateTime.now();
    final todayHabits = habitProvider.getTodayHabits();
    final allHabits = habitProvider.activeHabits;

    final total = habitProvider.getTotalHabitsForDate(today);
    final completed = habitProvider.getCompletedCountForDate(today);
    final pending = habitProvider.getPendingCountForDate(today);
    final progress = habitProvider.getDailyProgress(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await habitProvider.initialize();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _GreetingBanner(userName: appProvider.userName),
            const SizedBox(height: 18),
            ProgressOverviewCard(
              title: 'Today\'s Progress',
              total: total,
              completed: completed,
              pending: pending,
              progress: progress,
            ),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'Today\'s Habits',
              actionText: 'See History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            if (todayHabits.isEmpty)
              const EmptyStateWidget(
                icon: Icons.checklist_rounded,
                title: 'No habits for today',
                subtitle: 'Add a new habit and start building consistency.',
              )
            else
              ...todayHabits.map(
                    (habit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HabitCard(
                    habit: habit,
                    isCompleted: habitProvider.isHabitCompletedOnDate(
                      habit.id,
                      today,
                    ),
                    onToggleComplete: () {
                      habitProvider.toggleHabitCompletion(habit.id, today);
                    },
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        HabitDetailScreen.routeName,
                        arguments: habit.id,
                      );
                    },
                    onEdit: () {
                      Navigator.pushNamed(
                        context,
                        EditHabitScreen.routeName,
                        arguments: habit.id,
                      );
                    },
                    onDelete: () {
                      _showDeleteDialog(context, habitProvider, habit);
                    },
                  ),
                ),
              ),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'All Habits',
              actionText: allHabits.isNotEmpty ? 'View Stats' : null,
              onTap: allHabits.isNotEmpty
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StatisticsScreen(),
                  ),
                );
              }
                  : null,
            ),
            const SizedBox(height: 12),
            if (allHabits.isEmpty)
              const EmptyStateWidget(
                icon: Icons.auto_graph_rounded,
                title: 'No habits created yet',
                subtitle: 'Tap the Add Habit button to create your first habit.',
              )
            else
              ...allHabits.map(
                    (habit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HabitCard(
                    habit: habit,
                    isCompleted: habitProvider.isHabitCompletedOnDate(
                      habit.id,
                      today,
                    ),
                    onToggleComplete: () {
                      habitProvider.toggleHabitCompletion(habit.id, today);
                    },
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        HabitDetailScreen.routeName,
                        arguments: habit.id,
                      );
                    },
                    onEdit: () {
                      Navigator.pushNamed(
                        context,
                        EditHabitScreen.routeName,
                        arguments: habit.id,
                      );
                    },
                    onDelete: () {
                      _showDeleteDialog(context, habitProvider, habit);
                    },
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.emoji_events_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Longest streak across habits: ${habitProvider.getLongestStreakAcrossHabits()} days',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _GreetingBanner extends StatelessWidget {
  final String userName;

  const _GreetingBanner({
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $userName 👋',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay consistent today. Small actions build big results.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}