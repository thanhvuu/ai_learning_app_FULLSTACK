package com.vu.ai_learning_backend.modules.learning.infrastructure.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LessonJpaRepository extends JpaRepository<LessonJpaEntity, Long> {
    Optional<LessonJpaEntity> findFirstByUsernameAndCategory(String username, String category);
    Optional<LessonJpaEntity> findFirstByCategory(String category);
    List<LessonJpaEntity> findByUsernameOrderByCreatedAtDesc(String username);
}

