import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ providers/habit_provider.dart';
import '../ widgets/custom_text_field.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/time_helper.dart';
import '../core/utils/validators.dart';


class AddHabitScreen extends StatefulWidget {
  static const String routeName = '/add-habit';

  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController(text: '1');
  final _targetUnitController = TextEditingController(text: 'time');

  String _selectedCategory = AppConstants.categories.first;
  String _selectedFrequency = AppConstants.frequencies.first;
  List<int> _selectedCustomDays = [];
  int _selectedIconCodePoint = AppConstants.selectableIcons.first.codePoint;
  int _selectedColorValue = AppConstants.selectableColors.first.value;
  TimeOfDay? _selectedReminderTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _targetUnitController.dispose();
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

  void _toggleCustomDay(int day) {
    setState(() {
      if (_selectedCustomDays.contains(day)) {
        _selectedCustomDays.remove(day);
      } else {
        _selectedCustomDays.add(day);
        _selectedCustomDays.sort();
      }
    });
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFrequency == 'Custom' && _selectedCustomDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one custom day.'),
        ),
      );
      return;
    }

    final targetValue = int.tryParse(_targetValueController.text.trim()) ?? 1;
    final reminderString = _selectedReminderTime != null
        ? TimeHelper.timeOfDayToStorage(_selectedReminderTime!)
        : null;

    await context.read<HabitProvider>().addHabit(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      frequency: _selectedFrequency,
      customDays: _selectedCustomDays,
      targetValue: targetValue,
      targetUnit: _targetUnitController.text.trim(),
      iconCodePoint: _selectedIconCodePoint,
      colorValue: _selectedColorValue,
      reminderTime: reminderString,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit added successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = Color(_selectedColorValue);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: selectedColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            IconData(
                              _selectedIconCodePoint,
                              fontFamily: 'MaterialIcons',
                            ),
                            color: selectedColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _titleController.text.trim().isEmpty
                                    ? 'Your new habit'
                                    : _titleController.text.trim(),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Create a routine and stay consistent every day.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  controller: _titleController,
                  label: 'Habit Title',
                  hint: 'Ex. Drink Water',
                  validator: (value) =>
                      Validators.requiredField(value, fieldName: 'Habit title'),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Write a short description',
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                _SectionTitle(title: 'Category'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: AppConstants.categories
                      .map(
                        (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                _SectionTitle(title: 'Frequency'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  items: AppConstants.frequencies
                      .map(
                        (frequency) => DropdownMenuItem(
                      value: frequency,
                      child: Text(frequency),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFrequency = value);
                    }
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.repeat_rounded),
                  ),
                ),
                if (_selectedFrequency == 'Custom') ...[
                  const SizedBox(height: 14),
                  _SectionTitle(title: 'Custom Days'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(AppConstants.weekDays.length, (index) {
                      final dayNumber = index + 1;
                      final isSelected = _selectedCustomDays.contains(dayNumber);

                      return FilterChip(
                        label: Text(AppConstants.weekDays[index]),
                        selected: isSelected,
                        onSelected: (_) => _toggleCustomDay(dayNumber),
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _targetValueController,
                        label: 'Target Value',
                        hint: '1',
                        keyboardType: TextInputType.number,
                        validator: (value) => Validators.positiveNumber(
                          value,
                          fieldName: 'Target value',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _targetUnitController,
                        label: 'Target Unit',
                        hint: 'times / liters / minutes',
                        validator: (value) => Validators.requiredField(
                          value,
                          fieldName: 'Target unit',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionTitle(title: 'Choose Icon'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppConstants.selectableIcons.map((icon) {
                    final selected = _selectedIconCodePoint == icon.codePoint;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIconCodePoint = icon.codePoint;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: selected
                              ? selectedColor.withOpacity(0.16)
                              : theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? selectedColor : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: selected
                              ? selectedColor
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                _SectionTitle(title: 'Choose Color'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppConstants.selectableColors.map((color) {
                    final selected = _selectedColorValue == color.value;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedColorValue = color.value;
                        });
                      },
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
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                _SectionTitle(title: 'Reminder Time'),
                const SizedBox(height: 8),
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
                          .withOpacity(0.28),
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
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saveHabit,
                    icon: const Icon(Icons.save_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Save Habit'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}