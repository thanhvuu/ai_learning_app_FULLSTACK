package com.vu.ai_learning_backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.net.URI; // Nhập công cụ URI vào
import java.util.List;
import java.util.Map;

@Service
public class AiService {

    @Value("${gemini.api.key}")
    private String apiKey;

    public String generateQuizJson(String pdfText) {
        String urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;
        String prompt = "Bạn là giáo viên ngoại ngữ. Dựa vào đoạn văn bản sau, hãy tạo 3 câu hỏi trắc nghiệm bằng tiếng Việt. " +
                "BẮT BUỘC TRẢ VỀ DUY NHẤT một mảng JSON (không có ký tự ```json ở đầu/cuối, không nói thêm lời nào khác). " +
                "Cấu trúc JSON yêu cầu: [{\"prompt\": \"Câu hỏi?\", \"options\": [\"A\", \"B\", \"C\", \"D\"], \"correctAnswer\": \"Đáp án đúng\", \"explanation\": \"Giải thích ngắn gọn\"}]\n\n" +
                "Văn bản cần đọc:\n" + pdfText;

        Map<String, Object> requestBody = Map.of(
                "contents", List.of(Map.of("parts", List.of(Map.of("text", prompt))))
        );

        try {
            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);

            // BÍ KÍP TRỊ LỖI 404: Ép thành đối tượng URI để giữ nguyên dấu hai chấm (:)
            URI uri = URI.create(urlString);

            // Gửi đi bằng 'uri' thay vì 'urlString'
            String rawResponse = restTemplate.postForObject(uri, request, String.class);

            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(rawResponse);
            String resultText = rootNode.path("candidates").get(0).path("content").path("parts").get(0).path("text").asText();

            return resultText.replace("```json\n", "").replace("```json", "").replace("```", "").trim();

        } catch (Exception e) {
            e.printStackTrace();
            return "[]";
        }
    }
}