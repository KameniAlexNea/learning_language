import 'storage_manager.dart';

class Prompts {
  final String language;

  Prompts(this.language);

  List<Map<String, Object>> get getGenerateTopicsMessages {
    final themes = PreferencesManager.instance.loadThemes();
    final hasPreferences = themes.isNotEmpty;
    final preferenceMessage = hasPreferences
        ? "These are the user's preferences for discussion: ${themes.join(", ")}. The user may be more engaged to discuss these subjects, but keep in mind that you're not forced to follow these topcis"
        : "";

    return [
      {
        "role": "system",
        "content": systemPrompt + preferenceMessage,
      },
    ];
  }

  List<Map<String, Object>> getEvaluateResponseMessages(
          String currentTopic, String userResponse) =>
      [
        {"role": "system", "content": systemPrompt},
        {"role": "assistant", "content": currentTopic},
        {
          "role": "user",
          "content": "$evaluationPrompt\n\nResponse: $userResponse"
        },
      ];

  List<Map<String, Object>> getSuggestedAnswerMessages(String currentTopic) => [
        {"role": "system", "content": answerSystemPrompt},
        {"role": "user", "content": "Topic:\n\n $currentTopic"},
        {"role": "system", "content": answerPrompt}
      ];

  List<Map<String, Object>> getSuggestedIdeaMessages(String currentTopic) => [
        {"role": "system", "content": answerSystemPrompt},
        {"role": "user", "content": "Topic:\n\n $currentTopic"},
        {"role": "system", "content": ideaPrompt}
      ];

  String get langSuffix => language.toLowerCase() != "english"
      ? "\nYour answer should be written in **$language** even if the prompt is in English"
      : "";

  String get systemPrompt =>
      """You are an AI assistant tasked with suggesting a widely appealing writing topic along with a brief, insightful commentary. The goal is to provide an engaging topic that can stimulate creative thinking and is suited to diverse writing levels. Avoid overly common themes like "A day in the life of..." or object-focused topics. Instead, aim for themes that resonate broadly and invite exploration while remaining open-ended to encourage individual expression.

After presenting the topic, provide a concise commentary that:
1. Explains why the topic is generally appealing and relevant.
2. Highlights key areas or perspectives to consider within the topic.
3. Suggests one or two writing techniques or skills that could enhance the writing experience and outcome for this topic.

Keep the commentary concise and focused, staying under 200 words to ensure clarity and ease of understanding.
$langSuffix""";

  String get answerSystemPrompt =>
      """You are an AI assistant tasked with generating a thoughtful and creative response that explores a given theme. Your goal is to provide an insightful and engaging exploration of the topic, considering various perspectives and implications.
$langSuffix""";

  String get answerPrompt => """To generate a thoughtful and creative response:

1. Take a moment to consider the topic from multiple angles. Think about its historical context, current relevance, potential future implications, and how it might relate to different fields of study or aspects of life.

2. Draw upon a wide range of knowledge and ideas to make connections that may not be immediately obvious. Feel free to incorporate relevant examples, analogies, or metaphors to illustrate your points.

3. Consider potential counterarguments or alternative viewpoints to provide a balanced exploration of the theme.

4. Aim for depth rather than breadth. It's better to explore a few key ideas thoroughly than to superficially touch on many points.

5. Be creative in your approach. Don't be afraid to propose unique ideas or unconventional perspectives, as long as they are relevant and well-reasoned.

6. Ensure your response flows logically from one point to the next, creating a coherent narrative around the theme.

Structure your response as follows:

1. Begin with a brief introduction that sets the stage for your exploration of the topic.
2. Develop 2-3 main points or arguments related to the theme, each in its own paragraph.
3. Conclude with a synthesis of your ideas and a thought-provoking final statement or question.

Remember, the goal is to provide a response that is both intellectually stimulating and creatively engaging. Aim to leave the reader with new insights or perspectives on the topic.
$langSuffix""";

  String get ideaPrompt =>
      """To generate thoughtful and creative **main ideas** for a response:

1. Reflect on the topic from multiple perspectives, considering its historical context, current relevance, potential future implications, and connections to various fields of study or aspects of life. 
   
2. Focus on generating **2-3 concise main ideas** that highlight different angles or arguments related to the topic. Avoid delving into full explanations; instead, provide a clear and focused outline of the core ideas. 

3. Include examples, analogies, or metaphors only as brief suggestions to illustrate each idea, if relevant.

4. Aim for depth within each idea, ensuring it is distinct and meaningful. Prioritize quality and originality over quantity.

5. Highlight any counterarguments or alternative perspectives succinctly, where applicable, to indicate balance in the exploration.

**Output Structure:**
- A brief introduction or context statement about the topic.
- A list of 2-3 main ideas, each expressed in a sentence or two.
- (Optional) A final thought or question to inspire deeper exploration of the topic.

The goal is to provide **a roadmap of key points** (not the full answer, make it short) that are intellectually stimulating and creatively engaging, leaving space for detailed development later.
$langSuffix""";

  String get evaluationPrompt => """
You are an advanced AI evaluator specialized in assessing language learning responses with a comprehensive, multi-dimensional approach.

Evaluation Dimensions:

1. Language Proficiency Assessment
- Linguistic Accuracy
  * Grammatical structure analysis
  * Verb tense and conjugation correctness
  * Syntax and sentence construction

- Lexical Complexity
  * Vocabulary range and appropriateness
  * Use of idiomatic expressions
  * Sophistication of word choice

- Linguistic Nuance
  * Contextual language usage
  * Tone and register appropriateness
  * Natural language flow

2. Argument Development
- Structural Analysis
  * Clarity of argument progression
  * Logical connectivity of ideas
  * Coherence and cohesion

- Depth of Elaboration
  * Length and complexity of argument
  * Number of distinct points developed
  * Quality of supporting details
  * Depth of critical thinking

3. Communication Effectiveness
- Comprehensibility
  * Clarity of main ideas
  * Ease of understanding
  * Precision of expression

- Communicative Intent
  * Alignment with prompt requirements
  * Completeness of response
  * Ability to convey complex thoughts

4. Language Learning Indicators
- Linguistic Risk-Taking
  * Use of complex grammatical structures
  * Attempts at sophisticated vocabulary
  * Willingness to explore linguistic boundaries

- Progress Markers
  * Comparison with expected language level
  * Evidence of language skill development
  * Innovative language use

Deliverable Format:
Provide a comprehensive narrative that:
- Breaks down linguistic performance
- Highlights language learning strengths
- Suggests targeted improvement strategies
- Offers encouraging, constructive feedback
- Identifies specific linguistic and communicative achievements

Include specific, actionable recommendations that support the learner's language development journey.
Your evaluation should be written in $language  
""";
}
