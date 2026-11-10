package com.vu.ai_learning_backend.modules.gamification.infrastructure.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface DailyProgressJpaRepository extends JpaRepository<DailyProgressJpaEntity, Long> {
    Optional<DailyProgressJpaEntity> findByUsernameAndStudyDate(String username, LocalDate studyDate);
    Optional<DailyProgressJpaEntity> findTopByUsernameOrderByStudyDateDesc(String username);
}

