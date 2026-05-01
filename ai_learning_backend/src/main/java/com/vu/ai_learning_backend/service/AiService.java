package com.vu.ai_learning_backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.util.List;
import java.util.Map;

@Service
public class AiService {

    @Value("${gemini.api.key}")
    private String apiKey;

    /**
     * Hàm cũ: Tạo câu hỏi từ text PDF
     */
    public String generateQuizJson(String pdfText, String quizType) {
        return callGemini(pdfText, quizType, null);
    }

    /**
     * Hàm mới: Tự tạo nội dung và câu hỏi theo chuyên ngành (Topic)
     */
    public String generateLessonByTopic(String topic, String quizType) {
        return callGemini(null, quizType, topic);
    }

    private String callGemini(String pdfText, String quizType, String topic) {
        String urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;

        String basePrompt = "";
        if (pdfText != null) {
            basePrompt = "Bạn là một chuyên gia thiết kế bài giảng ngoại ngữ. Dựa vào nội dung tài liệu sau:\n\"\"\"" + pdfText + "\"\"\"\n\n";
        } else {
            basePrompt = "Bạn là một chuyên gia thiết kế bài giảng ngoại ngữ. Hãy tự soạn một đoạn văn tiếng Anh chuyên ngành khoảng 150-200 chữ về chủ đề: \"" + topic + "\".\n" +
                    "Sau đó dựa vào chính đoạn văn đó để tạo câu hỏi.\n\n";
        }

        String taskPrompt = "";
        // CHIA NHÁNH THEO TỪNG TRÒ CHƠI
        if ("multiple_choice".equals(quizType)) {
            taskPrompt = "Hãy tạo 5 câu hỏi TRẮC NGHIỆM (A, B, C, D) bằng tiếng Anh.\n";
        } else if ("fill_blank".equals(quizType)) {
            taskPrompt = "Hãy tạo 5 câu hỏi bài tập ĐỤC LỖ (Tự gõ đáp án).\n";
        } else {
            taskPrompt = "Hãy tạo ra 5 câu hỏi bài tập dạng KÉO THẢ TỪ VỰNG.\n";
        }

        String jsonFormat = "Yêu cầu cấu trúc JSON trả về phải là một Object duy nhất chứa 3 phần:\n" +
                "1. 'content': Chứa đoạn văn bản tiếng Anh (đoạn văn gốc từ PDF hoặc đoạn văn bạn tự soạn).\n" +
                "2. 'vocabularies': Là một mảng gồm 5 từ vựng quan trọng nhất trong đoạn văn, mỗi Object có:\n" +
                "   - 'word': Từ vựng tiếng Anh.\n" +
                "   - 'phonetic': Phiên âm quốc tế (IPA).\n" +
                "   - 'meaning': Nghĩa tiếng Việt.\n" +
                "   - 'example': Một câu ví dụ tiếng Anh có chứa từ đó.\n" +
                "3. 'questions': Là một mảng gồm 5 Object câu hỏi, mỗi Object có các trường:\n" +
                "   - 'sentenceStart': Phần trước từ khóa.\n" +
                "   - 'sentenceEnd': Phần sau từ khóa.\n" +
                "   - 'optionA', 'optionB', 'optionC', 'optionD': 4 lựa chọn.\n" +
                "   - 'correctAnswer': Đáp án đúng.\n" +
                "   - 'explanation': Giải thích ngắn gọn bằng tiếng Việt.\n\n" +
                "BẮT BUỘC TRẢ VỀ DUY NHẤT JSON theo định dạng này:\n" +
                "{\n" +
                "  \"content\": \"...\",\n" +
                "  \"vocabularies\": [ ... ],\n" +
                "  \"questions\": [ ... ]\n" +
                "}";

        String finalPrompt = basePrompt + taskPrompt + jsonFormat;

        Map<String, Object> requestBody = Map.of("contents", List.of(Map.of("parts", List.of(Map.of("text", finalPrompt)))));
        try {
            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);
            URI uri = URI.create(urlString);
            String rawResponse = restTemplate.postForObject(uri, request, String.class);

            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(rawResponse);
            String resultText = rootNode.path("candidates").get(0).path("content").path("parts").get(0).path("text").asText();
            return resultText.replace("```json\n", "").replace("```json", "").replace("```", "").trim();
        } catch (Exception e) {
            e.printStackTrace();
            return "{\"content\": \"\", \"vocabularies\": [], \"questions\": []}";
        }
    }
}