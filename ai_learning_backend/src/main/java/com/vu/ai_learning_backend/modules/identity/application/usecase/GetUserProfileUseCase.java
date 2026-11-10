package com.vu.ai_learning_backend.modules.identity.application.usecase;

import com.vu.ai_learning_backend.common.exception.ResourceNotFoundException;
import com.vu.ai_learning_backend.modules.identity.domain.model.User;
import com.vu.ai_learning_backend.modules.identity.domain.repository.UserRepositoryPort;
import org.springframework.stereotype.Service;

@Service
public class GetUserProfileUseCase {
    private final UserRepositoryPort userRepositoryPort;

    public GetUserProfileUseCase(UserRepositoryPort userRepositoryPort) {
        this.userRepositoryPort = userRepositoryPort;
    }

    public User execute(String username) {
        return userRepositoryPort.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng!"));
    }
}

