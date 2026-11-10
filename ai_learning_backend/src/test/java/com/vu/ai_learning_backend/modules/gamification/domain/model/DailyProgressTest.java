package com.vu.ai_learning_backend.modules.gamification.domain.model;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class DailyProgressTest {

    @Test
    @DisplayName("Cộng phút học chưa đạt mục tiêu: Không tăng streak và isGoalAchieved = false")
    void testAddMinutesBelowGoal() {
        DailyProgress progress = DailyProgress.builder()
                .username("test_user")
                .studyDate(LocalDate.now())
                .dailyGoal(45)
                .minutesLearned(0)
                .isGoalAchieved(false)
                .streakCount(2)
                .build();

        progress.addMinutes(30);

        assertEquals(30, progress.getMinutesLearned());
        assertFalse(progress.isGoalAchieved());
        assertEquals(2, progress.getStreakCount());
    }

    @Test
    @DisplayName("Cộng phút học vượt mục tiêu: isGoalAchieved = true và streakCount tăng 1")
    void testAddMinutesReachingGoal() {
        DailyProgress progress = DailyProgress.builder()
                .username("test_user")
                .studyDate(LocalDate.now())
                .dailyGoal(45)
                .minutesLearned(40)
                .isGoalAchieved(false)
                .streakCount(2)
                .build();

        progress.addMinutes(10); // 50 >= 45

        assertEquals(50, progress.getMinutesLearned());
        assertTrue(progress.isGoalAchieved());
        assertEquals(3, progress.getStreakCount());
    }

    @Test
    @DisplayName("Tính toán chuỗi streak từ ngày học hôm qua đã đạt mục tiêu")
    void testCalculateInitialStreakYesterdayAchieved() {
        LocalDate today = LocalDate.now();
        DailyProgress yesterday = DailyProgress.builder()
                .username("test_user")
                .studyDate(today.minusDays(1))
                .isGoalAchieved(true)
                .streakCount(3)
                .build();

        DailyProgress todayProgress = DailyProgress.builder()
                .username("test_user")
                .studyDate(today)
                .build();

        todayProgress.calculateInitialStreak(yesterday, today);

        assertEquals(4, todayProgress.getStreakCount());
    }

    @Test
    @DisplayName("Tính toán chuỗi streak khi bỏ lỡ quá 1 ngày: Streak về 0")
    void testCalculateInitialStreakMissedDays() {
        LocalDate today = LocalDate.now();
        DailyProgress twoDaysAgo = DailyProgress.builder()
                .username("test_user")
                .studyDate(today.minusDays(2))
                .isGoalAchieved(true)
                .streakCount(5)
                .build();

        DailyProgress todayProgress = DailyProgress.builder()
                .username("test_user")
                .studyDate(today)
                .build();

        todayProgress.calculateInitialStreak(twoDaysAgo, today);

        assertEquals(0, todayProgress.getStreakCount());
    }
}

