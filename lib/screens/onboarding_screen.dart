import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ providers/app_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/time_helper.dart';
import '../core/utils/validators.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedThemeMode = 'system';
  int _selectedColorValue = Colors.indigo.value;
  TimeOfDay? _selectedReminderTime;

  @override
  void initState() {
    super.initState();
    _selectedColorValue = AppConstants.selectableColors.first.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? const TimeOfDay(hour: 8, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _selectedReminderTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final reminderString = _selectedReminderTime != null
        ? TimeHelper.timeOfDayToStorage(_selectedReminderTime!)
        : null;

    await context.read<AppProvider>().completeOnboarding(
      name: _nameController.text.trim(),
      themeMode: _selectedThemeMode,
      seedColorValue: _selectedColorValue,
      globalReminderTime: reminderString,
    );

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      HomeScreen.routeName,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = Color(_selectedColorValue);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Welcome to Habit Tracker',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create good routines, stay consistent, and track your daily progress with a clean and simple system.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Let’s get started',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Set up your basic profile and app preferences.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your name',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) =>
                          Validators.requiredField(value, fieldName: 'Name'),
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Choose theme mode',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ThemeModeSelector(
                      selectedValue: _selectedThemeMode,
                      onChanged: (value) {
                        setState(() {
                          _selectedThemeMode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Choose app accent color',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: AppConstants.selectableColors.map((color) {
                        final isSelected = _selectedColorValue == color.value;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedColorValue = color.value;
                            });
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.onSurface
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: color.withOpacity(0.45),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Daily reminder time',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _pickReminderTime,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.alarm_rounded),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedReminderTime == null
                                    ? 'Select reminder time'
                                    : _selectedReminderTime!.format(context),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            if (_selectedReminderTime != null)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedReminderTime = null;
                                  });
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: selectedColor.withOpacity(0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: selectedColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _submit,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Finish Setup'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const _ThemeModeSelector({
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _ThemeItem(
        title: 'System',
        subtitle: 'Follow device setting',
        value: 'system',
        icon: Icons.brightness_auto_rounded,
      ),
      _ThemeItem(
        title: 'Light',
        subtitle: 'Bright appearance',
        value: 'light',
        icon: Icons.light_mode_rounded,
      ),
      _ThemeItem(
        title: 'Dark',
        subtitle: 'Low-light appearance',
        value: 'dark',
        icon: Icons.dark_mode_rounded,
      ),
    ];

    return Column(
      children: items.map((item) {
        final selected = selectedValue == item.value;
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => onChanged(item.value),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest.withOpacity(0.25),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(item.icon),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(item.subtitle),
                      ],
                    ),
                  ),
                  Radio<String>(
                    value: item.value,
                    groupValue: selectedValue,
                    onChanged: (value) {
                      if (value != null) {
                        onChanged(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ThemeItem {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;

  const _ThemeItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
  });
}