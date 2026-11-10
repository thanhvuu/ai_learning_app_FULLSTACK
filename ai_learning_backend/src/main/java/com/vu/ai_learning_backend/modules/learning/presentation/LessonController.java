package com.vu.ai_learning_backend.modules.learning.presentation;

import com.vu.ai_learning_backend.modules.learning.application.usecase.*;
import com.vu.ai_learning_backend.modules.learning.domain.model.Lesson;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@CrossOrigin("*")
@RequestMapping("/api/lessons")
public class LessonController {

    private final GenerateLessonFromPdfUseCase generateLessonFromPdfUseCase;
    private final GenerateLessonByTopicUseCase generateLessonByTopicUseCase;
    private final UpdateLessonProgressUseCase updateLessonProgressUseCase;
    private final GetUserLessonsUseCase getUserLessonsUseCase;
    private final GetRoadmapUseCase getRoadmapUseCase;
    private final PreGenerateBatchLessonsUseCase preGenerateBatchLessonsUseCase;

    public LessonController(GenerateLessonFromPdfUseCase generateLessonFromPdfUseCase,
                            GenerateLessonByTopicUseCase generateLessonByTopicUseCase,
                            UpdateLessonProgressUseCase updateLessonProgressUseCase,
                            GetUserLessonsUseCase getUserLessonsUseCase,
                            GetRoadmapUseCase getRoadmapUseCase,
                            PreGenerateBatchLessonsUseCase preGenerateBatchLessonsUseCase) {
        this.generateLessonFromPdfUseCase = generateLessonFromPdfUseCase;
        this.generateLessonByTopicUseCase = generateLessonByTopicUseCase;
        this.updateLessonProgressUseCase = updateLessonProgressUseCase;
        this.getUserLessonsUseCase = getUserLessonsUseCase;
        this.getRoadmapUseCase = getRoadmapUseCase;
        this.preGenerateBatchLessonsUseCase = preGenerateBatchLessonsUseCase;
    }

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
            Lesson lesson = generateLessonFromPdfUseCase.execute(file.getInputStream(), file.getOriginalFilename(), quizType, username);
            return ResponseEntity.ok(lesson);
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
            Lesson lesson = generateLessonByTopicUseCase.execute(topic, quizType, username, category);
            return ResponseEntity.ok(lesson);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Có lỗi xảy ra: " + e.getMessage());
        }
    }

    @PostMapping("/update-progress")
    public ResponseEntity<?> updateProgress(@RequestBody Map<String, Object> payload) {
        try {
            Long lessonId = Long.valueOf(payload.get("lessonId").toString());
            int progress = Integer.parseInt(payload.get("progress").toString());

            updateLessonProgressUseCase.execute(lessonId, progress);
            return ResponseEntity.ok(Map.of("message", "Cập nhật tiến độ thành công"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Lỗi cập nhật: " + e.getMessage());
        }
    }

    @GetMapping("/roadmap")
    public ResponseEntity<?> getRoadmap(@RequestParam("major") String major) {
        System.out.println("--- Đang lấy Roadmap cho ngành: " + major + " ---");
        List<String> steps = getRoadmapUseCase.execute(major);
        return ResponseEntity.ok(steps);
    }

    @GetMapping("/my-lessons")
    public ResponseEntity<?> getMyLessons(@RequestParam("username") String username) {
        try {
            List<Lesson> lessons = getUserLessonsUseCase.execute(username);
            return ResponseEntity.ok(lessons);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Lỗi lấy dữ liệu: " + e.getMessage());
        }
    }

    @PostMapping("/admin/pre-generate-batch")
    public ResponseEntity<?> preGenerateBatch() {
        int count = preGenerateBatchLessonsUseCase.execute();
        return ResponseEntity.ok(Map.of("message", "Đã tạo thành công " + count + " bài học mới cho hệ thống."));
    }
}

