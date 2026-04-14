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

    private int streak = 0;
    private int lives = 5;
    private int totalXp = 0;

    @Column(name =  "last_study_date")
    private LocalDate lastStudyDate;
}