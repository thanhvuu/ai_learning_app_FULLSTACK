package com.vu.ai_learning_backend.modules.learning.infrastructure.event;

import com.vu.ai_learning_backend.common.domain.DomainEvent;
import com.vu.ai_learning_backend.modules.learning.application.port.EventPublisherPort;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;

@Component
public class SpringEventPublisherAdapter implements EventPublisherPort {

    private final ApplicationEventPublisher applicationEventPublisher;

    public SpringEventPublisherAdapter(ApplicationEventPublisher applicationEventPublisher) {
        this.applicationEventPublisher = applicationEventPublisher;
    }

    @Override
    public void publish(DomainEvent event) {
        if (event != null) {
            applicationEventPublisher.publishEvent(event);
        }
    }
}

