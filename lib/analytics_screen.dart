import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  AnalyticsScreen({required this.habits});

  @override
  Widget build(BuildContext context) {
    int total = habits.length;
    int totalStreak =
    habits.fold<int>(0, (sum, h) => sum + (h["streak"] as int));


    return Scaffold(
      appBar: AppBar(title: Text("Analytics")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Card(child: ListTile(title: Text("Total Habits"), trailing: Text("$total"))),
            Card(child: ListTile(title: Text("Total Streak Days"), trailing: Text("$totalStreak"))),
          ],
        ),
      ),
    );
  }
}
