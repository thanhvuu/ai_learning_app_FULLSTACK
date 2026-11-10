package com.vu.ai_learning_backend.modules.learning.application.usecase;

import com.vu.ai_learning_backend.modules.learning.domain.repository.LessonRepositoryPort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PreGenerateBatchLessonsUseCase {

    private final LessonRepositoryPort lessonRepositoryPort;
    private final GenerateLessonByTopicUseCase generateLessonByTopicUseCase;

    public PreGenerateBatchLessonsUseCase(LessonRepositoryPort lessonRepositoryPort,
                                          GenerateLessonByTopicUseCase generateLessonByTopicUseCase) {
        this.lessonRepositoryPort = lessonRepositoryPort;
        this.generateLessonByTopicUseCase = generateLessonByTopicUseCase;
    }

    public int execute() {
        List<String> popularTopics = List.of(
                "Frontend Basics",
                "ReactJS Advanced",
                "Database SQL",
                "UI/UX Principles",
                "Docker for Beginners"
        );

        int count = 0;
        for (String topic : popularTopics) {
            try {
                if (lessonRepositoryPort.findFirstByCategory(topic).isPresent()) {
                    System.out.println("--- Admin: Bỏ qua (Đã có sẵn): " + topic + " ---");
                    continue;
                }

                System.out.println("--- Admin: Đang tạo trước dữ liệu cho: " + topic + " ---");
                generateLessonByTopicUseCase.execute(topic, "drag_drop", "system_admin", topic);
                count++;

                // Nghỉ 5 giây để tránh bị giới hạn API Rate Limit của Gemini
                Thread.sleep(5000);
            } catch (Exception e) {
                System.err.println("--- Admin: Lỗi khi tạo topic " + topic + ": " + e.getMessage());
            }
        }
        return count;
    }
}

