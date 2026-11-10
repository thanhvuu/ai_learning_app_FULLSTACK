package com.vu.ai_learning_backend.modules.gamification.application.usecase;

import com.vu.ai_learning_backend.modules.gamification.domain.model.DailyProgress;
import com.vu.ai_learning_backend.modules.gamification.domain.repository.DailyProgressRepositoryPort;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Optional;

@Service
public class RecordStudyTimeUseCase {

    private final DailyProgressRepositoryPort progressRepository;

    public RecordStudyTimeUseCase(DailyProgressRepositoryPort progressRepository) {
        this.progressRepository = progressRepository;
    }

    public DailyProgress execute(String username, int minutesToAdd) {
        LocalDate today = LocalDate.now();

        Optional<DailyProgress> todayProgressOpt = progressRepository.findByUsernameAndStudyDate(username, today);
        DailyProgress todayProgress;

        if (todayProgressOpt.isPresent()) {
            todayProgress = todayProgressOpt.get();
            todayProgress.addMinutes(minutesToAdd);
        } else {
            todayProgress = DailyProgress.builder()
                    .username(username)
                    .studyDate(today)
                    .minutesLearned(0)
                    .dailyGoal(45)
                    .isGoalAchieved(false)
                    .build();

            // Tính toán Streak từ lần học trước
            Optional<DailyProgress> lastProgressOpt = progressRepository.findTopByUsernameOrderByStudyDateDesc(username);
            todayProgress.calculateInitialStreak(lastProgressOpt.orElse(null), today);

            // Cộng dồn phút học và kiểm tra mục tiêu ngày
            todayProgress.addMinutes(minutesToAdd);
        }

        return progressRepository.save(todayProgress);
    }
}

