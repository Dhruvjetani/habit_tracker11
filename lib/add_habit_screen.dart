import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddHabitScreen extends StatefulWidget {
  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final controller = TextEditingController();

  void saveHabit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList("habits") ?? [];

    Map<String, dynamic> newHabit = {
      "name": controller.text,
      "streak": 0,
      "longestStreak": 0,
      "lastCompleted": ""
    };

    data.add(jsonEncode(newHabit));
    await prefs.setStringList("habits", data);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Habit")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: controller, decoration: InputDecoration(labelText: "Habit Name")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: saveHabit, child: Text("Save"))
          ],
        ),
      ),
    );
  }
}
