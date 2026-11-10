package com.vu.ai_learning_backend.modules.gamification.application.usecase;

import com.vu.ai_learning_backend.common.exception.ResourceNotFoundException;
import com.vu.ai_learning_backend.modules.identity.domain.model.User;
import com.vu.ai_learning_backend.modules.identity.domain.repository.UserRepositoryPort;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class WaterPlantsUseCase {

    private final UserRepositoryPort userRepositoryPort;

    public WaterPlantsUseCase(UserRepositoryPort userRepositoryPort) {
        this.userRepositoryPort = userRepositoryPort;
    }

    public Map<String, Object> execute(String username, int plants) {
        User user = userRepositoryPort.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng!"));

        user.waterPlants(plants);
        userRepositoryPort.save(user);

        return Map.of(
                "message", "Đã tưới " + plants + " cây thành công!",
                "totalXp", user.getSafeTotalXp(),
                "wateredPlants", user.getSafeWateredPlants()
        );
    }
}

