package com.vu.ai_learning_backend.modules.gamification.application.listener;

import com.vu.ai_learning_backend.modules.gamification.application.usecase.RecordLessonProgressRewardUseCase;
import com.vu.ai_learning_backend.modules.learning.domain.event.LessonCompletedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

@Component
public class LessonCompletedEventListener {

    private final RecordLessonProgressRewardUseCase recordLessonProgressRewardUseCase;

    public LessonCompletedEventListener(RecordLessonProgressRewardUseCase recordLessonProgressRewardUseCase) {
        this.recordLessonProgressRewardUseCase = recordLessonProgressRewardUseCase;
    }

    @EventListener
    public void onLessonCompleted(LessonCompletedEvent event) {
        System.out.println("--- [EVENT BUS] Received LessonCompletedEvent for user: " + event.getUsername() + " ---");
        try {
            recordLessonProgressRewardUseCase.execute(event.getUsername());
        } catch (Exception e) {
            System.err.println("--- [EVENT BUS] Error processing lesson completed reward: " + e.getMessage());
        }
    }
}

