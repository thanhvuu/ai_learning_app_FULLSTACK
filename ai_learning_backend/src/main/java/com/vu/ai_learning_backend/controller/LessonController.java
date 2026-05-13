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
            // 1. Xác định Category để tìm kiếm trong DB
            String searchCategory = (category != null && !category.isEmpty()) ? category : topic;

            // 2. Kiểm tra xem user này đã có bài học này chưa?
            // Lưu ý: Cần repository hỗ trợ findByUsernameAndCategory
            Lesson userLesson = lessonRepository.findFirstByUsernameAndCategory(username, searchCategory);
            if (userLesson != null) {
                System.out.println("--- Trả về bài học đã có của user: " + username + " ---");
                return ResponseEntity.ok(userLesson);
            }

            // 3. Nếu user chưa có, kiểm tra xem trong hệ thống đã có template bài học này chưa?
            Lesson templateLesson = lessonRepository.findFirstByCategory(searchCategory);
            if (templateLesson != null) {
                System.out.println("--- Cloning lesson from template for user: " + username + " ---");
                Lesson clonedLesson = cloneLessonForUser(templateLesson, username, quizType);
                return ResponseEntity.ok(clonedLesson);
            }

            // 4. Nếu chưa có template, mới gọi AI để tạo
            System.out.println("--- Cache Miss: Gọi AI để tạo bài học: " + topic + " ---");
            String jsonResult = aiService.generateLessonByTopic(topic, quizType);
            return processAiResponse(jsonResult, topic, username, quizType, searchCategory);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Có lỗi xảy ra: " + e.getMessage());
        }
    }

    private Lesson cloneLessonForUser(Lesson template, String username, String quizType) {
        Lesson newLesson = new Lesson();
        newLesson.setTitle(template.getTitle());
        newLesson.setUsername(username);
        newLesson.setQuizType(quizType); // User có thể chọn loại quiz khác nhau cho cùng 1 topic
        newLesson.setProgress(0);
        newLesson.setContent(template.getContent());
        newLesson.setCategory(template.getCategory());
        newLesson.setPdfUrl(template.getPdfUrl());
        
        Lesson savedLesson = lessonRepository.save(newLesson);
        
        // Clone vocabularies
        if (template.getVocabularies() != null) {
            List<Vocabulary> newVocabs = new ArrayList<>();
            for (Vocabulary v : template.getVocabularies()) {
                Vocabulary nv = new Vocabulary();
                nv.setWord(v.getWord());
                nv.setMeaning(v.getMeaning());
                nv.setPhonetic(v.getPhonetic());
                nv.setExample(v.getExample());
                nv.setLesson(savedLesson);
                newVocabs.add(vocabularyRepository.save(nv));
            }
            savedLesson.setVocabularies(newVocabs);
        }
        
        // Clone questions
        if (template.getQuestions() != null) {
            List<Question> newQuestions = new ArrayList<>();
            for (Question q : template.getQuestions()) {
                Question nq = new Question();
                nq.setSentenceStart(q.getSentenceStart());
                nq.setSentenceEnd(q.getSentenceEnd());
                nq.setCorrectAnswer(q.getCorrectAnswer());
                nq.setOptionA(q.getOptionA());
                nq.setOptionB(q.getOptionB());
                nq.setOptionC(q.getOptionC());
                nq.setOptionD(q.getOptionD());
                nq.setExplanation(q.getExplanation());
                nq.setLesson(savedLesson);
                newQuestions.add(questionRepository.save(nq));
            }
            savedLesson.setQuestions(newQuestions);
        }
        
        return savedLesson;
    }

    @PostMapping("/update-progress")
    public ResponseEntity<?> updateProgress(@RequestBody Map<String, Object> payload) {
        try {
            Long lessonId = Long.valueOf(payload.get("lessonId").toString());
            int progress = Integer.parseInt(payload.get("progress").toString());
            
            Lesson lesson = lessonRepository.findById(lessonId).orElseThrow();
            lesson.setProgress(progress);
            lessonRepository.save(lesson);
            
            return ResponseEntity.ok(Map.of("message", "Cập nhật tiến độ thành công"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Lỗi cập nhật: " + e.getMessage());
        }
    }

    // API lấy lộ trình học (Roadmap) cho một chuyên ngành
    @GetMapping("/roadmap")
    public ResponseEntity<?> getRoadmap(@RequestParam("major") String major) {
        System.out.println("--- Đang lấy Roadmap cho ngành: " + major + " ---");
        List<String> steps = new ArrayList<>();
        
        if (major.contains("Information Technology")) {
            steps = List.of("Introduction to IT", "Computer Hardware", "Software Engineering", "Computer Networking", "Cybersecurity Basics");
        } else if (major.contains("Business")) {
            steps = List.of("Business Basics", "Marketing Principles", "Financial Accounting", "Human Resource Management", "International Trade");
        } else if (major.contains("Medical")) {
            steps = List.of("Medical Terminology", "Human Anatomy", "Common Diseases", "Pharmacology Basics", "Patient Care & Communication");
        } else if (major.contains("Travel")) {
            steps = List.of("At the Airport", "Hotel Reservations", "Sightseeing & Directions", "Dining Out", "Emergency Situations");
        } else if (major.contains("Engineering")) {
            steps = List.of("Engineering Basics", "Materials Science", "Technical Drawing", "Mathematics for Engineers", "Safety Regulations");
        } else if (major.contains("Art")) {
            steps = List.of("Art History", "Color Theory", "Drawing Techniques", "Digital Design Basics", "Famous Artists & Works");
        } else if (major.contains("Daily")) {
            steps = List.of("Greetings & Introductions", "Family & Friends", "Hobbies & Interests", "Shopping & Prices", "Weather & Time");
        } else if (major.contains("IELTS") || major.contains("TOEIC")) {
            steps = List.of("Listening Strategies", "Reading Comprehension", "Writing Task 1 & 2", "Speaking Fluency", "Practice Tests");
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

    // API ADMIN: Tự động sinh dữ liệu mẫu hàng loạt để tránh người dùng phải đợi AI
    @PostMapping("/admin/pre-generate-batch")
    public ResponseEntity<?> preGenerateBatch() {
        List<String> popularTopics = List.of(
            "Frontend Basics", 
            "ReactJS Advanced", 
            "Database SQL", 
            "UI/UX Principles", 
            "Docker for Beginners"
        );
        
        int count = 0;
        for (String topic : popularTopics) {
            try {
                // Kiểm tra xem đã có trong DB chưa
                if (lessonRepository.findFirstByCategory(topic) != null) {
                    System.out.println("--- Admin: Bỏ qua (Đã có sẵn): " + topic + " ---");
                    continue;
                }
                
                System.out.println("--- Admin: Đang tạo trước dữ liệu cho: " + topic + " ---");
                String jsonResult = aiService.generateLessonByTopic(topic, "drag_drop");
                processAiResponse(jsonResult, topic, "system_admin", "drag_drop", topic);
                
                count++;
                // Nghỉ 5 giây để tránh bị giới hạn API Rate Limit của Gemini
                Thread.sleep(5000);
            } catch (Exception e) {
                System.err.println("--- Admin: Lỗi khi tạo topic " + topic + ": " + e.getMessage());
            }
        }
        
        return ResponseEntity.ok(Map.of("message", "Đã tạo thành công " + count + " bài học mới cho hệ thống."));
    }
}
