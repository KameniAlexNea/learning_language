class Prompts {
  final String language;

  Prompts(this.language);

  final String MODEL_NAME = "gpt-4o";

  String get langSuffix =>
      language.toLowerCase() != "english"
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

  String get answerPrompt =>
      """To generate a thoughtful and creative response:

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

  String get evaluationPrompt => """
Evaluate the following response for clarity, grammar, and provide suggestions. Discuss also the user ability to follow the subject. Your evaluation should be written in 
""";
}
