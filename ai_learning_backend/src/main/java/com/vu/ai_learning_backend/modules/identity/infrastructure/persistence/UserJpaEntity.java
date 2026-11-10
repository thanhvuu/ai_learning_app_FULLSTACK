package com.vu.ai_learning_backend.modules.identity.infrastructure.persistence;

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
        name = "users",
        indexes = {
                @Index(name = "idx_users_username", columnList = "username"),
                @Index(name = "idx_users_total_xp", columnList = "total_xp")
        }
)
public class UserJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    private String password;

    @Column(unique = true)
    private String username;

    @Builder.Default
    @Column(columnDefinition = "integer default 0")
    private Integer streak = 0;

    @Builder.Default
    @Column(columnDefinition = "integer default 5")
    private Integer lives = 5;

    @Builder.Default
    @Column(name = "total_xp", columnDefinition = "integer default 0")
    private Integer totalXp = 0;

    @Builder.Default
    @Column(name = "watered_plants", columnDefinition = "integer default 0")
    private Integer wateredPlants = 0;

    private String major;

    @Column(name = "last_study_date")
    private LocalDate lastStudyDate;

    @PrePersist
    public void prePersist() {
        if (streak == null) streak = 0;
        if (lives == null) lives = 5;
        if (totalXp == null) totalXp = 0;
        if (wateredPlants == null) wateredPlants = 0;
    }
}
