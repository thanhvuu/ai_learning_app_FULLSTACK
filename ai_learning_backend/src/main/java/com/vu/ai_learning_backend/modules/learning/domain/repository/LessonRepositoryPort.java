package com.vu.ai_learning_backend.modules.learning.domain.repository;

import com.vu.ai_learning_backend.modules.learning.domain.model.Lesson;

import java.util.List;
import java.util.Optional;

public interface LessonRepositoryPort {
    Lesson save(Lesson lesson);
    Optional<Lesson> findById(Long id);
    Optional<Lesson> findFirstByUsernameAndCategory(String username, String category);
    Optional<Lesson> findFirstByCategory(String category);
    List<Lesson> findByUsernameOrderByCreatedAtDesc(String username);
}

