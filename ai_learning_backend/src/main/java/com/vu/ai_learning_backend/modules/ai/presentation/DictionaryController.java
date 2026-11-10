package com.vu.ai_learning_backend.modules.ai.presentation;

import com.vu.ai_learning_backend.modules.ai.application.usecase.LookupDictionaryUseCase;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dictionary")
@CrossOrigin(origins = "*")
public class DictionaryController {

    private final LookupDictionaryUseCase lookupDictionaryUseCase;

    public DictionaryController(LookupDictionaryUseCase lookupDictionaryUseCase) {
        this.lookupDictionaryUseCase = lookupDictionaryUseCase;
    }

    @GetMapping("/lookup")
    public ResponseEntity<String> lookupWord(@RequestParam("word") String word) {
        try {
            String jsonResult = lookupDictionaryUseCase.execute(word);
            return ResponseEntity.ok(jsonResult);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("{\"error\": \"Lỗi server: " + e.getMessage() + "\"}");
        }
    }
}

