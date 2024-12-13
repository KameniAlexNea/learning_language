import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_key.dart';

// import 'package:huggingface_client/huggingface_client.dart';

Future<String?> askLLM(
  String url,
  String apiKey,
  String modelName,
  List<Map<String, dynamic>> messages,
  int maxTokens,
) async {
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
  // final client = HuggingFaceClient.getInferenceClient(
  //     hfApiKey, HuggingFaceClient.inferenceBasePath);

  // final apiInstance = InferenceApi(client);

  // final result = await apiInstance.chatCompletion(
  //     query: ApiQueryChatCompletion(
  //       message: messages,
  //       model: hfModelName,
  //       temperature: temperature,
  //       maxLength : maxTokens,
  //       stream: stream,
  //     ),
  //     );

  // return result?.choices[0].message.content;
}
