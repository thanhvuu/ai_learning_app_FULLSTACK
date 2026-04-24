package com.vu.ai_learning_backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;

@Data
@Entity
@Table(name = "daily_progress")
public class DailyProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String username;

    // Ngày học (Chỉ lưu ngày, tháng, năm)
    private LocalDate studyDate;

    // Tổng số phút đã học trong ngày hôm đó
    private int minutesLearned;

    // Mục tiêu của ngày hôm đó (Mặc định là 45 phút)
    private int dailyGoal = 45;

    // Có hoàn thành mục tiêu ngày hôm đó chưa?
    private boolean isGoalAchieved = false;

    // Chuỗi ngày học liên tiếp tính đến ngày hôm đó
    private int streakCount;
}