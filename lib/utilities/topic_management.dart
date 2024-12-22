import 'package:flutter/material.dart';

import '../db/discusia.dart';
import '../db/discussion.dart';
import '../db/model.dart';
import '../db/auth_google.dart';

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
    return false;
  }
  return true;
}

Future<void> saveData() async {
  // collect and save data
  DiscussionUserInteraction data = DiscussionUserInteraction(
      userId: GoogleAuthService.currentUser!.uid,
      theme: DiscusiaConfig.currentTopic,
      userAnswer: DiscusiaConfig.responseController.text.trim(),
      evaluation: DiscusiaConfig.evaluation,
      suggestedIdea: DiscusiaConfig.suggestedIdea,
      suggestedAnswer: DiscusiaConfig.suggestedAnswer);

  final docId =
      await DiscussionInteractionDBManager.createDiscussionInteraction(data);
  data.uid = docId;

  DiscusiaConfig.interactions.add(data);
}
