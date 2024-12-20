import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mode_provider.dart';

class ModePage extends StatelessWidget {
  const ModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Select Mode"),
        automaticallyImplyLeading: false, // Prevent back button from appearing
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Provider.of<ModeProvider>(context, listen: false)
                    .setMode(Mode.Easy);
                Navigator.pushNamed(context, '/main');
              },
              child: Text("Easy Mode"),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<ModeProvider>(context, listen: false)
                    .setMode(Mode.Hard);
                Navigator.pushNamed(context, '/main');
              },
              child: Text("Hard Mode"),
            ),
          ],
        ),
      ),
    );
  }
}
