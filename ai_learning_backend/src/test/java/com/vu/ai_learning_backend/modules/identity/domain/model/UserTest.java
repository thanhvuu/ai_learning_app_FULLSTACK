package com.vu.ai_learning_backend.modules.identity.domain.model;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class UserTest {

    @Test
    @DisplayName("Cộng XP chính xác")
    void testAddXp() {
        User user = User.builder().totalXp(50).build();
        user.addXp(20);
        assertEquals(70, user.getTotalXp());
    }

    @Test
    @DisplayName("Tưới cây: cộng dồn số cây và thưởng 5 XP trên mỗi cây")
    void testWaterPlants() {
        User user = User.builder().wateredPlants(2).totalXp(10).build();
        user.waterPlants(3);

        assertEquals(5, user.getWateredPlants());
        assertEquals(25, user.getTotalXp()); // 10 + (3 * 5)
    }

    @Test
    @DisplayName("Cập nhật streak liên tiếp mỗi ngày")
    void testUpdateStudyStreakConsecutiveDays() {
        LocalDate today = LocalDate.now();
        User user = User.builder()
                .streak(2)
                .lastStudyDate(today.minusDays(1))
                .build();

        user.updateStudyStreak(today);

        assertEquals(3, user.getStreak());
        assertEquals(today, user.getLastStudyDate());
    }

    @Test
    @DisplayName("Cập nhật streak khi bỏ lỡ quá 1 ngày: streak reset về 1")
    void testUpdateStudyStreakBroken() {
        LocalDate today = LocalDate.now();
        User user = User.builder()
                .streak(10)
                .lastStudyDate(today.minusDays(3))
                .build();

        user.updateStudyStreak(today);

        assertEquals(1, user.getStreak());
        assertEquals(today, user.getLastStudyDate());
    }
}

