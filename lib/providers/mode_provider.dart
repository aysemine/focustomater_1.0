import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Mode { Easy, Hard }

class ModeProvider with ChangeNotifier {
  Mode _currentMode = Mode.Easy;
  int _exp = 0; // Global EXP variable
  Duration _dailyTime = Duration.zero; // Variable to store daily time
  DateTime? _lastResetDate; // Variable to track the last reset date

  Mode get currentMode => _currentMode;
  int get exp => _exp;

  String get formattedDailyTime =>
      "${_dailyTime.inHours}h ${(_dailyTime.inMinutes.remainder(60))}m ${(_dailyTime.inSeconds.remainder(60))}s";

  ModeProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load EXP, Mode, and Daily Time from SharedPreferences
    _exp = prefs.getInt('exp') ?? 0;
    _currentMode = Mode.values[prefs.getInt('mode') ?? 0];
    int dailyTimeInSeconds = prefs.getInt('dailyTime') ?? 0;
    _dailyTime = Duration(seconds: dailyTimeInSeconds);

    String? lastResetString = prefs.getString('lastResetDate');

// Check if lastResetString is null before parsing
    if (lastResetString != null) {
      _lastResetDate = DateTime.parse(lastResetString);
    } else {
      // Handle the case when there is no stored last reset date, if necessary
      _lastResetDate = DateTime.now(); // or set it to a default value
    }

    notifyListeners();

  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save EXP, Mode, and Daily Time to SharedPreferences
    await prefs.setInt('exp', _exp);
    await prefs.setInt('mode', _currentMode.index);
    await prefs.setInt('dailyTime', _dailyTime.inSeconds);

    // Save last reset date
    if (_lastResetDate != null) {
      await prefs.setString('lastResetDate', _lastResetDate!.toIso8601String());
    }
  }

  void setMode(Mode mode) {
    _currentMode = mode;
    _saveData();  // Save data when mode changes
    notifyListeners();
  }

  void addExp(int points) {
    _exp += points;
    _saveData();  // Save data when EXP changes
    notifyListeners();
  }

  void deductExp(int points) {
    _exp = (_exp - points).clamp(0, double.infinity).toInt();
    _saveData();  // Save data when EXP changes
    notifyListeners();
  }

  void updateDailyTime(Duration duration) {
    if (_lastResetDate == null ||
        DateTime.now().difference(_lastResetDate!).inDays > 0) {
      _dailyTime = duration;
      _lastResetDate = DateTime.now();
    } else {
      _dailyTime += duration;
    }
    _saveData();  // Save data when daily time changes
    notifyListeners();
  }

  void completeTask(Duration elapsed) {
    int points = 0;
    if (_currentMode == Mode.Easy) {
      points = elapsed.inMinutes;
      addExp(points + 1);
    } else if (_currentMode == Mode.Hard) {
      points = elapsed.inMinutes * 2;
      addExp(points + 10);
    }
    updateDailyTime(elapsed);
  }

  void finishEarly(Duration remaining) {
    int deduction = _currentMode == Mode.Easy ? remaining.inMinutes : remaining.inMinutes * 2;
    deductExp(deduction);
  }

  void resetTimer(Duration remaining) {
    finishEarly(remaining);
  }

  void resetDailyTime() {
    _dailyTime = Duration.zero;
    _saveData();  // Save data when daily time is reset
    notifyListeners();
  }
}
