package com.vu.ai_learning_backend.modules.ai.application.usecase;

import com.vu.ai_learning_backend.modules.ai.application.port.PdfExtractorPort;
import org.springframework.stereotype.Service;

import java.io.InputStream;

@Service
public class ExtractPdfTextUseCase {
    private final PdfExtractorPort pdfExtractorPort;

    public ExtractPdfTextUseCase(PdfExtractorPort pdfExtractorPort) {
        this.pdfExtractorPort = pdfExtractorPort;
    }

    public String execute(InputStream inputStream) {
        return pdfExtractorPort.extractText(inputStream);
    }
}

