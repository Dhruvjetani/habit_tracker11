import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'add_habit_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  HomeScreen({required this.onThemeChanged});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, dynamic>> habits = [];
  String? profileImagePath;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadHabits();
    loadProfile();
    loadTheme();
  }

  void loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool("darkMode") ?? false;
    setState(() {});
  }

  void loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    profileImagePath = prefs.getString("profileImage");
    setState(() {});
  }

  void pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("profileImage", image.path);
      setState(() => profileImagePath = image.path);
    }
  }

  void loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList("habits") ?? [];
    habits = data
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    setState(() {});
  }

  void saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        "habits", habits.map((e) => jsonEncode(e)).toList());
  }

  void markComplete(int index) {
    String today = DateTime.now().toIso8601String().split("T")[0];

    if (habits[index]["lastCompleted"] != today) {
      habits[index]["streak"] += 1;

      if (habits[index]["streak"] >
          (habits[index]["longestStreak"] ?? 0)) {
        habits[index]["longestStreak"] =
        habits[index]["streak"];
      }

      habits[index]["lastCompleted"] = today;
      saveHabits();
      setState(() {});
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    Navigator.pop(context);
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    widget.onThemeChanged(isDarkMode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Habits"),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundImage: profileImagePath != null
                  ? FileImage(File(profileImagePath!))
                  : null,
              child: profileImagePath == null
                  ? Icon(Icons.person)
                  : null,
            ),
            onSelected: (value) {
              if (value == "theme") toggleTheme();
              if (value == "logout") logout();
              if (value == "profile") pickImage();
              if (value == "analytics") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AnalyticsScreen(habits: habits)),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "profile", child: Text("Change Profile Photo")),
              PopupMenuItem(value: "analytics", child: Text("Analytics")),
              PopupMenuItem(value: "theme", child: Text("Toggle Dark Mode")),
              PopupMenuItem(value: "logout", child: Text("Logout")),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddHabitScreen()));
          loadHabits();
        },
      ),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(habits[index]["name"]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🔥 ${habits[index]["streak"]} days"),
                  Text("🏆 Longest: ${habits[index]["longestStreak"]}"),
                ],
              ),
              leading: Checkbox(
                value: habits[index]["lastCompleted"] ==
                    DateTime.now().toIso8601String().split("T")[0],
                onChanged: (_) => markComplete(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
