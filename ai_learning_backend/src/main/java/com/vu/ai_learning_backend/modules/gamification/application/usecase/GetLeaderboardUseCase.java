package com.vu.ai_learning_backend.modules.gamification.application.usecase;

import com.vu.ai_learning_backend.modules.identity.domain.model.User;
import com.vu.ai_learning_backend.modules.identity.domain.repository.UserRepositoryPort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GetLeaderboardUseCase {

    private final UserRepositoryPort userRepositoryPort;

    public GetLeaderboardUseCase(UserRepositoryPort userRepositoryPort) {
        this.userRepositoryPort = userRepositoryPort;
    }

    public List<User> execute() {
        return userRepositoryPort.findTop10ByOrderByTotalXpDesc();
    }
}

