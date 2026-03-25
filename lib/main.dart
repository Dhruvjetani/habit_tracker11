import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import ' providers/app_provider.dart';
import ' providers/habit_provider.dart';
import 'app.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/notification_service.dart';
import 'providers/app_provider.dart';
import 'providers/habit_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorageService = LocalStorageService();
  await localStorageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider(localStorageService)..loadAppSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitProvider(
            localStorageService: localStorageService,
            notificationService: notificationService,
          )..initialize(),
        ),
      ],
      child: const HabitTrackerApp(),
    ),
  );
}