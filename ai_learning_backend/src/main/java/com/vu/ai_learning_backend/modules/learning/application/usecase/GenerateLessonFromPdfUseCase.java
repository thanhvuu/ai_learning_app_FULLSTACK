package com.vu.ai_learning_backend.modules.learning.application.usecase;

import com.vu.ai_learning_backend.modules.ai.application.port.GeminiClientPort;
import com.vu.ai_learning_backend.modules.ai.application.port.PdfExtractorPort;
import com.vu.ai_learning_backend.modules.learning.domain.model.Lesson;
import org.springframework.stereotype.Service;

import java.io.InputStream;

@Service
public class GenerateLessonFromPdfUseCase {

    private final PdfExtractorPort pdfExtractorPort;
    private final GeminiClientPort geminiClientPort;
    private final GenerateLessonByTopicUseCase lessonHelper;

    public GenerateLessonFromPdfUseCase(PdfExtractorPort pdfExtractorPort,
                                        GeminiClientPort geminiClientPort,
                                        GenerateLessonByTopicUseCase lessonHelper) {
        this.pdfExtractorPort = pdfExtractorPort;
        this.geminiClientPort = geminiClientPort;
        this.lessonHelper = lessonHelper;
    }

    public Lesson execute(InputStream inputStream, String filename, String quizType, String username) {
        String pdfText = pdfExtractorPort.extractText(inputStream);
        String jsonResult = geminiClientPort.generateQuizJson(pdfText, quizType);
        return lessonHelper.parseAndSaveLesson(jsonResult, filename, username, quizType, "PDF_UPLOAD", null);
    }
}

