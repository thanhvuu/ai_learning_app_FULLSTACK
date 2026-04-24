package com.vu.ai_learning_backend.controller;

import com.vu.ai_learning_backend.entity.DailyProgress;
import com.vu.ai_learning_backend.service.ProgressService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@CrossOrigin("*")
@RequestMapping("/api/progress")
public class ProgressController {

    @Autowired
    private ProgressService progressService;

    // API 1: Lấy tiến độ hôm nay
    @GetMapping("/today")
    public ResponseEntity<?> getTodayProgress(@RequestParam String username) {
        DailyProgress progress = progressService.getTodayProgress(username);
        return ResponseEntity.ok(progress);
    }

    // API 2: Báo cáo đã học xong 1 khoảng thời gian
    @PostMapping("/add-time")
    public ResponseEntity<?> addStudyTime(@RequestBody Map<String, Object> payload) {
        String username = (String) payload.get("username");
        int minutes = (int) payload.get("minutes");

        DailyProgress updatedProgress = progressService.addStudyTime(username, minutes);
        return ResponseEntity.ok(updatedProgress);
    }
}