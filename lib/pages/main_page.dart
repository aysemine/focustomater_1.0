import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mode_provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the current mode and EXP value from the provider
    final mode = Provider.of<ModeProvider>(context).currentMode;
    final exp = Provider.of<ModeProvider>(context).exp; // Get the global EXP
    final dailyTime = Provider.of<ModeProvider>(context).formattedDailyTime; // Get formatted daily time

    return Scaffold(
      appBar: AppBar(
        title: Text("Focus App - ${mode == Mode.Easy ? 'Easy' : 'Hard'} Mode"),
        automaticallyImplyLeading: false, // Prevent back button from appearing
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Daily Time: $dailyTime", // Display the formatted daily time
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "EXP: $exp", // Display the dynamic EXP value
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/stopwatch');
              },
              child: Text("Stopwatch"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/timer');
              },
              child: Text("Timer"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, '/mode');
              },
              child: Text("Change Mode"),
            ),
          ],
        ),
      ),
    );
  }

}
