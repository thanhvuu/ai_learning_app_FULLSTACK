package com.vu.ai_learning_backend.modules.identity.application.usecase;

import com.vu.ai_learning_backend.common.exception.BadRequestException;
import com.vu.ai_learning_backend.modules.identity.application.port.PasswordEncoderPort;
import com.vu.ai_learning_backend.modules.identity.domain.model.User;
import com.vu.ai_learning_backend.modules.identity.domain.repository.UserRepositoryPort;
import org.springframework.stereotype.Service;

@Service
public class AuthenticateUserUseCase {
    private final UserRepositoryPort userRepositoryPort;
    private final PasswordEncoderPort passwordEncoderPort;

    public AuthenticateUserUseCase(UserRepositoryPort userRepositoryPort, PasswordEncoderPort passwordEncoderPort) {
        this.userRepositoryPort = userRepositoryPort;
        this.passwordEncoderPort = passwordEncoderPort;
    }

    public User execute(String username, String rawPassword) {
        if (username == null || rawPassword == null) {
            throw new BadRequestException("Tài khoản hoặc mật khẩu không hợp lệ!");
        }

        User user = userRepositoryPort.findByUsername(username)
                .orElseThrow(() -> new BadRequestException("Tài khoản không tồn tại!"));

        if (!passwordEncoderPort.matches(rawPassword, user.getPassword())) {
            throw new BadRequestException("Sai mật khẩu!");
        }

        return user;
    }
}

