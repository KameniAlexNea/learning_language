import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../db/discusia.dart';
import 'card_builder.dart';
import '../utilities/topic_management.dart';

class TypingScreen extends StatefulWidget {
  final TabController tabController;
  const TypingScreen({super.key, required this.tabController});

  @override
  _TypingScreenState createState() => _TypingScreenState();
}

class _TypingScreenState extends State<TypingScreen> {
  Future<void> _saveData() async {
    if (!checkCurrentTopicNotEmpty() ||
        DiscusiaConfig.responseController.text.trim().isEmpty ||
        DiscusiaConfig.currentTopic.isEmpty) {
      showError(
        context,
        "Please complete the following steps before saving data:\n"
        "1. Generate a topic\n"
        "2. Fill in some text\n"
        "3. Evaluate the topic",
      );
      return;
    }
    setState(() => DiscusiaConfig.isSavingState = true);
    try {
      await saveData();

      widget.tabController.animateTo(4);
    } on FirebaseException catch (e) {
      if (mounted) showError(context, e.code);
    } finally {
      setState(() => DiscusiaConfig.isSavingState = false);
    }
  }

  Future<void> generateTopic() async {
    try {
      setState(() => DiscusiaConfig.isGeneratingTopic = true);
      try {
        final response = await DiscusiaConfig.llmCall(
            DiscusiaConfig.prompts.getGenerateTopicsMessages, 500);

        setState(() {
          DiscusiaConfig.currentTopic = response ?? "No topic generated.";
        });
        DiscusiaConfig.clearInterface();
      } on SocketException catch (e) {
        if (mounted) showError(context, "Network error: ${e.message}");
      } catch (e) {
        if (mounted) showError(context, "An unexpected error occurred: $e");
      }
    } finally {
      setState(() => DiscusiaConfig.isGeneratingTopic = false);
    }
  }

  Future<void> evaluateResponse() async {
    if (!checkCurrentTopicNotEmpty() ||
        DiscusiaConfig.responseController.text.isEmpty) {
      showError(
          context,
          "Please complete the following steps before evaluation:\n"
          "1. Generate a topic\n"
          "2. Fill in some text\n");
      return;
    }
    setState(() => DiscusiaConfig.isEvaluatingResponse = true);
    try {
      final response = await DiscusiaConfig.llmCall(
          DiscusiaConfig.prompts.getEvaluateResponseMessages(
              DiscusiaConfig.currentTopic,
              DiscusiaConfig.responseController.text),
          1000);

      setState(() {
        DiscusiaConfig.evaluation = response ?? "No evaluation generated.";
        if (response != null) {
          widget.tabController.animateTo(3);
        }
      });
    } finally {
      setState(() => DiscusiaConfig.isEvaluatingResponse = false);
    }
  }

  Future<void> getSuggestedAnswer() async {
    if (!checkCurrentTopicNotEmpty()) {
      showError(context,
          "To suggest an answer, you have to generate first a discussion topic");
      return;
    }
    setState(() => DiscusiaConfig.isGettingSuggestedAnswer = true);
    try {
      final response = await DiscusiaConfig.llmCall(
          DiscusiaConfig.prompts
              .getSuggestedAnswerMessages(DiscusiaConfig.currentTopic),
          1000);

      setState(() {
        DiscusiaConfig.suggestedAnswer = response ?? "No suggestion generated.";
        // Switch to the Suggested Answer tab
        if (response != null) {
          widget.tabController.animateTo(2);
        }
      });
    } finally {
      setState(() => DiscusiaConfig.isGettingSuggestedAnswer = false);
    }
  }

  Future<void> getSuggestedIdea() async {
    if (!checkCurrentTopicNotEmpty()) {
      showError(context,
          "To suggest ideas, you have to generate first a discussion topic");
      return;
    }
    setState(() => DiscusiaConfig.isGettingSuggestedIdea = true);
    try {
      final response = await DiscusiaConfig.llmCall(
          DiscusiaConfig.prompts
              .getSuggestedIdeaMessages(DiscusiaConfig.currentTopic),
          1000);

      setState(() {
        DiscusiaConfig.suggestedIdea = response ?? "No suggestion idea.";
        // Switch to the Suggested Answer tab
        if (response != null) widget.tabController.animateTo(2);
      });
    } finally {
      setState(() => DiscusiaConfig.isGettingSuggestedIdea = false);
    }
  }

  Future<void> _showEssay() async {
    final title = DiscusiaConfig.currentTopic.isEmpty
        ? "Topic"
        : DiscusiaConfig.currentTopic.split("\n")[0];
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text("Your Essay"),
            content: SingleChildScrollView(
              child: buildCard(context, title, DiscusiaConfig.essay),
            ),
            scrollable: true,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'CLOSE'),
                child: const Text('CLOSE'),
              ),
            ]);
      },
    );
  }

  // Second Tab: Writing Assistant Functionality
  @override
  Widget build(BuildContext context) {
    DiscusiaConfig.responseController.text = DiscusiaConfig.essay;
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
                              DiscusiaConfig.currentTopic.isEmpty ||
                              DiscusiaConfig.currentTopicHasIdea
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
                              DiscusiaConfig.currentTopic.isEmpty ||
                              DiscusiaConfig.currentTopicHasAnswer
                          ? null
                          : getSuggestedAnswer,
                    ),
                    const Text("Answer"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.share2),
                      onPressed: DiscusiaConfig.isSavingState ||
                              DiscusiaConfig.currentTopic.isEmpty ||
                              DiscusiaConfig.evaluation.isEmpty
                          ? null
                          : _saveData,
                    ),
                    const Text("Share"),
                  ],
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildCard(
                        context, "Current Topic", DiscusiaConfig.currentTopic,
                        previewLength: 100),
                    const SizedBox(height: 10),
                    TextField(
                      controller: DiscusiaConfig.responseController,
                      maxLines: 10, // Makes it expandable for long text
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
                      textCapitalization: TextCapitalization.sentences,
                      onTapOutside: (event) {
                        setState(() {
                          DiscusiaConfig.essay =
                              DiscusiaConfig.responseController.text;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                        onPressed: _showEssay,
                        icon: const Icon(LucideIcons.view))
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
