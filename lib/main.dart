import 'package:flutter/material.dart';
import 'package:hw11_ai_summary/ui/summary_screen.dart';

void main() {
  runApp(const Project11App());
}

class Project11App extends StatelessWidget {
  const Project11App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SummaryScreen(),
    );
  }
}
