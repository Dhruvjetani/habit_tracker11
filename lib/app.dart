import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import ' providers/app_provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/add_habit_screen.dart';
import 'screens/edit_habit_screen.dart';
import 'screens/habit_detail_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/statistics_screen.dart';

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: AppTheme.lightTheme(seedColor: appProvider.seedColor),
      darkTheme: AppTheme.darkTheme(seedColor: appProvider.seedColor),
      themeMode: appProvider.themeMode,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        AddHabitScreen.routeName: (_) => const AddHabitScreen(),
        EditHabitScreen.routeName: (_) => const EditHabitScreen(),
        HabitDetailScreen.routeName: (_) => const HabitDetailScreen(),
        HistoryScreen.routeName: (_) => const HistoryScreen(),
        StatisticsScreen.routeName: (_) => const StatisticsScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
    );
  }
}