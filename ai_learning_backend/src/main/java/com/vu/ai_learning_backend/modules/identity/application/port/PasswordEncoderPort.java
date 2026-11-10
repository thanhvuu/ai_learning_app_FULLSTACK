package com.vu.ai_learning_backend.modules.identity.application.port;

public interface PasswordEncoderPort {
    String encode(String rawPassword);
    boolean matches(String rawPassword, String encodedPassword);
}

