package com.vu.ai_learning_backend.modules.identity.application.usecase;

import com.vu.ai_learning_backend.common.exception.BadRequestException;
import com.vu.ai_learning_backend.modules.identity.application.port.PasswordEncoderPort;
import com.vu.ai_learning_backend.modules.identity.domain.model.User;
import com.vu.ai_learning_backend.modules.identity.domain.repository.UserRepositoryPort;
import org.springframework.stereotype.Service;

@Service
public class RegisterUserUseCase {
    private final UserRepositoryPort userRepositoryPort;
    private final PasswordEncoderPort passwordEncoderPort;

    public RegisterUserUseCase(UserRepositoryPort userRepositoryPort, PasswordEncoderPort passwordEncoderPort) {
        this.userRepositoryPort = userRepositoryPort;
        this.passwordEncoderPort = passwordEncoderPort;
    }

    public User execute(User user) {
        if (user.getUsername() == null || user.getUsername().trim().isEmpty()) {
            throw new BadRequestException("Tên đăng nhập không được để trống!");
        }
        if (userRepositoryPort.findByUsername(user.getUsername()).isPresent()) {
            throw new BadRequestException("Tên đăng nhập đã tồn tại! Vui lòng chọn tên khác.");
        }

        user.setPassword(passwordEncoderPort.encode(user.getPassword()));
        return userRepositoryPort.save(user);
    }
}

