package com.vu.ai_learning_backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import com.fasterxml.jackson.annotation.JsonBackReference;

@Entity
@Data
public class Question {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // --- 2 BIẾN MỚI THAY CHO BIẾN content CŨ ---
    @Column(columnDefinition = "TEXT")
    private String sentenceStart; // Khúc đầu câu (VD: "I ")

    @Column(columnDefinition = "TEXT")
    private String sentenceEnd;   // Khúc sau câu (VD: " to school every day.")

    private String optionA;
    private String optionB;
    private String optionC;
    private String optionD;

    private String correctAnswer;
    private String explanation;

    @ManyToOne
    @JoinColumn(name = "lesson_id")
    @com.fasterxml.jackson.annotation.JsonIgnore
    private Lesson lesson;
}