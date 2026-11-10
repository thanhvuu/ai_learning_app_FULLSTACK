package com.vu.ai_learning_backend.modules.ai.application.usecase;

import com.vu.ai_learning_backend.modules.ai.application.port.GeminiClientPort;
import org.springframework.stereotype.Service;

@Service
public class LookupDictionaryUseCase {
    private final GeminiClientPort geminiClientPort;

    public LookupDictionaryUseCase(GeminiClientPort geminiClientPort) {
        this.geminiClientPort = geminiClientPort;
    }

    public String execute(String word) {
        if (word == null || word.trim().isEmpty()) {
            return "{\"error\": \"Từ khóa không được để trống\"}";
        }
        return geminiClientPort.lookupDictionary(word.trim());
    }
}

