import 'package:flutter/material.dart';

import '../db/discusia.dart';
import '../widgets/builder.dart';

class EvalScreen extends StatefulWidget {
  const EvalScreen({super.key});

  @override
  _EvalScreenState createState() => _EvalScreenState();
}

class _EvalScreenState extends State<EvalScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildCard(context, "Current Topic", DiscusiaConfig.currentTopic),
            const SizedBox(height: 10),
            buildCard(context, "Suggested Ideas", DiscusiaConfig.suggestedIdea),
            const SizedBox(height: 10),
            buildCard(
                context, "Suggested Answer", DiscusiaConfig.suggestedAnswer),
          ],
        ),
      ),
    );
  }
}
