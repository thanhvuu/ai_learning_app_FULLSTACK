package com.vu.ai_learning_backend.modules.identity.domain.model;

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
public class User {
    private Long id;
    private String email;
    private String password;
    private String username;
    @Builder.Default
    private Integer streak = 0;
    @Builder.Default
    private Integer lives = 5;
    @Builder.Default
    private Integer totalXp = 0;
    @Builder.Default
    private Integer wateredPlants = 0;
    private String major;
    private LocalDate lastStudyDate;

    public void addXp(int xp) {
        if (xp > 0) {
            this.totalXp = (this.totalXp == null ? 0 : this.totalXp) + xp;
        }
    }

    public void waterPlants(int plants) {
        if (plants > 0) {
            this.wateredPlants = (this.wateredPlants == null ? 0 : this.wateredPlants) + plants;
            addXp(plants * 5);
        }
    }

    public void updateStudyStreak(LocalDate today) {
        if (lastStudyDate == null) {
            this.streak = 1;
        } else {
            long daysBetween = ChronoUnit.DAYS.between(lastStudyDate, today);
            if (daysBetween == 1) {
                this.streak = (this.streak == null ? 0 : this.streak) + 1;
            } else if (daysBetween > 1) {
                this.streak = 1;
            }
        }
        this.lastStudyDate = today;
    }

    public int getSafeStreak() {
        return streak != null ? streak : 0;
    }

    public int getSafeLives() {
        return lives != null ? lives : 5;
    }

    public int getSafeTotalXp() {
        return totalXp != null ? totalXp : 0;
    }

    public int getSafeWateredPlants() {
        return wateredPlants != null ? wateredPlants : 0;
    }
}

