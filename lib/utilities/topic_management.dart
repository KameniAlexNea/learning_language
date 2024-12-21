import 'package:flutter/material.dart';

import '../db/discusia.dart';
import '../db/discussion.dart';
import '../db/model.dart';
import 'auth_google.dart';

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

void showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ),
  );
}

bool checkCurrentTopicNotEmpty() {
  if (DiscusiaConfig.currentTopic.isEmpty) {
    DiscusiaConfig.errorMessage =
        "Current topic cannot be empty. Please, first generate a topic";

    return false;
  }
  return true;
}

Future<void> saveData() async {
  // collect and save data
  DiscussionUserInteraction data = DiscussionUserInteraction(
      userId: GoogleAuthService.user!.uid,
      theme: DiscusiaConfig.currentTopic,
      userAnswer: DiscusiaConfig.responseController.text.trim(),
      evaluation: DiscusiaConfig.evaluation,
      suggestedIdea: DiscusiaConfig.suggestedIdea,
      suggestedAnswer: DiscusiaConfig.suggestedAnswer);

  final docId =
      await DiscussionInteractionDBManager.createDiscussionInteraction(data);
  data.id = docId;

  DiscusiaConfig.interactions.add(data);
}
