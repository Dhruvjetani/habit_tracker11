import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../ models/habit_completion_model.dart';
import '../ models/habit_model.dart';
import '../ models/user_profile_model.dart';
import '../../core/constants/storage_keys.dart';


class LocalStorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveUserProfile(UserProfileModel profile) async {
    await _prefs.setString(
      StorageKeys.userProfile,
      jsonEncode(profile.toJson()),
    );
  }

  UserProfileModel? getUserProfile() {
    final data = _prefs.getString(StorageKeys.userProfile);
    if (data == null) return null;

    return UserProfileModel.fromJson(
      jsonDecode(data) as Map<String, dynamic>,
    );
  }

  Future<void> saveHabits(List<HabitModel> habits) async {
    final encoded = habits.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(StorageKeys.habits, encoded);
  }

  List<HabitModel> getHabits() {
    final list = _prefs.getStringList(StorageKeys.habits) ?? [];
    return list
        .map((e) => HabitModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCompletions(List<HabitCompletionModel> completions) async {
    final encoded = completions.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList('habit_completions', encoded);
  }

  List<HabitCompletionModel> getCompletions() {
    final list = _prefs.getStringList('habit_completions') ?? [];
    return list
        .map((e) => HabitCompletionModel.fromJson(
      jsonDecode(e) as Map<String, dynamic>,
    ))
        .toList();
  }

  Future<void> setThemeMode(String value) async {
    await _prefs.setString(StorageKeys.themeMode, value);
  }

  String getThemeMode() {
    return _prefs.getString(StorageKeys.themeMode) ?? 'system';
  }

  Future<void> setSeedColor(int colorValue) async {
    await _prefs.setInt(StorageKeys.seedColor, colorValue);
  }

  int getSeedColor() {
    return _prefs.getInt(StorageKeys.seedColor) ?? 0xFF6750A4;
  }
}