package com.vu.ai_learning_backend.modules.identity.application.usecase;

import com.vu.ai_learning_backend.common.exception.BadRequestException;
import com.vu.ai_learning_backend.modules.identity.application.port.PasswordEncoderPort;
import com.vu.ai_learning_backend.modules.identity.domain.model.User;
import com.vu.ai_learning_backend.modules.identity.domain.repository.UserRepositoryPort;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class RegisterUserUseCaseTest {

    private UserRepositoryPort userRepositoryPort;
    private PasswordEncoderPort passwordEncoderPort;
    private RegisterUserUseCase registerUserUseCase;

    @BeforeEach
    void setUp() {
        userRepositoryPort = mock(UserRepositoryPort.class);
        passwordEncoderPort = mock(PasswordEncoderPort.class);
        registerUserUseCase = new RegisterUserUseCase(userRepositoryPort, passwordEncoderPort);
    }

    @Test
    @DisplayName("Đăng ký thành công: Mật khẩu được mã hóa và người dùng được lưu vào database")
    void testRegisterSuccess() {
        User user = User.builder()
                .username("new_user")
                .email("new@example.com")
                .password("raw_password")
                .build();

        when(userRepositoryPort.findByUsername("new_user")).thenReturn(Optional.empty());
        when(passwordEncoderPort.encode("raw_password")).thenReturn("hashed_password");
        when(userRepositoryPort.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        User registered = registerUserUseCase.execute(user);

        assertNotNull(registered);
        assertEquals("hashed_password", registered.getPassword());
        verify(userRepositoryPort, times(1)).save(user);
    }

    @Test
    @DisplayName("Đăng ký thất bại khi username đã tồn tại")
    void testRegisterDuplicateUsername() {
        User user = User.builder()
                .username("existing_user")
                .email("test@example.com")
                .password("pass")
                .build();

        when(userRepositoryPort.findByUsername("existing_user")).thenReturn(Optional.of(user));

        assertThrows(BadRequestException.class, () -> registerUserUseCase.execute(user));
        verify(userRepositoryPort, never()).save(any());
    }
}

