class HabitCompletionModel {
  final String habitId;
  final String dateKey; // yyyy-MM-dd
  final bool completed;

  const HabitCompletionModel({
    required this.habitId,
    required this.dateKey,
    required this.completed,
  });

  HabitCompletionModel copyWith({
    String? habitId,
    String? dateKey,
    bool? completed,
  }) {
    return HabitCompletionModel(
      habitId: habitId ?? this.habitId,
      dateKey: dateKey ?? this.dateKey,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'dateKey': dateKey,
      'completed': completed,
    };
  }

  factory HabitCompletionModel.fromJson(Map<String, dynamic> json) {
    return HabitCompletionModel(
      habitId: json['habitId'],
      dateKey: json['dateKey'],
      completed: json['completed'] ?? false,
    );
  }
}