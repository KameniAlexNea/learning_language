import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../db/discusia.dart';
import 'card_builder.dart';
import '../utilities/topic_management.dart';

class TypingScreen extends StatefulWidget {
  const TypingScreen({super.key});

  @override
  _TypingScreenState createState() => _TypingScreenState();
}

class _TypingScreenState extends State<TypingScreen> {
  Future<void> _saveData() async {
    if (!checkCurrentTopicNotEmpty() ||
        DiscusiaConfig.responseController.text.trim().isEmpty ||
        DiscusiaConfig.currentTopic.isEmpty) {
      return; // @TODO add an alert here
    }
    setState(() => DiscusiaConfig.isSavingState = true);
    try {
      await saveData();

      DiscusiaConfig.setState(() {
        DiscusiaConfig.tabController.animateTo(4);
      });
    } finally {
      setState(() => DiscusiaConfig.isSavingState = false);
    }
  }

  // Second Tab: Writing Assistant Functionality
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.plus),
                      onPressed: DiscusiaConfig.isGeneratingTopic
                          ? null
                          : generateTopic,
                    ),
                    const Text("Generate"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.checkCircle),
                      onPressed: DiscusiaConfig.isEvaluatingResponse ||
                              DiscusiaConfig.currentTopic.isEmpty
                          ? null
                          : evaluateResponse,
                    ),
                    const Text("Evaluate"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.lightbulb),
                      onPressed: DiscusiaConfig.isGettingSuggestedIdea ||
                              DiscusiaConfig.currentTopic.isEmpty
                          ? null
                          : getSuggestedIdea,
                    ),
                    const Text("Idea"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.messageCircle),
                      onPressed: DiscusiaConfig.isGettingSuggestedAnswer ||
                              DiscusiaConfig.currentTopic.isEmpty
                          ? null
                          : getSuggestedAnswer,
                    ),
                    const Text("Answer"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.save),
                      onPressed: DiscusiaConfig.isSavingState ||
                              DiscusiaConfig.currentTopic.isEmpty ||
                              DiscusiaConfig.evaluation.isEmpty
                          ? null
                          : _saveData,
                    ),
                    const Text("Save"),
                  ],
                ),
              ],
            ),
            if (DiscusiaConfig.errorMessage.isNotEmpty)
              Text(
                "Error: ${DiscusiaConfig.errorMessage}",
                style: const TextStyle(color: Colors.red),
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildCard(
                        context, "Current Topic", DiscusiaConfig.currentTopic),
                    const SizedBox(height: 10),
                    TextField(
                        controller: DiscusiaConfig.responseController,
                        maxLines: 50, // Makes it expandable for long text
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          labelText: "Write your essay here",
                          alignLabelWithHint: true, // Aligns label to top
                        ),
                        style: TextStyle(fontSize: 16.0),
                        textAlignVertical: TextAlignVertical.top,
                        minLines: 5, // Starts with 5 lines
                        textCapitalization: TextCapitalization.sentences),
                    // const SizedBox(height: 10),
                    // buildCard(context, "Evaluation", DiscusiaConfig.evaluation),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
