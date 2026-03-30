package com.vu.ai_learning_backend.service;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.InputStream;

@Service // Gắn mác đây là Chuyên viên xử lý logic
public class PdfService {

    public String extractText(MultipartFile file) {
        // Mở file và bóc tách chữ
        try (InputStream inputStream = file.getInputStream();
             PDDocument document = PDDocument.load(inputStream)) {

            PDFTextStripper stripper = new PDFTextStripper();
            String text = stripper.getText(document);

            return text; // Trả về toàn bộ đống chữ đọc được

        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi khi đọc file PDF: " + e.getMessage();
        }
    }
}