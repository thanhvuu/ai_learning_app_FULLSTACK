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

    public String generateQuizJson(String pdfText, String quizType) {
        String urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;

        String basePrompt = "Bạn là một chuyên gia thiết kế bài giảng ngoại ngữ. Dựa vào nội dung tài liệu sau:\n\"\"\"" + pdfText + "\"\"\"\n\n";
        String taskPrompt = "";

        // CHIA NHÁNH THEO TỪNG TRÒ CHƠI
        if ("multiple_choice".equals(quizType)) {
            taskPrompt = "Hãy tạo 5 câu hỏi TRẮC NGHIỆM (A, B, C, D) bằng tiếng Anh.\n" +
                    "Yêu cầu cấu trúc JSON:\n" +
                    "- 'sentenceStart': chứa toàn bộ nội dung câu hỏi.\n" +
                    "- 'sentenceEnd': để chuỗi rỗng \"\".\n" +
                    "- 'optionA', 'optionB', 'optionC', 'optionD': chứa 4 đáp án.\n" +
                    "- 'correctAnswer': chứa đáp án đúng (phải trùng khớp chữ với 1 trong 4 option).\n" +
                    "- 'explanation': Giải thích cực kỳ ngắn gọn (bằng tiếng Việt) tại sao lại chọn đáp án này.";
        } else if ("fill_blank".equals(quizType)) {
            taskPrompt = "Hãy tạo 5 câu hỏi bài tập ĐỤC LỖ (Tự gõ đáp án).\n" +
                    "Yêu cầu:\n" +
                    "- Chọn 1 từ vựng quan trọng (Single word) làm đáp án.\n" +
                    "- 'sentenceStart': phần trước từ đó.\n" +
                    "- 'sentenceEnd': phần sau từ đó.\n" +
                    "- 'optionA', 'optionB', 'optionC', 'optionD': để trống \"\".\n" +
                    "- 'correctAnswer': từ khóa đúng (không phân biệt hoa thường).\n" +
                    "- 'explanation': Giải thích tại sao từ này lại đúng ngữ pháp/ngữ cảnh đó.";
        } else {
            // Mặc định là drag_drop (Kéo thả)
            taskPrompt = "Hãy tạo ra 5 câu hỏi bài tập dạng KÉO THẢ TỪ VỰNG.\n" +
                    "Yêu cầu cấu trúc JSON:\n" +
                    "- Cắt câu làm 2 phần: phần trước từ khóa (sentenceStart) và phần sau (sentenceEnd).\n" +
                    "- 'optionA', 'optionB', 'optionC', 'optionD': chứa 4 đáp án (1 đúng, 3 nhiễu).\n" +
                    "- 'correctAnswer': chứa đáp án đúng.\n" +
                    "- 'explanation': Giải thích cực kỳ ngắn gọn (bằng tiếng Việt) tại sao từ này lại phù hợp để điền vào chỗ trống.";
        }

        String finalPrompt = basePrompt + taskPrompt + "\n\nBẮT BUỘC TRẢ VỀ DUY NHẤT MỘT MẢNG JSON, tuyệt đối không có text thừa. Ví dụ:\n" +
                "[\n  {\n    \"sentenceStart\": \"...\",\n    \"sentenceEnd\": \"...\",\n    \"optionA\": \"...\",\n    \"optionB\": \"...\",\n    \"optionC\": \"...\",\n    \"optionD\": \"...\",\n    \"correctAnswer\": \"...\",\n    \"explanation\": \"...\"\n  }\n]";
        // ... (Giữ nguyên đoạn gửi request bằng RestTemplate và ObjectMapper ở dưới)
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
            return "[]";
        }
    }
}