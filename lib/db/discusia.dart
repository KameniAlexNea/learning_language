import '../utilities/prompts.dart';
import 'package:flutter/material.dart';

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
  static Prompts prompts = Prompts("English");

  static late TabController tabController;
  static late Function llmCall;
  static late Function setState;
  static final modelType = 2; // 0: OpenAI, 1: HF, 2: Groq
  static final TextEditingController responseController = TextEditingController();
}
