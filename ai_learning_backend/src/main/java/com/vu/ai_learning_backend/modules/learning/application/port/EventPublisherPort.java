package com.vu.ai_learning_backend.modules.learning.application.port;

import com.vu.ai_learning_backend.common.domain.DomainEvent;

public interface EventPublisherPort {
    void publish(DomainEvent event);
}

