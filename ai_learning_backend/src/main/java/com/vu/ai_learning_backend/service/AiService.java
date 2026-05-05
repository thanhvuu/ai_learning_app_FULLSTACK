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
     * Hàm cũ: Tự tạo nội dung và câu hỏi theo chuyên ngành (Topic)
     */
    public String generateLessonByTopic(String topic, String quizType) {
        // --- KIỂM TRA BÀI HỌC CÓ SẴN (PRE-BUILT) ĐỂ TĂNG TỐC ---
        if ("Introduction to IT".equals(topic)) {
            return getPreBuiltITLesson();
        } else if ("Business Basics".equals(topic)) {
            return getPreBuiltBusinessLesson();
        } else if ("Medical Terminology".equals(topic)) {
            return getPreBuiltMedicalLesson();
        } else if ("At the Airport".equals(topic)) {
            return getPreBuiltTravelLesson();
        } else if ("Greetings & Introductions".equals(topic)) {
            return getPreBuiltDailyLesson();
        }
        
        // Nếu không có sẵn, mới gọi AI
        return callGemini(null, quizType, topic);
    }

    private String getPreBuiltMedicalLesson() {
        return "{\n" +
                "  \"content\": \"Medical terminology is the language used by healthcare professionals to describe the human body and associated conditions. Most terms are derived from Latin or Greek and follow a logical structure of prefix, root, and suffix. Understanding these terms is crucial for accurate patient diagnosis and treatment.\",\n" +
                "  \"vocabularies\": [\n" +
                "    {\"word\": \"Diagnosis\", \"phonetic\": \"/ˌdaɪ.əɡˈnoʊ.sɪs/\", \"meaning\": \"Chẩn đoán\", \"example\": \"The doctor is waiting for the final diagnosis.\"}, \n" +
                "    {\"word\": \"Anatomy\", \"phonetic\": \"/əˈnæt.ə.mi/\", \"meaning\": \"Giải phẫu học\", \"example\": \"Students study anatomy to learn about the human body.\"}, \n" +
                "    {\"word\": \"Treatment\", \"phonetic\": \"/ˈtriːt.mənt/\", \"meaning\": \"Điều trị\", \"example\": \"She is responding well to the medical treatment.\"}, \n" +
                "    {\"word\": \"Pharmacology\", \"phonetic\": \"/ˌfɑːr.məˈkɑː.lə.dʒi/\", \"meaning\": \"Dược lý học\", \"example\": \"Nurses must have a strong knowledge of pharmacology.\"}, \n" +
                "    {\"word\": \"Symptom\", \"phonetic\": \"/ˈsɪmp.təm/\", \"meaning\": \"Triệu chứng\", \"example\": \"Fever is a common symptom of many infections.\"}\n" +
                "  ],\n" +
                "  \"questions\": [\n" +
                "    {\"sentenceStart\": \"The doctor made a \", \"sentenceEnd\": \" after examining the patient.\", \"optionA\": \"Diagnosis\", \"optionB\": \"Symptom\", \"optionC\": \"Treatment\", \"optionD\": \"Anatomy\", \"correctAnswer\": \"A\", \"explanation\": \"Diagnosis là việc chẩn đoán bệnh sau khi thăm khám.\"}, \n" +
                "    {\"sentenceStart\": \"\", \"sentenceEnd\": \" is the study of how drugs interact with the body.\", \"optionA\": \"Anatomy\", \"optionB\": \"Pharmacology\", \"optionC\": \"Symptom\", \"optionD\": \"Diagnosis\", \"correctAnswer\": \"B\", \"explanation\": \"Pharmacology là môn nghiên cứu về tương tác của thuốc.\"}, \n" +
                "    {\"sentenceStart\": \"A headache is a \", \"sentenceEnd\": \" of stress.\", \"optionA\": \"Diagnosis\", \"optionB\": \"Treatment\", \"optionC\": \"Symptom\", \"optionD\": \"Anatomy\", \"correctAnswer\": \"C\", \"explanation\": \"Symptom là triệu chứng của một tình trạng nào đó.\"}, \n" +
                "    {\"sentenceStart\": \"Modern \", \"sentenceEnd\": \" can cure many previously fatal diseases.\", \"optionA\": \"Anatomy\", \"optionB\": \"Symptom\", \"optionC\": \"Diagnosis\", \"optionD\": \"Treatment\", \"correctAnswer\": \"D\", \"explanation\": \"Treatment (điều trị) hiện đại có thể chữa nhiều bệnh.\"}, \n" +
                "    {\"sentenceStart\": \"To perform surgery, one must understand human \", \"sentenceEnd\": \".\", \"optionA\": \"Anatomy\", \"optionB\": \"Diagnosis\", \"optionC\": \"Symptom\", \"optionD\": \"Treatment\", \"correctAnswer\": \"A\", \"explanation\": \"Phẫu thuật đòi hỏi kiến thức về giải phẫu học (Anatomy).\"}\n" +
                "  ]\n" +
                "}";
    }

    private String getPreBuiltTravelLesson() {
        return "{\n" +
                "  \"content\": \"Traveling by air involves several steps, from arriving at the airport to boarding the plane. Passengers must check in their luggage, pass through security screening, and find their departure gate. Knowing common airport vocabulary helps ensure a smooth travel experience.\",\n" +
                "  \"vocabularies\": [\n" +
                "    {\"word\": \"Departure\", \"phonetic\": \"/dɪˈpɑːr.tʃər/\", \"meaning\": \"Khởi hành\", \"example\": \"The departure board shows all outgoing flights.\"}, \n" +
                "    {\"word\": \"Boarding\", \"phonetic\": \"/ˈbɔːr.dɪŋ/\", \"meaning\": \"Lên máy bay\", \"example\": \"Boarding will begin at gate number five.\"}, \n" +
                "    {\"word\": \"Luggage\", \"phonetic\": \"/ˈlʌɡ.ɪdʒ/\", \"meaning\": \"Hành lý\", \"example\": \"Please keep your luggage with you at all times.\"}, \n" +
                "    {\"word\": \"Security\", \"phonetic\": \"/səˈkjʊr.ə.ti/\", \"meaning\": \"An ninh\", \"example\": \"You must remove your shoes at the security checkpoint.\"}, \n" +
                "    {\"word\": \"Passport\", \"phonetic\": \"/ˈpæs.pɔːrt/\", \"meaning\": \"Hộ chiếu\", \"example\": \"Don't forget to bring your passport to the airport.\"}\n" +
                "  ],\n" +
                "  \"questions\": [\n" +
                "    {\"sentenceStart\": \"You need to show your \", \"sentenceEnd\": \" at the immigration desk.\", \"optionA\": \"Luggage\", \"optionB\": \"Passport\", \"optionC\": \"Security\", \"optionD\": \"Departure\", \"correctAnswer\": \"B\", \"explanation\": \"Bạn cần trình hộ chiếu (Passport) tại bàn nhập cảnh.\"}, \n" +
                "    {\"sentenceStart\": \"The \", \"sentenceEnd\": \" gate is located at the end of the hall.\", \"optionA\": \"Boarding\", \"optionB\": \"Security\", \"optionC\": \"Luggage\", \"optionD\": \"Passport\", \"correctAnswer\": \"A\", \"explanation\": \"Cổng lên máy bay (Boarding gate) nằm ở cuối sảnh.\"}, \n" +
                "    {\"sentenceStart\": \"Please check the \", \"sentenceEnd\": \" time of your flight.\", \"optionA\": \"Passport\", \"optionB\": \"Security\", \"optionC\": \"Departure\", \"optionD\": \"Luggage\", \"correctAnswer\": \"C\", \"explanation\": \"Hãy kiểm tra giờ khởi hành (Departure) của chuyến bay.\"}, \n" +
                "    {\"sentenceStart\": \"All \", \"sentenceEnd\": \" must be scanned before entry.\", \"optionA\": \"Departure\", \"optionB\": \"Passport\", \"optionC\": \"Luggage\", \"optionD\": \"Boarding\", \"correctAnswer\": \"C\", \"explanation\": \"Tất cả hành lý (Luggage) phải được quét qua máy.\"}, \n" +
                "    {\"sentenceStart\": \"The \", \"sentenceEnd\": \" officer asked for my identification.\", \"optionA\": \"Departure\", \"optionB\": \"Security\", \"optionC\": \"Boarding\", \"optionD\": \"Passport\", \"correctAnswer\": \"B\", \"explanation\": \"Nhân viên an ninh (Security officer) yêu cầu kiểm tra giấy tờ.\"}\n" +
                "  ]\n" +
                "}";
    }

    private String getPreBuiltDailyLesson() {
        return "{\n" +
                "  \"content\": \"Basic greetings and introductions are the foundation of any conversation. When meeting someone for the first time, it's common to say 'Hello' or 'Nice to meet you'. Introducing yourself and asking simple questions helps build new relationships and friendships.\",\n" +
                "  \"vocabularies\": [\n" +
                "    {\"word\": \"Greeting\", \"phonetic\": \"/ˈɡriː.tɪŋ/\", \"meaning\": \"Lời chào\", \"example\": \"A warm greeting makes everyone feel welcome.\"}, \n" +
                "    {\"word\": \"Introduction\", \"phonetic\": \"/ˌɪn.trəˈdʌk.ʃən/\", \"meaning\": \"Giới thiệu\", \"example\": \"Let's start with a round of introductions.\"}, \n" +
                "    {\"word\": \"Friendship\", \"phonetic\": \"/ˈfrend.ʃɪp/\", \"meaning\": \"Tình bạn\", \"example\": \"They have a very strong friendship.\"}, \n" +
                "    {\"word\": \"Conversation\", \"phonetic\": \"/ˌkɑːn.vəˈseɪ.ʃən/\", \"meaning\": \"Cuộc hội thoại\", \"example\": \"The conversation lasted for over an hour.\"}, \n" +
                "    {\"word\": \"Relationship\", \"phonetic\": \"/rɪˈleɪ.ʃən.ʃɪp/\", \"meaning\": \"Mối quan hệ\", \"example\": \"Honesty is key to a good relationship.\"}\n" +
                "  ],\n" +
                "  \"questions\": [\n" +
                "    {\"sentenceStart\": \"A simple 'Hi' is a common \", \"sentenceEnd\": \" in English.\", \"optionA\": \"Conversation\", \"optionB\": \"Greeting\", \"optionC\": \"Introduction\", \"optionD\": \"Relationship\", \"correctAnswer\": \"B\", \"explanation\": \"'Hi' là một lời chào (Greeting) phổ biến.\"}, \n" +
                "    {\"sentenceStart\": \"\", \"sentenceEnd\": \" yourself is the first step to making friends.\", \"optionA\": \"Introducing\", \"optionB\": \"Greeting\", \"optionC\": \"Friendship\", \"optionD\": \"Conversation\", \"correctAnswer\": \"A\", \"explanation\": \"Giới thiệu bản thân là bước đầu để kết bạn.\"}, \n" +
                "    {\"sentenceStart\": \"We had an interesting \", \"sentenceEnd\": \" about music.\", \"optionA\": \"Greeting\", \"optionB\": \"Friendship\", \"optionC\": \"Conversation\", \"optionD\": \"Introduction\", \"correctAnswer\": \"C\", \"explanation\": \"Chúng tôi đã có một cuộc hội thoại (Conversation) về âm nhạc.\"}, \n" +
                "    {\"sentenceStart\": \"Trust is important for a long-lasting \", \"sentenceEnd\": \".\", \"optionA\": \"Greeting\", \"optionB\": \"Introduction\", \"optionC\": \"Friendship\", \"optionD\": \"Conversation\", \"correctAnswer\": \"C\", \"explanation\": \"Sự tin tưởng quan trọng cho một tình bạn (Friendship) bền lâu.\"}, \n" +
                "    {\"sentenceStart\": \"How is your \", \"sentenceEnd\": \" with your new neighbor?\", \"optionA\": \"Greeting\", \"optionB\": \"Introduction\", \"optionC\": \"Relationship\", \"optionD\": \"Conversation\", \"correctAnswer\": \"C\", \"explanation\": \"Mối quan hệ (Relationship) của bạn với hàng xóm thế nào?\"}\n" +
                "  ]\n" +
                "}";
    }

    private String getPreBuiltITLesson() {
        return "{\n" +
                "  \"content\": \"Information Technology (IT) is the use of computers to store, retrieve, transmit, and manipulate data. It is a broad field that covers everything from computer hardware and software to networking and cybersecurity. In today's digital world, IT is essential for businesses and individuals alike.\",\n" +
                "  \"vocabularies\": [\n" +
                "    {\"word\": \"Hardware\", \"phonetic\": \"/ˈhɑːrd.wer/\", \"meaning\": \"Phần cứng\", \"example\": \"The computer hardware needs to be upgraded.\"}, \n" +
                "    {\"word\": \"Software\", \"phonetic\": \"/ˈsɔːft.wer/\", \"meaning\": \"Phần mềm\", \"example\": \"I installed new software on my laptop.\"}, \n" +
                "    {\"word\": \"Networking\", \"phonetic\": \"/ˈnet.wɜːr.kɪŋ/\", \"meaning\": \"Kết nối mạng\", \"example\": \"Networking allows computers to communicate with each other.\"}, \n" +
                "    {\"word\": \"Cybersecurity\", \"phonetic\": \"/ˈsaɪ.bər.sɪˌkjʊr.ə.ti/\", \"meaning\": \"An ninh mạng\", \"example\": \"Cybersecurity is important for protecting data.\"}, \n" +
                "    {\"word\": \"Data\", \"phonetic\": \"/ˈdeɪ.tə/\", \"meaning\": \"Dữ liệu\", \"example\": \"The company collects a lot of data about its customers.\"}\n" +
                "  ],\n" +
                "  \"questions\": [\n" +
                "    {\"sentenceStart\": \"Computer \", \"sentenceEnd\": \" includes the physical parts of a computer.\", \"optionA\": \"Software\", \"optionB\": \"Hardware\", \"optionC\": \"Data\", \"optionD\": \"Networking\", \"correctAnswer\": \"B\", \"explanation\": \"Hardware là các thành phần vật lý của máy tính.\"}, \n" +
                "    {\"sentenceStart\": \"\", \"sentenceEnd\": \" refers to programs and instructions for the computer.\", \"optionA\": \"Hardware\", \"optionB\": \"Data\", \"optionC\": \"Software\", \"optionD\": \"Networking\", \"correctAnswer\": \"C\", \"explanation\": \"Software là các chương trình và chỉ dẫn cho máy tính.\"}, \n" +
                "    {\"sentenceStart\": \"\", \"sentenceEnd\": \" is used to connect computers together.\", \"optionA\": \"Hardware\", \"optionB\": \"Networking\", \"optionC\": \"Software\", \"optionD\": \"Data\", \"correctAnswer\": \"B\", \"explanation\": \"Networking được dùng để kết nối các máy tính với nhau.\"}, \n" +
                "    {\"sentenceStart\": \"Protecting information from online threats is called \", \"sentenceEnd\": \".\", \"optionA\": \"Hardware\", \"optionB\": \"Data\", \"optionC\": \"Software\", \"optionD\": \"Cybersecurity\", \"correctAnswer\": \"D\", \"explanation\": \"Cybersecurity là bảo vệ thông tin khỏi các mối đe dọa trực tuyến.\"}, \n" +
                "    {\"sentenceStart\": \"The computer processes \", \"sentenceEnd\": \" to give information.\", \"optionA\": \"Software\", \"optionB\": \"Hardware\", \"optionC\": \"Data\", \"optionD\": \"Networking\", \"correctAnswer\": \"C\", \"explanation\": \"Máy tính xử lý dữ liệu (Data) để đưa ra thông tin.\"}\n" +
                "  ]\n" +
                "}";
    }

    private String getPreBuiltBusinessLesson() {
        return "{\n" +
                "  \"content\": \"Business is the activity of making, buying, or selling goods or providing services in exchange for money. Every business aims to be profitable while meeting the needs of its customers. Key areas include marketing, finance, and management.\",\n" +
                "  \"vocabularies\": [\n" +
                "    {\"word\": \"Profitable\", \"phonetic\": \"/ˈprɑː.fɪ.tə.bəl/\", \"meaning\": \"Có lợi nhuận\", \"example\": \"The company has been profitable for five years.\"}, \n" +
                "    {\"word\": \"Marketing\", \"phonetic\": \"/ˈmɑːr.kɪ.tɪŋ/\", \"meaning\": \"Tiếp thị\", \"example\": \"Effective marketing is key to success.\"}, \n" +
                "    {\"word\": \"Finance\", \"phonetic\": \"/ˈfaɪ.næns/\", \"meaning\": \"Tài chính\", \"example\": \"He works in the finance department.\"}, \n" +
                "    {\"word\": \"Management\", \"phonetic\": \"/ˈmæn.ɪdʒ.mənt/\", \"meaning\": \"Quản lý\", \"example\": \"The management team is very experienced.\"}, \n" +
                "    {\"word\": \"Customer\", \"phonetic\": \"/ˈkʌs.tə.mər/\", \"meaning\": \"Khách hàng\", \"example\": \"The customer is always right.\"}\n" +
                "  ],\n" +
                "  \"questions\": [\n" +
                "    {\"sentenceStart\": \"A \", \"sentenceEnd\": \" business earns more money than it spends.\", \"optionA\": \"Marketing\", \"optionB\": \"Finance\", \"optionC\": \"Profitable\", \"optionD\": \"Management\", \"correctAnswer\": \"C\", \"explanation\": \"Một doanh nghiệp có lợi nhuận (Profitable) kiếm được nhiều tiền hơn số tiền chi tiêu.\"}, \n" +
                "    {\"sentenceStart\": \"\", \"sentenceEnd\": \" involves promoting and selling products.\", \"optionA\": \"Finance\", \"optionB\": \"Management\", \"optionC\": \"Customer\", \"optionD\": \"Marketing\", \"correctAnswer\": \"D\", \"explanation\": \"Marketing bao gồm việc quảng bá và bán sản phẩm.\"}, \n" +
                "    {\"sentenceStart\": \"The study of money and investments is called \", \"sentenceEnd\": \".\", \"optionA\": \"Marketing\", \"optionB\": \"Finance\", \"optionC\": \"Management\", \"optionD\": \"Customer\", \"correctAnswer\": \"B\", \"explanation\": \"Việc nghiên cứu về tiền bạc và đầu tư được gọi là Tài chính (Finance).\"}, \n" +
                "    {\"sentenceStart\": \"Good \", \"sentenceEnd\": \" helps the company run smoothly.\", \"optionA\": \"Management\", \"optionB\": \"Finance\", \"optionC\": \"Customer\", \"optionD\": \"Marketing\", \"correctAnswer\": \"A\", \"explanation\": \"Quản lý (Management) tốt giúp công ty vận hành trơn tru.\"}, \n" +
                "    {\"sentenceStart\": \"Every business needs a \", \"sentenceEnd\": \" to buy its goods.\", \"optionA\": \"Management\", \"optionB\": \"Finance\", \"optionC\": \"Marketing\", \"optionD\": \"Customer\", \"correctAnswer\": \"D\", \"explanation\": \"Mọi doanh nghiệp đều cần khách hàng (Customer) để mua hàng hóa của mình.\"}\n" +
                "  ]\n" +
                "}";
    }

    private String callGemini(String pdfText, String quizType, String topic) {
        String urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;

        System.out.println("--- Đang gọi Gemini AI cho: " + (topic != null ? topic : "PDF Content") + " ---");

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
            org.springframework.http.client.SimpleClientHttpRequestFactory factory = new org.springframework.http.client.SimpleClientHttpRequestFactory();
            factory.setConnectTimeout(30000); // 30 giây
            factory.setReadTimeout(60000);    // 60 giây

            RestTemplate restTemplate = new RestTemplate(factory);
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);
            URI uri = URI.create(urlString);
            String rawResponse = restTemplate.postForObject(uri, request, String.class);

            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(rawResponse);
            String resultText = rootNode.path("candidates").get(0).path("content").path("parts").get(0).path("text").asText();
            System.out.println("--- Nhận phản hồi từ Gemini thành công ---");
            return resultText.replace("```json\n", "").replace("```json", "").replace("```", "").trim();
        } catch (Exception e) {
            System.err.println("Lỗi khi gọi Gemini AI: " + e.getMessage());
            e.printStackTrace();
            return "{\"content\": \"\", \"vocabularies\": [], \"questions\": []}";
        }
    }

    // =========================================================================
    // HÀM MỚI BỔ SUNG: TRA CỨU TỪ ĐIỂN VỚI AI (Mô phỏng TFlat)
    // =========================================================================
    public String lookupDictionary(String word) {
        String urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;

        System.out.println("--- Đang tra từ điển AI: " + word + " ---");

        String prompt = "Hãy đóng vai một từ điển tiếng Anh - tiếng Việt chuyên nghiệp. " +
                "Tôi sẽ đưa cho bạn một từ hoặc cụm từ: '" + word + "'. " +
                "Nhiệm vụ của bạn là CHỈ TRẢ VỀ ĐÚNG MỘT ĐỐI TƯỢNG JSON ĐƠN NHẤT theo cấu trúc dưới đây. " +
                "TUYỆT ĐỐI KHÔNG giải thích, KHÔNG nói thêm bất cứ câu chữ nào bên ngoài JSON, KHÔNG dùng thẻ markdown.\n\n" +
                "{\n" +
                "  \"word\": \"(từ tiếng Anh đó)\",\n" +
                "  \"phonetic\": \"(phiên âm quốc tế IPA)\",\n" +
                "  \"partOfSpeech\": \"(Loại từ: Danh từ, Động từ, Tính từ...)\",\n" +
                "  \"meaning\": \"(Nghĩa tiếng Việt ngắn gọn, dễ hiểu)\",\n" +
                "  \"synonyms\": [\"(từ đồng nghĩa 1)\", \"(từ đồng nghĩa 2)\", \"(từ đồng nghĩa 3)\"],\n" +
                "  \"antonyms\": [\"(từ trái nghĩa 1)\", \"(từ trái nghĩa 2)\"],\n" +
                "  \"examples\": [\n" +
                "    {\"en\": \"(Câu ví dụ tiếng Anh 1)\", \"vn\": \"(Nghĩa tiếng Việt của câu 1)\"},\n" +
                "    {\"en\": \"(Câu ví dụ tiếng Anh 2)\", \"vn\": \"(Nghĩa tiếng Việt của câu 2)\"}\n" +
                "  ]\n" +
                "}";

        Map<String, Object> requestBody = Map.of("contents", List.of(Map.of("parts", List.of(Map.of("text", prompt)))));

        try {
            org.springframework.http.client.SimpleClientHttpRequestFactory factory = new org.springframework.http.client.SimpleClientHttpRequestFactory();
            factory.setConnectTimeout(20000); // 20 giây
            factory.setReadTimeout(30000);    // 30 giây

            RestTemplate restTemplate = new RestTemplate(factory);
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);
            URI uri = URI.create(urlString);
            String rawResponse = restTemplate.postForObject(uri, request, String.class);

            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(rawResponse);
            String resultText = rootNode.path("candidates").get(0).path("content").path("parts").get(0).path("text").asText();

            System.out.println("--- Tra từ điển thành công ---");
            // Dọn dẹp chuỗi JSON đề phòng Gemini tự thêm ký hiệu markdown (```json ... ```)
            return resultText.replace("```json\n", "").replace("```json", "").replace("```", "").trim();
        } catch (Exception e) {
            System.err.println("Lỗi tra từ điển AI: " + e.getMessage());
            e.printStackTrace();
            // Nếu lỗi, trả về JSON rỗng để App Flutter không bị crash
            return "{\"word\": \"" + word + "\", \"phonetic\": \"\", \"partOfSpeech\": \"\", \"meaning\": \"Không tìm thấy từ này hoặc lỗi server.\", \"synonyms\": [], \"antonyms\": [], \"examples\": []}";
        }
    }
}