package com.vu.ai_learning_backend.controller;

import com.vu.ai_learning_backend.service.AiService;
import com.vu.ai_learning_backend.service.PdfService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@CrossOrigin("*")// dòng này để cho phép Flutter truy cập
@RequestMapping("/api/lessons")
public class LessonController {

    @Autowired
    private PdfService pdfService;

    @Autowired
    private AiService aiService; // Thêm anh não bộ AI vào đây

    @PostMapping("/upload")
    public ResponseEntity<String> uploadPDF(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("Vui lòng chọn một file PDF!");
        }

        System.out.println("1. Đang đọc file PDF...");
        String extractedText = pdfService.extractText(file);

        System.out.println("2. Đang nhờ Gemini soạn câu hỏi... (Mất khoảng 3-5 giây)");
        String quizJson = aiService.generateQuizJson(extractedText);

        System.out.println("3. Xong! Đã trả về cho app.");
        return ResponseEntity.ok(quizJson);
    }
}