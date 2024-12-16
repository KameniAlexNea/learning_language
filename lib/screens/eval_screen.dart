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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildCard(
              context,
              "Current Topic",
              DiscusiaConfig.currentTopic,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 2.0,
            ),
            const SizedBox(height: 16),
            buildCard(
              context,
              "Suggested Ideas",
              DiscusiaConfig.suggestedIdea,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              elevation: 1.0,
            ),
            const SizedBox(height: 16),
            buildCard(
              context,
              "Suggested Answer",
              DiscusiaConfig.suggestedAnswer,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              elevation: 1.0,
            ),
          ],
        ),
      ),
    );
  }
}
