package com.vu.ai_learning_backend.modules.gamification.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyProgress {
    private Long id;
    private String username;
    private LocalDate studyDate;
    @Builder.Default
    private int minutesLearned = 0;
    @Builder.Default
    private int dailyGoal = 45;
    @Builder.Default
    private boolean isGoalAchieved = false;
    private int streakCount;

    public void addMinutes(int minutes) {
        this.minutesLearned += minutes;
        if (this.minutesLearned >= this.dailyGoal && !this.isGoalAchieved) {
            this.isGoalAchieved = true;
            this.streakCount += 1;
        }
    }

    public void calculateInitialStreak(DailyProgress lastProgress, LocalDate today) {
        if (lastProgress != null && lastProgress.getStudyDate() != null) {
            long daysBetween = ChronoUnit.DAYS.between(lastProgress.getStudyDate(), today);
            if (daysBetween == 1 && lastProgress.isGoalAchieved()) {
                this.streakCount = lastProgress.getStreakCount() + 1;
            } else if (daysBetween > 1) {
                this.streakCount = 0;
            } else {
                this.streakCount = lastProgress.getStreakCount();
            }
        } else {
            this.streakCount = 0;
        }
    }
}

