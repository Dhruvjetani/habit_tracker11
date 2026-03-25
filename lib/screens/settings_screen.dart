import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ providers/app_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/time_helper.dart';
import '../providers/app_provider.dart';
import '../data/services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  Future<void> _editName(BuildContext context) async {
    final appProvider = context.read<AppProvider>();
    final controller = TextEditingController(text: appProvider.userName);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isEmpty) return;
              await appProvider.updateUserName(value);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeReminderTime(BuildContext context) async {
    final appProvider = context.read<AppProvider>();
    final initial = TimeHelper.storageToTimeOfDay(
      appProvider.userProfile?.globalReminderTime,
    ) ??
        const TimeOfDay(hour: 8, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      await appProvider.updateGlobalReminderTime(
        TimeHelper.timeOfDayToStorage(picked),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    final selectedTheme = appProvider.themeMode;
    final reminderText = TimeHelper.storageToTimeOfDay(
      appProvider.userProfile?.globalReminderTime,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  appProvider.userName.isNotEmpty
                      ? appProvider.userName[0].toUpperCase()
                      : 'U',
                ),
              ),
              title: Text(appProvider.userName),
              subtitle: const Text('Your profile name'),
              trailing: IconButton(
                onPressed: () => _editName(context),
                icon: const Icon(Icons.edit_rounded),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Mode',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('System'),
                        selected: selectedTheme == ThemeMode.system,
                        onSelected: (_) {
                          appProvider.updateThemeMode('system');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Light'),
                        selected: selectedTheme == ThemeMode.light,
                        onSelected: (_) {
                          appProvider.updateThemeMode('light');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Dark'),
                        selected: selectedTheme == ThemeMode.dark,
                        onSelected: (_) {
                          appProvider.updateThemeMode('dark');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accent Color',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: AppConstants.selectableColors.map((color) {
                      final selected = appProvider.seedColor.value == color.value;

                      return InkWell(
                        onTap: () => appProvider.updateSeedColor(color.value),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? theme.colorScheme.onSurface
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: selected
                              ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.alarm_rounded),
              title: const Text('Daily Reminder Time'),
              subtitle: Text(
                reminderText == null
                    ? 'Not set'
                    : reminderText.format(context),
              ),
              trailing: IconButton(
                onPressed: () => _changeReminderTime(context),
                icon: const Icon(Icons.edit_rounded),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Test Notification'),
              subtitle: const Text('Check if local notifications are working'),
              trailing: FilledButton(
                onPressed: () async {
                  final notificationService = NotificationService();
                  await notificationService.init();
                  await notificationService.showInstantTestNotification(
                    title: 'Habit Tracker',
                    body: 'Notifications are working correctly.',
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test notification sent'),
                      ),
                    );
                  }
                },
                child: const Text('Test'),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About App',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Habit Tracker helps you build routines, maintain streaks, track your daily progress, and stay consistent using simple local storage with SharedPreferences.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}