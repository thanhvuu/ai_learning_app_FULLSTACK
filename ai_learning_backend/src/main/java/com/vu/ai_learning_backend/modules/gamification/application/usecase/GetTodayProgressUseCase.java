package com.vu.ai_learning_backend.modules.gamification.application.usecase;

import com.vu.ai_learning_backend.modules.gamification.domain.model.DailyProgress;
import com.vu.ai_learning_backend.modules.gamification.domain.repository.DailyProgressRepositoryPort;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Service
public class GetTodayProgressUseCase {

    private final DailyProgressRepositoryPort progressRepository;

    public GetTodayProgressUseCase(DailyProgressRepositoryPort progressRepository) {
        this.progressRepository = progressRepository;
    }

    public DailyProgress execute(String username) {
        LocalDate today = LocalDate.now();
        return progressRepository.findByUsernameAndStudyDate(username, today)
                .orElseGet(() -> {
                    DailyProgress empty = DailyProgress.builder()
                            .username(username)
                            .studyDate(today)
                            .minutesLearned(0)
                            .dailyGoal(45)
                            .isGoalAchieved(false)
                            .streakCount(0)
                            .build();

                    progressRepository.findTopByUsernameOrderByStudyDateDesc(username)
                            .ifPresent(last -> {
                                if (last.getStudyDate() != null) {
                                    long daysBetween = ChronoUnit.DAYS.between(last.getStudyDate(), today);
                                    empty.setStreakCount(daysBetween > 1 ? 0 : last.getStreakCount());
                                }
                            });
                    return empty;
                });
    }
}

