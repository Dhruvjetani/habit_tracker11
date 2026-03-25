class UserProfileModel {
  final String name;
  final bool onboardingCompleted;
  final String themeMode; // system, light, dark
  final int seedColorValue;
  final String? globalReminderTime; // HH:mm

  const UserProfileModel({
    required this.name,
    required this.onboardingCompleted,
    required this.themeMode,
    required this.seedColorValue,
    this.globalReminderTime,
  });

  UserProfileModel copyWith({
    String? name,
    bool? onboardingCompleted,
    String? themeMode,
    int? seedColorValue,
    String? globalReminderTime,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      themeMode: themeMode ?? this.themeMode,
      seedColorValue: seedColorValue ?? this.seedColorValue,
      globalReminderTime: globalReminderTime ?? this.globalReminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'onboardingCompleted': onboardingCompleted,
      'themeMode': themeMode,
      'seedColorValue': seedColorValue,
      'globalReminderTime': globalReminderTime,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] ?? '',
      onboardingCompleted: json['onboardingCompleted'] ?? false,
      themeMode: json['themeMode'] ?? 'system',
      seedColorValue: json['seedColorValue'] ?? 0xFF6750A4,
      globalReminderTime: json['globalReminderTime'],
    );
  }
}