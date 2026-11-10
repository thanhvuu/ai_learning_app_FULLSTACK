package com.vu.ai_learning_backend.modules.learning.domain.event;

import com.vu.ai_learning_backend.common.domain.DomainEvent;
import lombok.Getter;

@Getter
public class LessonCompletedEvent extends DomainEvent {
    private final String username;
    private final Long lessonId;
    private final int progress;

    public LessonCompletedEvent(String username, Long lessonId, int progress) {
        this.username = username;
        this.lessonId = lessonId;
        this.progress = progress;
    }
}

