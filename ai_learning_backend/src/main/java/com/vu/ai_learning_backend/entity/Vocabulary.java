package com.vu.ai_learning_backend.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "vocabularies")
public class Vocabulary {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String word;        // Từ vựng
    private String phonetic;    // Phiên âm
    private String meaning;     // Nghĩa tiếng Việt
    
    @Column(columnDefinition = "TEXT")
    private String example;     // Ví dụ minh họa

    @ManyToOne
    @JoinColumn(name = "lesson_id")
    @com.fasterxml.jackson.annotation.JsonIgnore
    private Lesson lesson;      // Thuộc về bài học nào
}
