package com.vu.ai_learning_backend.modules.gamification.infrastructure.persistence;

import com.vu.ai_learning_backend.modules.gamification.domain.model.DailyProgress;
import com.vu.ai_learning_backend.modules.gamification.domain.repository.DailyProgressRepositoryPort;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.Optional;

@Component
public class DailyProgressJpaAdapter implements DailyProgressRepositoryPort {

    private final DailyProgressJpaRepository jpaRepository;

    public DailyProgressJpaAdapter(DailyProgressJpaRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }

    @Override
    public DailyProgress save(DailyProgress domain) {
        DailyProgressJpaEntity entity = toEntity(domain);
        DailyProgressJpaEntity saved = jpaRepository.save(entity);
        return toDomain(saved);
    }

    @Override
    public Optional<DailyProgress> findByUsernameAndStudyDate(String username, LocalDate studyDate) {
        return jpaRepository.findByUsernameAndStudyDate(username, studyDate).map(this::toDomain);
    }

    @Override
    public Optional<DailyProgress> findTopByUsernameOrderByStudyDateDesc(String username) {
        return jpaRepository.findTopByUsernameOrderByStudyDateDesc(username).map(this::toDomain);
    }

    private DailyProgress toDomain(DailyProgressJpaEntity entity) {
        if (entity == null) return null;
        return DailyProgress.builder()
                .id(entity.getId())
                .username(entity.getUsername())
                .studyDate(entity.getStudyDate())
                .minutesLearned(entity.getMinutesLearned())
                .dailyGoal(entity.getDailyGoal())
                .isGoalAchieved(entity.isGoalAchieved())
                .streakCount(entity.getStreakCount())
                .build();
    }

    private DailyProgressJpaEntity toEntity(DailyProgress domain) {
        if (domain == null) return null;
        return DailyProgressJpaEntity.builder()
                .id(domain.getId())
                .username(domain.getUsername())
                .studyDate(domain.getStudyDate())
                .minutesLearned(domain.getMinutesLearned())
                .dailyGoal(domain.getDailyGoal())
                .isGoalAchieved(domain.isGoalAchieved())
                .streakCount(domain.getStreakCount())
                .build();
    }
}

