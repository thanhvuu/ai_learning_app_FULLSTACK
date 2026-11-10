package com.vu.ai_learning_backend.modules.learning.application.usecase;

import com.vu.ai_learning_backend.common.exception.ResourceNotFoundException;
import com.vu.ai_learning_backend.modules.learning.application.port.EventPublisherPort;
import com.vu.ai_learning_backend.modules.learning.domain.event.LessonCompletedEvent;
import com.vu.ai_learning_backend.modules.learning.domain.model.Lesson;
import com.vu.ai_learning_backend.modules.learning.domain.repository.LessonRepositoryPort;
import org.springframework.stereotype.Service;

@Service
public class UpdateLessonProgressUseCase {

    private final LessonRepositoryPort lessonRepositoryPort;
    private final EventPublisherPort eventPublisherPort;

    public UpdateLessonProgressUseCase(LessonRepositoryPort lessonRepositoryPort,
                                       EventPublisherPort eventPublisherPort) {
        this.lessonRepositoryPort = lessonRepositoryPort;
        this.eventPublisherPort = eventPublisherPort;
    }

    public Lesson execute(Long lessonId, int progress) {
        Lesson lesson = lessonRepositoryPort.findById(lessonId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy bài học có ID: " + lessonId));

        lesson.updateProgress(progress);
        Lesson saved = lessonRepositoryPort.save(lesson);

        // Nếu bài học đã hoàn thành 100%, bắn sự kiện cho module Gamification
        if (saved.isFinished() && saved.getUsername() != null) {
            eventPublisherPort.publish(new LessonCompletedEvent(saved.getUsername(), saved.getId(), saved.getProgress()));
        }

        return saved;
    }
}

