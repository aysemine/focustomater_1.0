import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mode_provider.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  bool _hasStopped = false; // Track if the stopwatch has been stopped

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startStopwatch() {
    if (!_isRunning) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _elapsed += Duration(seconds: 1);
        });
      });
      setState(() {
        _isRunning = true;
        _hasStopped = false; // Reset the stopped state when starting
      });
    }
  }

  void _stopStopwatch() {
    if (_isRunning) {
      _timer.cancel();
      setState(() {
        _isRunning = false;
        _hasStopped = true; // Set hasStopped to true when stopped
      });
    }
  }

  void _resetStopwatch() {
    final mode = Provider.of<ModeProvider>(context, listen: false).currentMode;

    if (mode == Mode.Hard && _elapsed.inMinutes < 20) {
      int penalty = _elapsed.inMinutes * 2;
      Provider.of<ModeProvider>(context, listen: false).deductExp(penalty);
    }

    _timer.cancel();
    setState(() {
      _isRunning = false;
      _elapsed = Duration.zero;
      _hasStopped = false; // Reset the stopped state when reset
    });
  }

  void _saveTime() {
    final modeProvider = Provider.of<ModeProvider>(context, listen: false);

    // Check the current mode and the elapsed time
    if (modeProvider.currentMode == Mode.Easy) {
      // In Easy mode, complete the task and give EXP
      modeProvider.completeTask(_elapsed);
      _resetStopwatch(); // Reset the stopwatch after saving
      Navigator.of(context).pop(); // Navigate back to the previous page
    } else if (modeProvider.currentMode == Mode.Hard) {
      // In Hard mode, check if 20 minutes have passed
      if (_elapsed.inMinutes >= 20) {
        modeProvider.completeTask(_elapsed); // Complete the task, which updates EXP
        _resetStopwatch(); // Reset the stopwatch after saving
        Navigator.of(context).pop(); // Navigate back to the previous page
      } else {
        // Show a SnackBar if the save attempt doesn't meet the conditions
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Save is only allowed after 20 minutes in Hard Mode.',
            style: TextStyle(fontSize: 16),
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeProvider = Provider.of<ModeProvider>(context);
    final exp = modeProvider.exp; // Get the global EXP from the provider

    return Scaffold(
      appBar: AppBar(
          title: Text("Stopwatch - ${modeProvider.currentMode == Mode.Easy ? 'Easy' : 'Hard'} Mode")
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _elapsed.toString().split('.').first.padLeft(8, "0"),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("EXP: $exp", style: TextStyle(fontSize: 24)), // Display the EXP from the provider
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startStopwatch,
                  child: Text("Start"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: !_isRunning ? null : _stopStopwatch,
                  child: Text("Stop"),
                ),
              ],
            ),
            // Show Reset and Save buttons only when the stopwatch has been stopped
            if (_hasStopped) ...[
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _resetStopwatch,
                    child: Text("Reset"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _saveTime,
                    child: Text("Save"),
                  ),
                ],
              ),
              if (modeProvider.currentMode == Mode.Hard && _elapsed.inMinutes < 20)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Save is only available after 20 minutes in Hard Mode",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
