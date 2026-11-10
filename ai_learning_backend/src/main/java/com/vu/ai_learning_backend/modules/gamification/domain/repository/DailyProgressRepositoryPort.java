package com.vu.ai_learning_backend.modules.gamification.domain.repository;

import com.vu.ai_learning_backend.modules.gamification.domain.model.DailyProgress;

import java.time.LocalDate;
import java.util.Optional;

public interface DailyProgressRepositoryPort {
    DailyProgress save(DailyProgress dailyProgress);
    Optional<DailyProgress> findByUsernameAndStudyDate(String username, LocalDate studyDate);
    Optional<DailyProgress> findTopByUsernameOrderByStudyDateDesc(String username);
}

