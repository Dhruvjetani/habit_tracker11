import '../ models/habit_completion_model.dart';
import '../ models/habit_model.dart';
import '../ models/user_profile_model.dart';
import '../services/local_storage_service.dart';

class HabitRepository {
  final LocalStorageService localStorageService;

  HabitRepository({required this.localStorageService});

  UserProfileModel? getUserProfile() {
    return localStorageService.getUserProfile();
  }

  Future<void> saveUserProfile(UserProfileModel profile) async {
    await localStorageService.saveUserProfile(profile);
  }

  List<HabitModel> getHabits() {
    return localStorageService.getHabits();
  }

  Future<void> saveHabits(List<HabitModel> habits) async {
    await localStorageService.saveHabits(habits);
  }

  List<HabitCompletionModel> getCompletions() {
    return localStorageService.getCompletions();
  }

  Future<void> saveCompletions(List<HabitCompletionModel> completions) async {
    await localStorageService.saveCompletions(completions);
  }

  Future<void> setThemeMode(String mode) async {
    await localStorageService.setThemeMode(mode);
  }

  String getThemeMode() {
    return localStorageService.getThemeMode();
  }

  Future<void> setSeedColor(int colorValue) async {
    await localStorageService.setSeedColor(colorValue);
  }

  int getSeedColor() {
    return localStorageService.getSeedColor();
  }
}