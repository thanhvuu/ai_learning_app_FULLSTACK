package com.vu.ai_learning_backend.repository;

import com.vu.ai_learning_backend.entity.DailyProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface DailyProgressRepository extends JpaRepository<DailyProgress, Long> {
    // Tìm tiến độ học của 1 user trong 1 ngày cụ thể
    Optional<DailyProgress> findByUsernameAndStudyDate(String username, LocalDate studyDate);

    // Tìm ngày học gần nhất của user để tính Streak
    Optional<DailyProgress> findTopByUsernameOrderByStudyDateDesc(String username);
}