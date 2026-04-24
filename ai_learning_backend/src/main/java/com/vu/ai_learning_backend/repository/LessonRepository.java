package com.vu.ai_learning_backend.repository;

import com.vu.ai_learning_backend.entity.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LessonRepository extends JpaRepository<Lesson, Long> {
    // Hàm "thần thánh" tự động tìm bài học theo tên user và sắp xếp mới nhất lên đầu
    List<Lesson> findByUsernameOrderByCreatedAtDesc(String username);
}