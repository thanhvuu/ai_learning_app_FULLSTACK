package com.vu.ai_learning_backend.modules.gamification.infrastructure.persistence;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(
        name = "daily_progress",
        indexes = {
                @Index(name = "idx_daily_progress_username_date", columnList = "username, study_date")
        },
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_daily_progress_username_date", columnNames = {"username", "study_date"})
        }
)
public class DailyProgressJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String username;

    @Column(name = "study_date")
    private LocalDate studyDate;

    private int minutesLearned;

    @Builder.Default
    private int dailyGoal = 45;

    @Builder.Default
    private boolean isGoalAchieved = false;

    private int streakCount;
}

