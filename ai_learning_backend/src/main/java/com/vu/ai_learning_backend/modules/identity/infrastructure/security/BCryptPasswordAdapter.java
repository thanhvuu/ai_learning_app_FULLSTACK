package com.vu.ai_learning_backend.modules.identity.infrastructure.security;

import com.vu.ai_learning_backend.modules.identity.application.port.PasswordEncoderPort;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.stereotype.Component;

@Component
public class BCryptPasswordAdapter implements PasswordEncoderPort {

    @Override
    public String encode(String rawPassword) {
        if (rawPassword == null) {
            return null;
        }
        return BCrypt.hashpw(rawPassword, BCrypt.gensalt());
    }

    @Override
    public boolean matches(String rawPassword, String encodedPassword) {
        if (rawPassword == null || encodedPassword == null) {
            return false;
        }
        return BCrypt.checkpw(rawPassword, encodedPassword);
    }
}

