package com.vu.ai_learning_backend.modules.learning.infrastructure.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VocabularyJpaRepository extends JpaRepository<VocabularyJpaEntity, Long> {
}

