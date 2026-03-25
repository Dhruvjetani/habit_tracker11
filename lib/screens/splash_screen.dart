import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ providers/app_provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final appProvider = context.read<AppProvider>();

    while (!appProvider.isLoaded) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    if (!mounted) return;

    if (appProvider.isOnboardingCompleted) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
              colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: colorScheme.primary,
              child: Icon(
                Icons.track_changes_rounded,
                size: 40,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Habit Tracker',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Build better routines, one day at a time.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}