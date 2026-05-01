package com.vu.ai_learning_backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;

import com.vu.ai_learning_backend.entity.Lesson;
import com.vu.ai_learning_backend.entity.Question;
import com.vu.ai_learning_backend.entity.Vocabulary;
import com.vu.ai_learning_backend.repository.LessonRepository;
import com.vu.ai_learning_backend.repository.QuestionRepository;
import com.vu.ai_learning_backend.repository.VocabularyRepository;
import com.vu.ai_learning_backend.service.AiService;
import com.vu.ai_learning_backend.service.PdfService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@CrossOrigin("*")
@RequestMapping("/api/lessons")
public class LessonController {

    @Autowired
    private PdfService pdfService;

    @Autowired
    private AiService aiService;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private VocabularyRepository vocabularyRepository;

    @PostMapping("/upload")
    public ResponseEntity<?> uploadPDF(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "quizType", defaultValue = "drag_drop") String quizType,
            @RequestParam("username") String username
    ) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("Vui lòng chọn một file PDF!");
        }
        try {
            String pdfText = pdfService.extractText(file);
            String jsonResult = aiService.generateQuizJson(pdfText, quizType);
            return processAiResponse(jsonResult, file.getOriginalFilename(), username, quizType, "PDF_UPLOAD");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Có lỗi xảy ra: " + e.getMessage());
        }
    }

    @PostMapping("/generate-by-topic")
    public ResponseEntity<?> generateByTopic(
            @RequestParam("topic") String topic,
            @RequestParam(value = "quizType", defaultValue = "drag_drop") String quizType,
            @RequestParam("username") String username,
            @RequestParam(value = "category", required = false) String category
    ) {
        try {
            String jsonResult = aiService.generateLessonByTopic(topic, quizType);
            return processAiResponse(jsonResult, topic, username, quizType, category != null ? category : topic);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Có lỗi xảy ra: " + e.getMessage());
        }
    }

    // API lấy lộ trình học (Roadmap) cho một chuyên ngành
    @GetMapping("/roadmap")
    public ResponseEntity<?> getRoadmap(@RequestParam("major") String major) {
        // Trong thực tế, bạn có thể gọi AI để sinh Roadmap hoặc lấy từ một danh sách cố định.
        // Ở đây tôi giả lập một lộ trình gồm 5 bài học cho mỗi ngành.
        List<String> steps = new ArrayList<>();
        if (major.contains("Information Technology")) {
            steps = List.of("Introduction to IT", "Computer Hardware", "Software Engineering", "Computer Networking", "Cybersecurity Basics");
        } else if (major.contains("Business")) {
            steps = List.of("Business Basics", "Marketing Principles", "Financial Accounting", "Human Resource Management", "International Trade");
        } else {
            steps = List.of("Fundamental Concepts", "Essential Vocabulary", "Advanced Topics", "Case Studies", "Final Review");
        }
        return ResponseEntity.ok(steps);
    }

    private ResponseEntity<?> processAiResponse(String jsonResult, String title, String username, String quizType, String category) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

        com.fasterxml.jackson.databind.JsonNode rootNode = mapper.readTree(jsonResult);
        String content = rootNode.path("content").asText();
        List<Vocabulary> vocabularies = mapper.convertValue(rootNode.path("vocabularies"), new TypeReference<List<Vocabulary>>(){});
        List<Question> questions = mapper.convertValue(rootNode.path("questions"), new TypeReference<List<Question>>(){});

        Lesson lesson = new Lesson();
        lesson.setTitle(title);
        lesson.setUsername(username);
        lesson.setQuizType(quizType);
        lesson.setProgress(0);
        lesson.setContent(content);
        lesson.setCategory(category);

        Lesson savedLesson = lessonRepository.save(lesson);

        if (vocabularies != null) {
            for (Vocabulary v : vocabularies) {
                v.setLesson(savedLesson);
                vocabularyRepository.save(v);
            }
        }

        for (Question q : questions) {
            q.setLesson(savedLesson);
            questionRepository.save(q);
        }

        savedLesson.setVocabularies(vocabularies);
        savedLesson.setQuestions(questions);
        return ResponseEntity.ok(savedLesson);
    }

    @GetMapping("/my-lessons")
    public ResponseEntity<?> getMyLessons(@RequestParam("username") String username) {
        try {
            List<Lesson> lessons = lessonRepository.findByUsernameOrderByCreatedAtDesc(username);
            return ResponseEntity.ok(lessons);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Lỗi lấy dữ liệu: " + e.getMessage());
        }
    }
}
