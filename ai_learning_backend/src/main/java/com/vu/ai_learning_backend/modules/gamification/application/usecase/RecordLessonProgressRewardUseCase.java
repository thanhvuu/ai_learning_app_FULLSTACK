package com.vu.ai_learning_backend.modules.gamification.application.usecase;

import com.vu.ai_learning_backend.common.exception.ResourceNotFoundException;
import com.vu.ai_learning_backend.modules.identity.domain.model.User;
import com.vu.ai_learning_backend.modules.identity.domain.repository.UserRepositoryPort;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Map;

@Service
public class RecordLessonProgressRewardUseCase {

    private final UserRepositoryPort userRepositoryPort;

    public RecordLessonProgressRewardUseCase(UserRepositoryPort userRepositoryPort) {
        this.userRepositoryPort = userRepositoryPort;
    }

    public Map<String, Object> execute(String username) {
        User user = userRepositoryPort.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng này!"));

        // Mỗi bài học xong thưởng 20 XP
        user.addXp(20);

        // Tính toán Streak
        LocalDate today = LocalDate.now();
        user.updateStudyStreak(today);

        userRepositoryPort.save(user);

        return Map.of(
                "totalXp", user.getSafeTotalXp(),
                "streak", user.getSafeStreak(),
                "message", "Cập nhật tiến độ thành công!"
        );
    }
}

