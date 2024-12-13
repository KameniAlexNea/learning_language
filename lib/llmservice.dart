import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_key.dart';

import 'package:huggingface_client/huggingface_client.dart';

final String openaiUrl = "https://api.openai.com/v1/chat/completions";

Future<http.Response> askLLM(
  modelName,
  messages,
  maxTokens,
) async {
  return http
      .post(
        Uri.parse(openaiUrl),
        headers: {
          "Authorization": "Bearer $openAIApiKey",
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
}

Future<String?> askLLMHF(
  String apiKey,
  List<Map<String, String>> messages,
  String model, {
  double temperature = 0.5,
  int maxTokens = 2048,
  double topP = 0.7,
  bool stream = false,
}) async {
  final client = HuggingFaceClient.getInferenceClient(
      inferenceApiKey, HuggingFaceClient.inferenceBasePath);

  final apiInstance = InferenceApi(client);

  final result = await apiInstance.query(
      queryString: jsonEncode({
        "model": model,
        "messages": messages,
        "temperature": temperature,
        "max_tokens": maxTokens,
        "top_p": topP,
        "stream": stream,
      }),
      model: model);

  return result;
}
