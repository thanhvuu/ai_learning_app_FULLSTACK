package com.vu.ai_learning_backend.modules.identity.application.usecase;

import com.vu.ai_learning_backend.modules.identity.domain.model.User;
import com.vu.ai_learning_backend.modules.identity.domain.repository.UserRepositoryPort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GetAllUsersUseCase {
    private final UserRepositoryPort userRepositoryPort;

    public GetAllUsersUseCase(UserRepositoryPort userRepositoryPort) {
        this.userRepositoryPort = userRepositoryPort;
    }

    public List<User> execute() {
        return userRepositoryPort.findAll();
    }
}

