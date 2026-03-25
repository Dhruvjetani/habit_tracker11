import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/date_utils.dart';
import '../data/ models/habit_completion_model.dart';
import '../data/ models/habit_model.dart';
import '../data/models/habit_completion_model.dart';
import '../data/models/habit_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/notification_service.dart';

class HabitProvider extends ChangeNotifier {
  final LocalStorageService localStorageService;
  final NotificationService notificationService;

  HabitProvider({
    required this.localStorageService,
    required this.notificationService,
  });

  final Uuid _uuid = const Uuid();

  final List<HabitModel> _habits = [];
  final List<HabitCompletionModel> _completions = [];

  bool _isLoading = true;

  List<HabitModel> get habits => List.unmodifiable(_habits);
  List<HabitCompletionModel> get completions => List.unmodifiable(_completions);
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _habits
      ..clear()
      ..addAll(localStorageService.getHabits());

    _completions
      ..clear()
      ..addAll(localStorageService.getCompletions());

    _recalculateAllStreaks(saveAfterUpdate: true);

    _isLoading = false;
    notifyListeners();
  }

  List<HabitModel> get activeHabits =>
      _habits.where((habit) => !habit.isArchived).toList();

  List<HabitModel> get archivedHabits =>
      _habits.where((habit) => habit.isArchived).toList();

  int get archivedHabitsCount => archivedHabits.length;

  List<HabitModel> getTodayHabits() {
    final today = DateTime.now();
    return activeHabits.where((habit) => _isHabitScheduledForDate(habit, today)).toList();
  }

  List<HabitModel> getHabitsForDate(DateTime date) {
    final normalized = AppDateUtils.dateOnly(date);
    return activeHabits
        .where((habit) => _isHabitScheduledForDate(habit, normalized))
        .toList();
  }

  List<HabitModel> getCompletedHabitsForDate(DateTime date) {
    final dateKey = AppDateUtils.formatDate(date);
    final completedIds = _completions
        .where((c) => c.dateKey == dateKey && c.completed)
        .map((e) => e.habitId)
        .toSet();

    return getHabitsForDate(date)
        .where((habit) => completedIds.contains(habit.id))
        .toList();
  }

  List<HabitModel> getPendingHabitsForDate(DateTime date) {
    final dateKey = AppDateUtils.formatDate(date);
    final completedIds = _completions
        .where((c) => c.dateKey == dateKey && c.completed)
        .map((e) => e.habitId)
        .toSet();

    return getHabitsForDate(date)
        .where((habit) => !completedIds.contains(habit.id))
        .toList();
  }

  bool isHabitCompletedOnDate(String habitId, DateTime date) {
    final dateKey = AppDateUtils.formatDate(date);
    return _completions.any(
          (c) => c.habitId == habitId && c.dateKey == dateKey && c.completed,
    );
  }

  Future<void> addHabit({
    required String title,
    required String description,
    required String category,
    required String frequency,
    required List<int> customDays,
    required int targetValue,
    required String targetUnit,
    required int iconCodePoint,
    required int colorValue,
    String? reminderTime,
  }) async {
    final habit = HabitModel(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      category: category,
      frequency: frequency,
      customDays: customDays,
      targetValue: targetValue,
      targetUnit: targetUnit.trim(),
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      reminderTime: reminderTime,
      createdAt: DateTime.now(),
      currentStreak: 0,
      bestStreak: 0,
      isArchived: false,
    );

    _habits.add(habit);
    await _saveHabits();

    if (reminderTime != null && reminderTime.isNotEmpty) {
      await _scheduleHabitReminder(habit);
    }

    notifyListeners();
  }

  Future<void> updateHabit(HabitModel updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index == -1) return;

    _habits[index] = updatedHabit;
    _recalculateHabitStreak(updatedHabit.id);
    await _saveHabits();

    if (updatedHabit.reminderTime != null && updatedHabit.reminderTime!.isNotEmpty) {
      await _scheduleHabitReminder(updatedHabit);
    } else {
      await notificationService.cancelHabitNotification(
        _notificationIdFromHabit(updatedHabit.id),
      );
    }

    notifyListeners();
  }

  Future<void> deleteHabit(String habitId) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    _habits.removeWhere((h) => h.id == habitId);
    _completions.removeWhere((c) => c.habitId == habitId);

    await notificationService.cancelHabitNotification(
      _notificationIdFromHabit(habitId),
    );
    await _saveHabits();
    await _saveCompletions();

    notifyListeners();
  }

  Future<void> archiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    _habits[index] = _habits[index].copyWith(isArchived: true);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> unarchiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    _habits[index] = _habits[index].copyWith(isArchived: false);
    await _saveHabits();
    notifyListeners();
  }

  HabitModel? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((h) => h.id == habitId);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    final normalizedDate = AppDateUtils.dateOnly(date);

    if (!_isHabitScheduledForDate(habit, normalizedDate)) return;

    final dateKey = AppDateUtils.formatDate(normalizedDate);
    final existingIndex = _completions.indexWhere(
          (c) => c.habitId == habitId && c.dateKey == dateKey,
    );

    if (existingIndex >= 0) {
      final existing = _completions[existingIndex];
      _completions[existingIndex] = existing.copyWith(completed: !existing.completed);
    } else {
      _completions.add(
        HabitCompletionModel(
          habitId: habitId,
          dateKey: dateKey,
          completed: true,
        ),
      );
    }

    _recalculateHabitStreak(habitId);
    await _saveCompletions();
    await _saveHabits();
    notifyListeners();
  }

  double getDailyProgress(DateTime date) {
    final total = getHabitsForDate(date).length;
    if (total == 0) return 0;

    final completed = getCompletedHabitsForDate(date).length;
    return completed / total;
  }

  int getTotalHabitsForDate(DateTime date) {
    return getHabitsForDate(date).length;
  }

  int getCompletedCountForDate(DateTime date) {
    return getCompletedHabitsForDate(date).length;
  }

  int getPendingCountForDate(DateTime date) {
    return getPendingHabitsForDate(date).length;
  }

  int getTotalCompletions() {
    return _completions.where((c) => c.completed).length;
  }

  int getLongestStreakAcrossHabits() {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.bestStreak).fold(0, max);
  }

  double getOverallCompletionRate() {
    final today = DateTime.now();
    final scheduledInstances = _calculateScheduledInstancesUntilDate(today);
    if (scheduledInstances == 0) return 0;

    final completedInstances = _completions.where((c) => c.completed).length;
    return completedInstances / scheduledInstances;
  }

  Map<String, int> getWeeklySummary() {
    final now = AppDateUtils.dateOnly(DateTime.now());
    final Map<String, int> result = {};

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final label = '${day.day}/${day.month}';
      result[label] = getCompletedCountForDate(day);
    }

    return result;
  }

  Map<String, int> getMonthlySummary() {
    final now = DateTime.now();
    final Map<String, int> result = {};

    for (int i = 3; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final label = '${monthDate.month}/${monthDate.year}';
      result[label] = _getCompletionsInMonth(monthDate.year, monthDate.month);
    }

    return result;
  }

  List<HabitModel> getCompletedHabitsOnSelectedDay(DateTime day) {
    return getCompletedHabitsForDate(day);
  }

  Set<DateTime> getCompletionDatesForCalendar() {
    return _completions
        .where((c) => c.completed)
        .map((c) => AppDateUtils.dateOnly(DateTime.parse(c.dateKey)))
        .toSet();
  }

  Future<void> _saveHabits() async {
    await localStorageService.saveHabits(_habits);
  }

  Future<void> _saveCompletions() async {
    await localStorageService.saveCompletions(_completions);
  }

  bool _isHabitScheduledForDate(HabitModel habit, DateTime date) {
    final normalizedDate = AppDateUtils.dateOnly(date);
    final createdDate = AppDateUtils.dateOnly(habit.createdAt);

    if (normalizedDate.isBefore(createdDate)) {
      return false;
    }

    final weekday = normalizedDate.weekday;

    switch (habit.frequency) {
      case 'Daily':
        return true;
      case 'Weekly':
        return createdDate.weekday == weekday;
      case 'Custom':
        return habit.customDays.contains(weekday);
      default:
        return false;
    }
  }

  int _calculateScheduledInstancesUntilDate(DateTime lastDate) {
    int total = 0;
    final normalizedLastDate = AppDateUtils.dateOnly(lastDate);

    for (final habit in activeHabits) {
      final start = AppDateUtils.dateOnly(habit.createdAt);
      DateTime cursor = start;

      while (!cursor.isAfter(normalizedLastDate)) {
        if (_isHabitScheduledForDate(habit, cursor)) {
          total++;
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }

    return total;
  }

  int _getCompletionsInMonth(int year, int month) {
    return _completions.where((completion) {
      if (!completion.completed) return false;
      final date = DateTime.parse(completion.dateKey);
      return date.year == year && date.month == month;
    }).length;
  }

  void _recalculateAllStreaks({bool saveAfterUpdate = false}) {
    for (final habit in _habits) {
      _recalculateHabitStreak(habit.id, save: false);
    }

    if (saveAfterUpdate) {
      localStorageService.saveHabits(_habits);
    }
  }

  void _recalculateHabitStreak(String habitId, {bool save = false}) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    final completedDates = _completions
        .where((c) => c.habitId == habitId && c.completed)
        .map((c) => AppDateUtils.dateOnly(DateTime.parse(c.dateKey)))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    int currentStreak = 0;
    int bestStreak = 0;
    int running = 0;
    DateTime? previous;

    for (final date in completedDates) {
      if (!_isHabitScheduledForDate(habit, date)) {
        continue;
      }

      if (previous == null) {
        running = 1;
      } else {
        final nextExpected = _nextScheduledDateAfter(habit, previous);
        if (nextExpected != null && AppDateUtils.isSameDate(nextExpected, date)) {
          running++;
        } else {
          running = 1;
        }
      }

      if (running > bestStreak) {
        bestStreak = running;
      }

      previous = date;
    }

    if (completedDates.isNotEmpty && previous != null) {
      final latestCompleted = previous;
      final today = AppDateUtils.dateOnly(DateTime.now());

      if (AppDateUtils.isSameDate(latestCompleted, today)) {
        currentStreak = running;
      } else {
        final expectedAfterLatest = _nextScheduledDateAfter(habit, latestCompleted);
        if (expectedAfterLatest != null &&
            (AppDateUtils.isSameDate(expectedAfterLatest, today) ||
                expectedAfterLatest.isAfter(today))) {
          currentStreak = running;
        } else {
          currentStreak = 0;
        }
      }
    }

    _habits[index] = habit.copyWith(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
    );

    if (save) {
      localStorageService.saveHabits(_habits);
    }
  }

  DateTime? _nextScheduledDateAfter(HabitModel habit, DateTime date) {
    DateTime cursor = date.add(const Duration(days: 1));

    for (int i = 0; i < 366; i++) {
      if (_isHabitScheduledForDate(habit, cursor)) {
        return cursor;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return null;
  }

  int _notificationIdFromHabit(String habitId) {
    return habitId.hashCode & 0x7fffffff;
  }

  Future<void> _scheduleHabitReminder(HabitModel habit) async {
    final reminderTime = habit.reminderTime;
    if (reminderTime == null || reminderTime.isEmpty) return;

    await notificationService.scheduleHabitReminder(
      id: _notificationIdFromHabit(habit.id),
      title: 'Habit Reminder',
      body: 'Time to complete "${habit.title}"',
      timeString: reminderTime,
    );
  }
}