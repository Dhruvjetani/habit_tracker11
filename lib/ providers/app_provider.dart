import 'package:flutter/material.dart';

import '../data/ models/user_profile_model.dart';
import '../data/models/user_profile_model.dart';
import '../data/services/local_storage_service.dart';

class AppProvider extends ChangeNotifier {
  final LocalStorageService localStorageService;

  AppProvider(this.localStorageService);

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = const Color(0xFF6750A4);
  UserProfileModel? _userProfile;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  UserProfileModel? get userProfile => _userProfile;
  bool get isLoaded => _isLoaded;

  bool get isOnboardingCompleted =>
      _userProfile?.onboardingCompleted ?? false;

  String get userName => _userProfile?.name ?? 'User';

  Future<void> loadAppSettings() async {
    final savedMode = localStorageService.getThemeMode();
    final savedSeedColor = localStorageService.getSeedColor();
    final profile = localStorageService.getUserProfile();

    _themeMode = _mapStringToThemeMode(savedMode);
    _seedColor = Color(savedSeedColor);
    _userProfile = profile;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String name,
    required String themeMode,
    required int seedColorValue,
    String? globalReminderTime,
  }) async {
    final profile = UserProfileModel(
      name: name.trim(),
      onboardingCompleted: true,
      themeMode: themeMode,
      seedColorValue: seedColorValue,
      globalReminderTime: globalReminderTime,
    );

    _userProfile = profile;
    _themeMode = _mapStringToThemeMode(themeMode);
    _seedColor = Color(seedColorValue);
    _isLoaded = true;

    await localStorageService.saveUserProfile(profile);
    await localStorageService.setThemeMode(themeMode);
    await localStorageService.setSeedColor(seedColorValue);

    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    final existing = _userProfile;
    if (existing == null) return;

    _userProfile = existing.copyWith(name: name.trim());
    await localStorageService.saveUserProfile(_userProfile!);
    notifyListeners();
  }

  Future<void> updateThemeMode(String mode) async {
    _themeMode = _mapStringToThemeMode(mode);
    await localStorageService.setThemeMode(mode);

    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(themeMode: mode);
      await localStorageService.saveUserProfile(_userProfile!);
    }

    notifyListeners();
  }

  Future<void> updateSeedColor(int colorValue) async {
    _seedColor = Color(colorValue);
    await localStorageService.setSeedColor(colorValue);

    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(seedColorValue: colorValue);
      await localStorageService.saveUserProfile(_userProfile!);
    }

    notifyListeners();
  }

  Future<void> updateGlobalReminderTime(String? time) async {
    if (_userProfile == null) return;

    _userProfile = _userProfile!.copyWith(globalReminderTime: time);
    await localStorageService.saveUserProfile(_userProfile!);
    notifyListeners();
  }

  ThemeMode _mapStringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}