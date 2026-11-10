package com.vu.ai_learning_backend.modules.gamification.presentation;

import com.vu.ai_learning_backend.modules.gamification.application.usecase.GetTodayProgressUseCase;
import com.vu.ai_learning_backend.modules.gamification.application.usecase.RecordStudyTimeUseCase;
import com.vu.ai_learning_backend.modules.gamification.domain.model.DailyProgress;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@CrossOrigin("*")
@RequestMapping("/api/progress")
public class ProgressController {

    private final GetTodayProgressUseCase getTodayProgressUseCase;
    private final RecordStudyTimeUseCase recordStudyTimeUseCase;

    public ProgressController(GetTodayProgressUseCase getTodayProgressUseCase,
                              RecordStudyTimeUseCase recordStudyTimeUseCase) {
        this.getTodayProgressUseCase = getTodayProgressUseCase;
        this.recordStudyTimeUseCase = recordStudyTimeUseCase;
    }

    @GetMapping("/today")
    public ResponseEntity<?> getTodayProgress(@RequestParam String username) {
        DailyProgress progress = getTodayProgressUseCase.execute(username);
        return ResponseEntity.ok(progress);
    }

    @PostMapping("/add-time")
    public ResponseEntity<?> addStudyTime(@RequestBody Map<String, Object> payload) {
        String username = (String) payload.get("username");
        int minutes = ((Number) payload.get("minutes")).intValue();

        DailyProgress updatedProgress = recordStudyTimeUseCase.execute(username, minutes);
        return ResponseEntity.ok(updatedProgress);
    }
}

