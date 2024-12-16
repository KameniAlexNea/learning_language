import 'dart:io';

import '../db/discusia.dart';
import '../db/model.dart';

bool checkCurrentTopicNotEmpty() {
  if (DiscusiaConfig.currentTopic.isEmpty) {
    DiscusiaConfig.setState(() {
      DiscusiaConfig.errorMessage =
          "Current topic cannot be empty. Please, first generate a topic";
    });
    return false;
  }
  return true;
}

Future<void> generateTopic() async {
  try {
    DiscusiaConfig.setState(() => DiscusiaConfig.isGeneratingTopic = true);
    try {
      final response = await DiscusiaConfig.llmCall(
          DiscusiaConfig.prompts.getGenerateTopicsMessages, 500);

      DiscusiaConfig.setState(() {
        DiscusiaConfig.currentTopic = response ?? "No topic generated.";
        DiscusiaConfig.evaluation = "";
        DiscusiaConfig.suggestedAnswer = "";
        DiscusiaConfig.suggestedIdea = "";
        DiscusiaConfig.errorMessage = "";
      });
    } on SocketException catch (e) {
      DiscusiaConfig.setState(() {
        DiscusiaConfig.errorMessage = "Network error: ${e.message}";
      });
    } catch (e) {
      DiscusiaConfig.setState(() {
        DiscusiaConfig.errorMessage = "An unexpected error occurred: $e";
      });
    }
  } finally {
    DiscusiaConfig.setState(() => DiscusiaConfig.isGeneratingTopic = false);
  }
}

Future<void> evaluateResponse() async {
  if (!checkCurrentTopicNotEmpty()) {
    return;
  }
  DiscusiaConfig.setState(() => DiscusiaConfig.isEvaluatingResponse = true);
  try {
    final response = await DiscusiaConfig.llmCall(
        DiscusiaConfig.prompts.getEvaluateResponseMessages(
            DiscusiaConfig.currentTopic,
            DiscusiaConfig.responseController.text),
        1000);

    DiscusiaConfig.setState(() {
      DiscusiaConfig.evaluation = response ?? "No evaluation generated.";
      DiscusiaConfig.errorMessage = "";
    });
  } finally {
    DiscusiaConfig.setState(() => DiscusiaConfig.isEvaluatingResponse = false);
  }
}

Future<void> getSuggestedAnswer() async {
  if (!checkCurrentTopicNotEmpty()) {
    return;
  }
  DiscusiaConfig.setState(() => DiscusiaConfig.isGettingSuggestedAnswer = true);
  try {
    final response = await DiscusiaConfig.llmCall(
        DiscusiaConfig.prompts
            .getSuggestedAnswerMessages(DiscusiaConfig.currentTopic),
        1000);

    DiscusiaConfig.setState(() {
      DiscusiaConfig.suggestedAnswer = response ?? "No suggestion generated.";
      DiscusiaConfig.errorMessage = "";
      // Switch to the Suggested Answer tab
      if (response != null) {
        DiscusiaConfig.tabController.animateTo(2);
      }
    });
  } finally {
    DiscusiaConfig.setState(
        () => DiscusiaConfig.isGettingSuggestedAnswer = false);
  }
}

Future<void> getSuggestedIdea() async {
  if (!checkCurrentTopicNotEmpty()) {
    return;
  }
  DiscusiaConfig.setState(() => DiscusiaConfig.isGettingSuggestedIdea = true);
  try {
    final response = await DiscusiaConfig.llmCall(
        DiscusiaConfig.prompts
            .getSuggestedIdeaMessages(DiscusiaConfig.currentTopic),
        1000);

    DiscusiaConfig.setState(() {
      DiscusiaConfig.suggestedIdea = response ?? "No suggestion idea.";
      DiscusiaConfig.errorMessage = "";
      // Switch to the Suggested Answer tab
      if (response != null) DiscusiaConfig.tabController.animateTo(2);
    });
  } finally {
    DiscusiaConfig.setState(
        () => DiscusiaConfig.isGettingSuggestedIdea = false);
  }
}

Future<void> saveData() async {
  if (!checkCurrentTopicNotEmpty() ||
      DiscusiaConfig.responseController.text.trim().isEmpty ||
      DiscusiaConfig.currentTopic.isEmpty) {
    return;
  }
  DiscusiaConfig.setState(() => DiscusiaConfig.isSavingState = true);
  try {
    // collect and save data
    final String text = DiscusiaConfig.responseController.text.trim();
    DiscussionInteraction data = DiscussionInteraction(
        theme: DiscusiaConfig.currentTopic,
        userAnswer: text,
        evaluation: DiscusiaConfig.evaluation,
        suggestedIdea: DiscusiaConfig.suggestedIdea,
        suggestedAnswer: DiscusiaConfig.suggestedAnswer);
  } finally {
    DiscusiaConfig.setState(() => DiscusiaConfig.isSavingState = false);
  }
}