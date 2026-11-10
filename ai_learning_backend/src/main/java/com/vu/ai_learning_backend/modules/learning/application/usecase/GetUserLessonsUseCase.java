package com.vu.ai_learning_backend.modules.learning.application.usecase;

import com.vu.ai_learning_backend.modules.learning.domain.model.Lesson;
import com.vu.ai_learning_backend.modules.learning.domain.repository.LessonRepositoryPort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GetUserLessonsUseCase {

    private final LessonRepositoryPort lessonRepositoryPort;

    public GetUserLessonsUseCase(LessonRepositoryPort lessonRepositoryPort) {
        this.lessonRepositoryPort = lessonRepositoryPort;
    }

    public List<Lesson> execute(String username) {
        return lessonRepositoryPort.findByUsernameOrderByCreatedAtDesc(username);
    }
}

