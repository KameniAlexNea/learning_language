import 'storage_manager.dart';

class Prompts {
  final String language;

  Prompts(this.language);

  List<Map<String, Object>> get getGenerateTopicsMessages {
    final themes = PreferencesManager.instance.loadThemes();
    final hasPreferences = themes.isNotEmpty;
    final preferenceMessage = hasPreferences
        ? "These are the user's preferences for discussion: ${themes.join(", ")}. The user maybe more engaged to discuss these subjects"
        : "The user didn't set a preference for subjects.";

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

The goal is to provide **a roadmap of key points** that are intellectually stimulating and creatively engaging, leaving space for detailed development later.
$langSuffix""";

  String get evaluationPrompt_ => """
Evaluate the following response for clarity, grammar, and provide suggestions. Discuss also the user ability to follow the subject. Your evaluation should be written in $langSuffix
""";

  String get evaluationPrompt => """
Evaluate the following dissertation response based on the following criteria:  

### I. Academic Rigor and Content Analysis  
1. **Thesis Alignment and Subject Coherence**  
   - How effectively does the dissertation address the original topic?  
   - Is the exploration of the subject sufficiently deep and broad?  
   - Does the dissertation align with the perspectives and insights suggested in the topic commentary?  

2. **Structural and Analytical Elements**  
   - Is the structure logical and coherent?  
   - Does the argument progress clearly and convincingly?  
   - Are key perspectives and insights effectively integrated?  

3. **Critical Thinking and Original Contribution**  
   - To what extent does the dissertation demonstrate critical thinking?  
   - Does it offer unique or innovative insights?  
   - How well does it balance analysis with originality?  

### II. Technical Writing Quality  
1. **Language and Communication**  
   - Assess grammar, syntax, and writing precision.  
   - Evaluate clarity and adherence to academic standards.  
   - Are sentence structures, vocabulary, and technical elements appropriate?  

2. **Citation and Research Integration**  
   - Are references relevant, scholarly, and properly cited?  
   - How well are external sources integrated into the arguments?  

### III. Creative and Interpretative Dimensions  
1. **Writing Technique and Style**  
   - How effectively are creative writing techniques used?  
   - Is the dissertation engaging and readable?  
   - Are stylistic choices appropriate for the topic?  

2. **Perspective and Interpretative Depth**  
   - Does the dissertation consider diverse perspectives?  
   - Are interpretations nuanced and complex?  
   - How well are multifaceted dimensions of the topic explored?  

### IV. Recommendations and Developmental Feedback  
1. **Strengths Identification**  
   - Highlight the strongest elements of the dissertation with specific examples.  

2. **Constructive Suggestions**  
   - Offer actionable recommendations for improvement.  
   - Suggest concrete strategies for addressing weaknesses.  

**Evaluation Format:**  
- Provide a detailed report, incorporating both qualitative commentary and quantitative scores (1-10) for each category.  
- Conclude with an overall assessment and actionable recommendations for further development.  

**Tone:** Professional, academic, constructive, and nuanced.  
**Length:** Approximately 500-750 words.  
""";
}
