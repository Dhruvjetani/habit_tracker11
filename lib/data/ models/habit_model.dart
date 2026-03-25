class HabitModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String frequency; // Daily, Weekly, Custom
  final List<int> customDays; // 1=Mon ... 7=Sun
  final int targetValue;
  final String targetUnit;
  final int iconCodePoint;
  final int colorValue;
  final String? reminderTime; // HH:mm
  final DateTime createdAt;
  final int currentStreak;
  final int bestStreak;
  final bool isArchived;

  const HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.frequency,
    required this.customDays,
    required this.targetValue,
    required this.targetUnit,
    required this.iconCodePoint,
    required this.colorValue,
    required this.reminderTime,
    required this.createdAt,
    required this.currentStreak,
    required this.bestStreak,
    required this.isArchived,
  });

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? frequency,
    List<int>? customDays,
    int? targetValue,
    String? targetUnit,
    int? iconCodePoint,
    int? colorValue,
    String? reminderTime,
    DateTime? createdAt,
    int? currentStreak,
    int? bestStreak,
    bool? isArchived,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'frequency': frequency,
      'customDays': customDays,
      'targetValue': targetValue,
      'targetUnit': targetUnit,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'reminderTime': reminderTime,
      'createdAt': createdAt.toIso8601String(),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'isArchived': isArchived,
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'],
      frequency: json['frequency'],
      customDays: List<int>.from(json['customDays'] ?? []),
      targetValue: json['targetValue'],
      targetUnit: json['targetUnit'] ?? '',
      iconCodePoint: json['iconCodePoint'],
      colorValue: json['colorValue'],
      reminderTime: json['reminderTime'],
      createdAt: DateTime.parse(json['createdAt']),
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      isArchived: json['isArchived'] ?? false,
    );
  }
}