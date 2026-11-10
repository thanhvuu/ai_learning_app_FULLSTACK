package com.vu.ai_learning_backend.modules.ai.application.port;

public interface GeminiClientPort {
    String generateQuizJson(String pdfText, String quizType);
    String generateLessonByTopic(String topic, String quizType);
    String lookupDictionary(String word);
}

