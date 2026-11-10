package com.vu.ai_learning_backend.modules.identity.infrastructure.persistence;

import com.vu.ai_learning_backend.modules.identity.domain.model.User;
import com.vu.ai_learning_backend.modules.identity.domain.repository.UserRepositoryPort;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Component
public class UserJpaAdapter implements UserRepositoryPort {

    private final UserJpaRepository jpaRepository;

    public UserJpaAdapter(UserJpaRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }

    @Override
    public User save(User user) {
        UserJpaEntity entity = toEntity(user);
        UserJpaEntity saved = jpaRepository.save(entity);
        return toDomain(saved);
    }

    @Override
    public Optional<User> findById(Long id) {
        return jpaRepository.findById(id).map(this::toDomain);
    }

    @Override
    public Optional<User> findByUsername(String username) {
        return jpaRepository.findByUsername(username).map(this::toDomain);
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return jpaRepository.findByEmail(email).map(this::toDomain);
    }

    @Override
    public List<User> findAll() {
        return jpaRepository.findAll().stream()
                .map(this::toDomain)
                .collect(Collectors.toList());
    }

    @Override
    public List<User> findTop10ByOrderByTotalXpDesc() {
        return jpaRepository.findTop10ByOrderByTotalXpDesc().stream()
                .map(this::toDomain)
                .collect(Collectors.toList());
    }

    private User toDomain(UserJpaEntity entity) {
        if (entity == null) return null;
        return User.builder()
                .id(entity.getId())
                .email(entity.getEmail())
                .password(entity.getPassword())
                .username(entity.getUsername())
                .streak(entity.getStreak() != null ? entity.getStreak() : 0)
                .lives(entity.getLives() != null ? entity.getLives() : 5)
                .totalXp(entity.getTotalXp() != null ? entity.getTotalXp() : 0)
                .wateredPlants(entity.getWateredPlants() != null ? entity.getWateredPlants() : 0)
                .major(entity.getMajor())
                .lastStudyDate(entity.getLastStudyDate())
                .build();
    }

    private UserJpaEntity toEntity(User domain) {
        if (domain == null) return null;
        return UserJpaEntity.builder()
                .id(domain.getId())
                .email(domain.getEmail())
                .password(domain.getPassword())
                .username(domain.getUsername())
                .streak(domain.getStreak())
                .lives(domain.getLives())
                .totalXp(domain.getTotalXp())
                .wateredPlants(domain.getWateredPlants())
                .major(domain.getMajor())
                .lastStudyDate(domain.getLastStudyDate())
                .build();
    }
}

