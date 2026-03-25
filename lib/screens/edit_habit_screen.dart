import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ providers/habit_provider.dart';
import '../ widgets/custom_text_field.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/time_helper.dart';
import '../core/utils/validators.dart';
import '../data/ models/habit_model.dart';
import '../data/models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../widgets/custom_text_field.dart';

class EditHabitScreen extends StatefulWidget {
  static const String routeName = '/edit-habit';

  const EditHabitScreen({super.key});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _targetUnitController = TextEditingController();

  HabitModel? _habit;

  String _selectedCategory = AppConstants.categories.first;
  String _selectedFrequency = AppConstants.frequencies.first;
  List<int> _selectedCustomDays = [];
  int _selectedIconCodePoint = AppConstants.selectableIcons.first.codePoint;
  int _selectedColorValue = AppConstants.selectableColors.first.value;
  TimeOfDay? _selectedReminderTime;

  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _targetUnitController.dispose();
    super.dispose();
  }

  void _loadHabitIfNeeded() {
    if (_initialized) return;

    final habitId = ModalRoute.of(context)?.settings.arguments as String?;
    if (habitId == null) return;

    final habitProvider = context.read<HabitProvider>();
    final habit = habitProvider.getHabitById(habitId);

    if (habit == null) return;

    _habit = habit;
    _titleController.text = habit.title;
    _descriptionController.text = habit.description;
    _targetValueController.text = habit.targetValue.toString();
    _targetUnitController.text = habit.targetUnit;

    _selectedCategory = habit.category;
    _selectedFrequency = habit.frequency;
    _selectedCustomDays = List<int>.from(habit.customDays);
    _selectedIconCodePoint = habit.iconCodePoint;
    _selectedColorValue = habit.colorValue;
    _selectedReminderTime = TimeHelper.storageToTimeOfDay(habit.reminderTime);

    _initialized = true;
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

  Future<void> _updateHabit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_habit == null) return;

    if (_selectedFrequency == 'Custom' && _selectedCustomDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one custom day.'),
        ),
      );
      return;
    }

    final updatedHabit = _habit!.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      frequency: _selectedFrequency,
      customDays: _selectedCustomDays,
      targetValue: int.tryParse(_targetValueController.text.trim()) ?? 1,
      targetUnit: _targetUnitController.text.trim(),
      iconCodePoint: _selectedIconCodePoint,
      colorValue: _selectedColorValue,
      reminderTime: _selectedReminderTime != null
          ? TimeHelper.timeOfDayToStorage(_selectedReminderTime!)
          : null,
    );

    await context.read<HabitProvider>().updateHabit(updatedHabit);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit updated successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _loadHabitIfNeeded();

    if (_habit == null) {
      return const Scaffold(
        body: Center(
          child: Text('Habit not found'),
        ),
      );
    }

    final theme = Theme.of(context);
    final selectedColor = Color(_selectedColorValue);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
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
                          child: Text(
                            'Update your habit details',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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
                    onPressed: _updateHabit,
                    icon: const Icon(Icons.save_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Update Habit'),
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