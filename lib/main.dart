import 'package:discursia/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  dotenv.load(fileName: ".env");
  runApp(const WritingAssistantApp());
}

class WritingAssistantApp extends StatelessWidget {
  const WritingAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WritingAssistantScreen(),
    );
  }
}
