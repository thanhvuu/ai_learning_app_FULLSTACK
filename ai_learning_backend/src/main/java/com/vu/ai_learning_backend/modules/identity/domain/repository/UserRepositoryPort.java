package com.vu.ai_learning_backend.modules.identity.domain.repository;

import com.vu.ai_learning_backend.modules.identity.domain.model.User;

import java.util.List;
import java.util.Optional;

public interface UserRepositoryPort {
    User save(User user);
    Optional<User> findById(Long id);
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    List<User> findAll();
    List<User> findTop10ByOrderByTotalXpDesc();
}

