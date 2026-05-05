package com.vu.ai_learning_backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;

@Data
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;
    private String password;

    private String username;

    @Column(columnDefinition = "integer default 0")
    private Integer streak = 0;

    @Column(columnDefinition = "integer default 5")
    private Integer lives = 5;

    @Column(name = "total_xp", columnDefinition = "integer default 0")
    private Integer totalXp = 0;

    // Lưu số lượng cây từ vựng đã tưới (Mặc định là 0)
    @Column(name = "watered_plants", columnDefinition = "integer default 0")
    private Integer wateredPlants = 0;

    @Column(name = "last_study_date")
    private LocalDate lastStudyDate;

    // Tự động gán giá trị mặc định trước khi lưu vào DB
    @PrePersist
    public void prePersist() {
        if (streak == null) streak = 0;
        if (lives == null) lives = 5;
        if (totalXp == null) totalXp = 0;
        if (wateredPlants == null) wateredPlants = 0;
    }

    // Getter an toàn — trả về 0 thay vì null
    public int getStreak() { return streak != null ? streak : 0; }
    public int getLives() { return lives != null ? lives : 5; }
    public int getTotalXp() { return totalXp != null ? totalXp : 0; }
    public int getWateredPlants() { return wateredPlants != null ? wateredPlants : 0; }
}
