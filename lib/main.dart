import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mode_provider.dart';
import 'pages/mode_page.dart';
import 'pages/main_page.dart';
import 'pages/stopwatch_page.dart';
import 'pages/timer_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ModeProvider(),
      child: FocusApp(),
    ),
  );
}

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus App',
      initialRoute: '/mode',
      routes: {
        '/mode': (context) => ModePage(),
        '/main': (context) => MainPage(),
        '/stopwatch': (context) => StopwatchPage(),
        '/timer': (context) => TimerPage(),
      },
    );
  }
}
