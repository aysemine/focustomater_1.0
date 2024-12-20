import 'dart:async';
import 'dart:math'; // Import the math library for the max function
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mode_provider.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late Timer _timer;
  Duration _remainingTime = Duration.zero;
  bool _isRunning = false;
  bool _isPaused = false; // To check if the timer is paused
  double _sliderValue = 1; // Start at 1 minute for Easy mode and 20 for Hard mode

  @override
  void initState() {
    super.initState();
    final mode = Provider.of<ModeProvider>(context, listen: false).currentMode;
    _sliderValue = mode == Mode.Easy ? 1 : 20; // Initialize based on mode
    _remainingTime = Duration(minutes: _sliderValue.toInt()); // Set initial remaining time
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!_isRunning) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime > Duration.zero) {
            _remainingTime -= Duration(seconds: 1);
          } else {
            // Timer completed
            _isRunning = false;
            _timer.cancel();
            _completeTimer();
          }
        });
      });
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });
    }
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer.cancel();
      setState(() {
        _isRunning = false;
        _isPaused = true; // Set to paused
      });
    }
  }

  void _resumeTimer() {
    if (_isPaused) {
      _startTimer();
    }
  }

  void _cancelTimer() {
    if (_isRunning || _isPaused) {
      _timer.cancel();
      final remaining = _remainingTime;
      Provider.of<ModeProvider>(context, listen: false).resetTimer(remaining);
      setState(() {
        _remainingTime = Duration(minutes: _sliderValue.toInt()); // Reset remaining time based on slider value
        _isRunning = false; // Reset running state
        _isPaused = false; // Reset paused state
      });
    }
    // Navigate back to the main page
    Navigator.of(context).pop();
  }

  void _completeTimer() {
    final modeProvider = Provider.of<ModeProvider>(context, listen: false);
    modeProvider.completeTask(Duration(minutes: _sliderValue.toInt())); // Update daily time and give EXP
    setState(() {
      _remainingTime = Duration.zero; // Reset remaining time
      _sliderValue = modeProvider.currentMode == Mode.Easy ? 1 : 20; // Reset slider value based on mode
    });

    // Show a dialog upon timer completion
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Timer Completed'),
        content: Text('Your timer has finished!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog immediately if button is pressed
            },
            child: Text('OK'),
          ),
        ],
      ),
    ).then((_) {
      // Navigate back to the main page after a delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close the timer page
      });
    });
  }

  void _updateSliderValue(double value) {
    setState(() {
      _sliderValue = value;
      // Update the remaining time according to slider value
      _remainingTime = Duration(minutes: value.toInt());
    });
  }

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context).currentMode;

    return Scaffold(
      appBar: AppBar(
          title: Text("Timer - ${mode == Mode.Easy ? 'Easy' : 'Hard'} Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${_remainingTime.inMinutes.toString().padLeft(2, '0')}:${(_remainingTime.inSeconds.remainder(60)).toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Slider(
              value: _sliderValue,
              min: mode == Mode.Easy ? 1 : 20, // Minimum value set to 1 minute
              max: 60,
              divisions: max(60, (60 - (mode == Mode.Easy ? 1 : 20)).toInt()),
              label: "${_sliderValue.toInt()} minutes",
              onChanged: (value) {
                _updateSliderValue(value);
              },
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startTimer,
                  child: Text(_isPaused ? "Resume" : "Start"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: !_isRunning ? null : _pauseTimer,
                  child: Text("Stop"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: !_isRunning && !_isPaused ? null : _cancelTimer,
                  child: Text("Cancel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
