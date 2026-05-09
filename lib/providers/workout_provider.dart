import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_program.dart';

class WorkoutProvider with ChangeNotifier {
  List<Program> _programs = [];
  Set<String> _history = {}; // Storing dates as ISO strings

  // In WorkoutProvider class
  Set<String> get history => _history;

  WorkoutProvider() {
    _loadFromDisk();
  }

  List<Program> get programs => _programs;

  int get streak {
    if (_history.isEmpty) return 0;

    int count = 0;
    DateTime checkDate = DateTime.now();

    // We check backwards from today
    while (true) {
      String dateKey = formatDate(checkDate);
      bool workedOut = _history.contains(dateKey);
      bool wasScheduled = _wasDateScheduled(checkDate);

      if (workedOut) {
        // If they worked out, the streak continues (even if it wasn't scheduled!)
        count++;
      } else if (wasScheduled) {
        // If it was a scheduled day and they missed it, the streak is DEAD.
        // Exception: Don't kill the streak for "today" until the day is actually over.
        if (dateKey != formatDate(DateTime.now())) {
          break;
        }
      } else {
        // If it wasn't scheduled and they didn't work out, it's a valid rest day.
        // The streak survives, but the count doesn't increase.
      }

      checkDate = checkDate.subtract(const Duration(days: 1));

      // Safety break to prevent infinite loops if something goes wrong
      if (count > 3650) break;
    }
    return count;
  }

  // Helper to see if a specific date had a workout planned
  bool _wasDateScheduled(DateTime date) {
    int weekday = date.weekday;
    // Check if any program was assigned to this weekday
    return _programs.any((p) => p.scheduledDays.contains(weekday));
  }

  Program? get todayProgram {
    int weekday = DateTime.now().weekday;
    return _programs.cast<Program?>().firstWhere(
      (p) => p!.scheduledDays.contains(weekday),
      orElse: () => Program(id: '0', name: 'Rest Day', exercises: []),
    );
  }

  // --- PERSISTENCE LOGIC ---

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final programsJson = jsonEncode(_programs.map((p) => p.toJson()).toList());
    await prefs.setString('chalk_programs', programsJson);
    await prefs.setStringList('chalk_history', _history.toList());
  }

  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();

    final programsRaw = prefs.getString('chalk_programs');
    if (programsRaw != null) {
      final List decoded = jsonDecode(programsRaw);
      _programs = decoded.map((p) => Program.fromJson(p)).toList();
    } else {
      // Default initial program if storage is empty
      _programs = [
        Program(
          id: '1',
          name: 'Push Day',
          exercises: [Exercise(name: 'Bench Press', imageUrl: '')],
          scheduledDays: [1, 3, 5],
        ),
      ];
    }

    final historyRaw = prefs.getStringList('chalk_history');
    if (historyRaw != null) _history = historyRaw.toSet();

    notifyListeners();
  }

  void completeWorkout() {
    _history.add(formatDate(DateTime.now()));
    _saveToDisk();
    notifyListeners();
  }

  void updateSchedule(String programId, List<int> newDays) {
    int index = _programs.indexWhere((p) => p.id == programId);
    if (index != -1) {
      final p = _programs[index];
      _programs[index] = Program(
        id: p.id,
        name: p.name,
        exercises: p.exercises,
        scheduledDays: newDays,
      );
      _saveToDisk();
      notifyListeners();
    }
  }

  // Add these to your WorkoutProvider class
  void addOrUpdateProgram(Program program) {
    int index = _programs.indexWhere((p) => p.id == program.id);
    if (index != -1) {
      _programs[index] = program;
    } else {
      _programs.add(program);
    }
    _saveToDisk();
    notifyListeners();
  }

  void deleteProgram(String id) {
    _programs.removeWhere((p) => p.id == id);
    _saveToDisk();
    notifyListeners();
  }

  String formatDate(DateTime date) => "${date.year}-${date.month}-${date.day}";
}
