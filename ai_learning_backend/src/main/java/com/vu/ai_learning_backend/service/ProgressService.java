package com.vu.ai_learning_backend.service;

import com.vu.ai_learning_backend.entity.DailyProgress;
import com.vu.ai_learning_backend.repository.DailyProgressRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Optional;

@Service
public class ProgressService {

    @Autowired
    private DailyProgressRepository progressRepository;

    // HÀM 1: CỘNG PHÚT HỌC & TÍNH STREAK
    public DailyProgress addStudyTime(String username, int minutesToAdd) {
        LocalDate today = LocalDate.now();

        // 1. Tìm xem hôm nay user đã có bản ghi nào chưa?
        Optional<DailyProgress> todayProgressOpt = progressRepository.findByUsernameAndStudyDate(username, today);
        DailyProgress todayProgress;

        if (todayProgressOpt.isPresent()) {
            // Đã học hôm nay rồi -> Cộng dồn phút
            todayProgress = todayProgressOpt.get();
            todayProgress.setMinutesLearned(todayProgress.getMinutesLearned() + minutesToAdd);
        } else {
            // Hôm nay mới vào lần đầu -> Tạo bản ghi mới
            todayProgress = new DailyProgress();
            todayProgress.setUsername(username);
            todayProgress.setStudyDate(today);
            todayProgress.setMinutesLearned(minutesToAdd);

            // TÍNH TOÁN STREAK: Tìm ngày học gần nhất trước đó
            Optional<DailyProgress> lastProgressOpt = progressRepository.findTopByUsernameOrderByStudyDateDesc(username);

            if (lastProgressOpt.isPresent()) {
                DailyProgress lastProgress = lastProgressOpt.get();
                long daysBetween = ChronoUnit.DAYS.between(lastProgress.getStudyDate(), today);

                if (daysBetween == 1 && lastProgress.isGoalAchieved()) {
                    // Nếu ngày học gần nhất là HÔM QUA và ĐÃ ĐẠT MỤC TIÊU -> Tăng Streak
                    todayProgress.setStreakCount(lastProgress.getStreakCount() + 1);
                } else if (daysBetween > 1) {
                    // Nếu bỏ bê quá 1 ngày -> Mất chuỗi, về 0
                    todayProgress.setStreakCount(0);
                } else {
                    // Trường hợp hôm qua chưa đạt mục tiêu
                    todayProgress.setStreakCount(lastProgress.getStreakCount());
                }
            } else {
                // Người dùng hoàn toàn mới
                todayProgress.setStreakCount(0);
            }
        }

        // 2. KIỂM TRA XEM ĐÃ ĐẠT MỤC TIÊU CHƯA?
        if (todayProgress.getMinutesLearned() >= todayProgress.getDailyGoal() && !todayProgress.isGoalAchieved()) {
            todayProgress.setGoalAchieved(true);
            // Nếu hôm nay vừa đạt mục tiêu thì tăng Streak lên luôn
            todayProgress.setStreakCount(todayProgress.getStreakCount() + 1);
        }

        return progressRepository.save(todayProgress);
    }

    // HÀM 2: LẤY THÔNG TIN TIẾN ĐỘ HÔM NAY ĐỂ HIỂN THỊ LÊN FLUTTER
    public DailyProgress getTodayProgress(String username) {
        LocalDate today = LocalDate.now();
        return progressRepository.findByUsernameAndStudyDate(username, today)
                .orElseGet(() -> {
                    // Nếu hôm nay chưa có gì thì trả về một bản ghi trống (0 phút)
                    DailyProgress empty = new DailyProgress();
                    empty.setUsername(username);
                    empty.setStudyDate(today);
                    empty.setMinutesLearned(0);

                    // Lấy lại Streak cũ để hiển thị (dù hôm nay chưa học)
                    progressRepository.findTopByUsernameOrderByStudyDateDesc(username)
                            .ifPresent(last -> {
                                long daysBetween = ChronoUnit.DAYS.between(last.getStudyDate(), today);
                                empty.setStreakCount(daysBetween > 1 ? 0 : last.getStreakCount());
                            });
                    return empty;
                });
    }
}