package com.vu.ai_learning_backend.controller;

import com.vu.ai_learning_backend.service.AiService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dictionary")
@CrossOrigin(origins = "*") // Cho phép Flutter gọi API
public class DictionaryController {

    @Autowired
    private AiService aiService;

    @GetMapping("/lookup")
    public ResponseEntity<String> lookupWord(@RequestParam("word") String word) {
        try {
            // Gọi AI để tra từ
            String jsonResult = aiService.lookupDictionary(word);
            return ResponseEntity.ok(jsonResult);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("{\"error\": \"Lỗi server: " + e.getMessage() + "\"}");
        }
    }
}