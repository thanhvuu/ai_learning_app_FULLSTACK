package com.vu.ai_learning_backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;

import com.vu.ai_learning_backend.entity.Lesson;
import com.vu.ai_learning_backend.entity.Question;
import com.vu.ai_learning_backend.repository.LessonRepository;
import com.vu.ai_learning_backend.repository.QuestionRepository;
import com.vu.ai_learning_backend.service.AiService;
import com.vu.ai_learning_backend.service.PdfService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@CrossOrigin("*") // Dòng này để cho phép Flutter truy cập
@RequestMapping("/api/lessons")
public class LessonController {

    @Autowired
    private PdfService pdfService;

    @Autowired
    private AiService aiService;

    // --- GỌI THÊM 2 ANH THỦ KHO RA LÀM VIỆC ---
    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private QuestionRepository questionRepository;

    @PostMapping("/upload")
    public ResponseEntity<?> uploadPDF(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "quizType", defaultValue = "drag_drop") String quizType,
            @RequestParam("username") String username // <--- BỔ SUNG NHẬN TÊN USER TỪ FLUTTER
    ) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("Vui lòng chọn một file PDF!");
        }

        try {
            System.out.println("1. Đang đọc file PDF...");
            String pdfText = pdfService.extractText(file);

            System.out.println("2. Đang tạo và lưu Bài học (Lesson) vào Database...");
            Lesson lesson = new Lesson();
            // Lấy tên file làm tên bài học
            lesson.setTitle(file.getOriginalFilename());

            // --- LƯU THÊM CÁC THÔNG TIN MỚI ---
            lesson.setUsername(username);
            lesson.setQuizType(quizType);
            lesson.setProgress(0); // Vừa tạo thì tiến độ là 0%
            // ----------------------------------

            Lesson savedLesson = lessonRepository.save(lesson);

            System.out.println("3. Đang nhờ Gemini soạn câu hỏi " + quizType + "...");
            String jsonResult = aiService.generateQuizJson(pdfText, quizType);

            System.out.println("4. Đang dùng ObjectMapper phiên dịch JSON sang Object...");
            ObjectMapper mapper = new ObjectMapper();

            // Dặn máy dịch là nếu AI có trả về dư biến nào không có trong class Question thì cứ lờ đi
            mapper.configure(com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

            List<Question> questions = mapper.readValue(jsonResult, new TypeReference<List<Question>>(){});

            System.out.println("5. Đang cất từng câu hỏi vào kho...");
            for (Question q : questions) {
                q.setLesson(savedLesson);
                questionRepository.save(q);
            }

            // Gắn danh sách câu hỏi ngược lại vào Bài học để in ra màn hình JSON
            savedLesson.setQuestions(questions);

            System.out.println("6. Hoàn tất! Đã trả về thông tin bài học cho app.");
            return ResponseEntity.ok(savedLesson);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Có lỗi xảy ra: " + e.getMessage());
        }
    }

    // =================================================================
    //  THÊM API MỚI: LẤY DANH SÁCH BÀI HỌC CHO TAB "MY LESSONS"
    // =================================================================
    @GetMapping("/my-lessons")
    public ResponseEntity<?> getMyLessons(@RequestParam String username) {
        try {
            System.out.println("Đang lấy danh sách bài học của user: " + username);
            // Gọi hàm tìm kiếm đã viết trong LessonRepository
            List<Lesson> lessons = lessonRepository.findByUsernameOrderByCreatedAtDesc(username);
            return ResponseEntity.ok(lessons);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Lỗi lấy dữ liệu: " + e.getMessage());
        }
    }
}