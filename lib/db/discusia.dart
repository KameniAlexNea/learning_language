import '../utilities/prompts.dart';
import 'package:flutter/material.dart';

import '../api/llmservice.dart';

import 'model.dart';

class DiscusiaConfig {
  static String errorMessage = "";
  static String currentTopic = "";
  static String evaluation = "";
  static String suggestedAnswer = "";
  static String suggestedIdea = "";

  static bool isGeneratingTopic = false;
  static bool isEvaluatingResponse = false;
  static bool isGettingSuggestedAnswer = false;
  static bool isGettingSuggestedIdea = false;
  static bool isSavingState = false;

  static String selectedLanguage = "English";
  static Prompts get prompts => Prompts(selectedLanguage);

  static late TabController tabController;
  static Function get llmCall =>
      modelType == 0 ? askLLMOA : (modelType == 1 ? askLLMHF : askLLMGroq);
  static late Function setState;
  static final modelType = 2; // 0: OpenAI, 1: HF, 2: Groq
  static final TextEditingController responseController =
      TextEditingController();

  static final List<DiscussionUserInteraction> interactions = [];

  static void clearInterface({bool withTopic = false}) {
    setState(() {
      errorMessage = "";
      evaluation = "";
      suggestedAnswer = "";
      suggestedIdea = "";

      isEvaluatingResponse = false;
      isGettingSuggestedAnswer = false;
      isGettingSuggestedIdea = false;
      isSavingState = false;

      responseController.text = "";
      if (withTopic) {
        currentTopic = "";
        isGeneratingTopic = false;
      }
    });
  }
}
