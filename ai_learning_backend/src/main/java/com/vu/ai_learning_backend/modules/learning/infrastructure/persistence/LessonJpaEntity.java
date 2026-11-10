package com.vu.ai_learning_backend.modules.learning.infrastructure.persistence;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(
        name = "lessons",
        indexes = {
                @Index(name = "idx_lessons_username_created_at", columnList = "username, created_at"),
                @Index(name = "idx_lessons_category", columnList = "category"),
                @Index(name = "idx_lessons_username_category", columnList = "username, category")
        }
)
public class LessonJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    @Column(length = 1000)
    private String pdfUrl;

    @Builder.Default
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    private String username;
    private String quizType;
    private int progress;

    @Column(columnDefinition = "TEXT")
    private String content;

    private String category;

    @Builder.Default
    @OneToMany(mappedBy = "lesson", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<QuestionJpaEntity> questions = new ArrayList<>();

    @Builder.Default
    @OneToMany(mappedBy = "lesson", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<VocabularyJpaEntity> vocabularies = new ArrayList<>();
}

