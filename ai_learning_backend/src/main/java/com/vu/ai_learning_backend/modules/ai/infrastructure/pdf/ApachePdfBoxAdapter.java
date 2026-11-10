package com.vu.ai_learning_backend.modules.ai.infrastructure.pdf;

import com.vu.ai_learning_backend.modules.ai.application.port.PdfExtractorPort;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.springframework.stereotype.Component;

import java.io.InputStream;

@Component
public class ApachePdfBoxAdapter implements PdfExtractorPort {

    @Override
    public String extractText(InputStream inputStream) {
        try (PDDocument document = PDDocument.load(inputStream)) {
            PDFTextStripper stripper = new PDFTextStripper();
            return stripper.getText(document);
        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi khi đọc file PDF: " + e.getMessage();
        }
    }
}

