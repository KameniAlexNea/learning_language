import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utilities/api_key.dart';

Future<String?> askLLM(
  String url,
  String apiKey,
  String modelName,
  List<Map<String, dynamic>> messages,
  int maxTokens,
) async {
  if (kDebugMode) {
    return "Okay Great \n Messages: $messages \n Model: $modelName";
  }
  final response = await http
      .post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: utf8.encode(jsonEncode({
          "model": modelName,
          "messages": messages,
          "max_tokens": maxTokens,
          "temperature": 0.7,
        })),
      )
      .timeout(const Duration(seconds: 60));

  response.statusCode;

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['choices']?[0]?['message']?['content']?.toString();
  }
  return null;
}

Future<String?> askLLMOA(
  List<Map<String, dynamic>> messages,
  int maxTokens,
) {
  return askLLM(openaiUrl, openAIApiKey, openAiModel, messages, maxTokens);
}

Future<String?> askLLMGroq(
  List<Map<String, dynamic>> messages,
  int maxTokens,
) {
  return askLLM(groqApiUrl, groqApiKey, gropModel, messages, maxTokens);
}

Future<String?> askLLMHF(
  List<Map<String, Object>> messages,
  int maxTokens, {
  double temperature = 0.5,
  double topP = 0.7,
  bool stream = false,
}) async {
  return askLLM(hfLink, hfApiKey, hfModelName, messages, maxTokens);
}
