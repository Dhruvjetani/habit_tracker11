import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Habit Tracker';

  static const List<String> categories = [
    'Health',
    'Study',
    'Fitness',
    'Reading',
    'Meditation',
    'Water',
    'Custom',
  ];

  static const List<String> frequencies = [
    'Daily',
    'Weekly',
    'Custom',
  ];

  static const List<Color> selectableColors = [
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.brown,
  ];

  static const List<IconData> selectableIcons = [
    Icons.favorite,
    Icons.menu_book,
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.water_drop,
    Icons.bedtime,
    Icons.directions_run,
    Icons.check_circle,
    Icons.star,
    Icons.local_fire_department,
    Icons.psychology,
    Icons.spa,
    Icons.work,
    Icons.school,
    Icons.timer,
  ];

  static const List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
}