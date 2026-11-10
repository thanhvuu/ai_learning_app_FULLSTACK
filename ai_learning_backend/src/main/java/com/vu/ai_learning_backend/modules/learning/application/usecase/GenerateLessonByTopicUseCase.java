package com.vu.ai_learning_backend.modules.learning.application.usecase;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vu.ai_learning_backend.modules.ai.application.port.GeminiClientPort;
import com.vu.ai_learning_backend.modules.learning.domain.model.Lesson;
import com.vu.ai_learning_backend.modules.learning.domain.model.Question;
import com.vu.ai_learning_backend.modules.learning.domain.model.Vocabulary;
import com.vu.ai_learning_backend.modules.learning.domain.repository.LessonRepositoryPort;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class GenerateLessonByTopicUseCase {

    private final LessonRepositoryPort lessonRepositoryPort;
    private final GeminiClientPort geminiClientPort;
    private final ObjectMapper mapper;

    public GenerateLessonByTopicUseCase(LessonRepositoryPort lessonRepositoryPort,
                                       GeminiClientPort geminiClientPort) {
        this.lessonRepositoryPort = lessonRepositoryPort;
        this.geminiClientPort = geminiClientPort;
        this.mapper = new ObjectMapper();
        this.mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
    }

    public Lesson execute(String topic, String quizType, String username, String category) {
        String searchCategory = (category != null && !category.isEmpty()) ? category : topic;

        // 1. Kiểm tra xem user này đã có bài học này chưa
        Optional<Lesson> userLesson = lessonRepositoryPort.findFirstByUsernameAndCategory(username, searchCategory);
        if (userLesson.isPresent()) {
            System.out.println("--- Trả về bài học đã có của user: " + username + " ---");
            return userLesson.get();
        }

        // 2. Nếu user chưa có, kiểm tra xem đã có template bài học này trong hệ thống chưa
        Optional<Lesson> templateLesson = lessonRepositoryPort.findFirstByCategory(searchCategory);
        if (templateLesson.isPresent()) {
            System.out.println("--- Cloning lesson from template for user: " + username + " ---");
            Lesson cloned = templateLesson.get().cloneForUser(username, quizType);
            return lessonRepositoryPort.save(cloned);
        }

        // 3. Nếu chưa có template, gọi AI để sinh bài học
        System.out.println("--- Cache Miss: Gọi AI để tạo bài học: " + topic + " ---");
        String jsonResult = geminiClientPort.generateLessonByTopic(topic, quizType);
        return parseAndSaveLesson(jsonResult, topic, username, quizType, searchCategory, null);
    }

    public Lesson parseAndSaveLesson(String jsonResult, String title, String username, String quizType, String category, String pdfUrl) {
        try {
            JsonNode rootNode = mapper.readTree(jsonResult);
            String content = rootNode.path("content").asText();

            List<Vocabulary> vocabularies = mapper.convertValue(rootNode.path("vocabularies"), new TypeReference<List<Vocabulary>>() {});
            List<Question> questions = mapper.convertValue(rootNode.path("questions"), new TypeReference<List<Question>>() {});

            Lesson lesson = Lesson.builder()
                    .title(title)
                    .username(username)
                    .quizType(quizType)
                    .progress(0)
                    .content(content)
                    .category(category)
                    .pdfUrl(pdfUrl)
                    .vocabularies(vocabularies != null ? vocabularies : new ArrayList<>())
                    .questions(questions != null ? questions : new ArrayList<>())
                    .build();

            return lessonRepositoryPort.save(lesson);
        } catch (Exception e) {
            throw new RuntimeException("Lỗi phân tích cú pháp bài học từ AI: " + e.getMessage(), e);
        }
    }
}

