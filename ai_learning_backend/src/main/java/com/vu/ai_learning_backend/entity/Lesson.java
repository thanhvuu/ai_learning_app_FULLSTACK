package com.vu.ai_learning_backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Entity
@Table(name = "lessons")
public class Lesson {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    @Column(length = 1000)
    private String pdfUrl;

    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "lesson", cascade = CascadeType.ALL)
    private List<Question> questions;

    // ==========================================
    // CÁC TRƯỜNG THÊM MỚI CHO TAB "MY LESSONS"
    // ==========================================
    private String username;
    private String quizType; // drag_drop, multiple_choice, fill_blank
    private int progress;    // 0 đến 100

    @Column(columnDefinition = "TEXT")
    private String content; // Nội dung bài đọc (AI tự soạn hoặc bóc tách từ PDF)

    private String category; // Chuyên ngành (ví dụ: IT, Business) để nhóm theo lộ trình

    @OneToMany(mappedBy = "lesson", cascade = CascadeType.ALL)
    private List<Vocabulary> vocabularies;
}