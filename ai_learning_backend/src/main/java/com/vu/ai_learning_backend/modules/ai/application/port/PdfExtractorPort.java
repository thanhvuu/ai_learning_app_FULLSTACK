package com.vu.ai_learning_backend.modules.ai.application.port;

import java.io.InputStream;

public interface PdfExtractorPort {
    String extractText(InputStream inputStream);
}

