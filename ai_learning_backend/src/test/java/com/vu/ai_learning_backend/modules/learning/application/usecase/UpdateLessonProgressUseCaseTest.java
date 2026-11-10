package com.vu.ai_learning_backend.modules.learning.application.usecase;

import com.vu.ai_learning_backend.modules.learning.application.port.EventPublisherPort;
import com.vu.ai_learning_backend.modules.learning.domain.event.LessonCompletedEvent;
import com.vu.ai_learning_backend.modules.learning.domain.model.Lesson;
import com.vu.ai_learning_backend.modules.learning.domain.repository.LessonRepositoryPort;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class UpdateLessonProgressUseCaseTest {

    private LessonRepositoryPort lessonRepositoryPort;
    private EventPublisherPort eventPublisherPort;
    private UpdateLessonProgressUseCase useCase;

    @BeforeEach
    void setUp() {
        lessonRepositoryPort = mock(LessonRepositoryPort.class);
        eventPublisherPort = mock(EventPublisherPort.class);
        useCase = new UpdateLessonProgressUseCase(lessonRepositoryPort, eventPublisherPort);
    }

    @Test
    @DisplayName("Cập nhật tiến độ bài học chưa hoàn thành (progress < 100): Không phát sự kiện LessonCompletedEvent")
    void testProgressUnder100NoEvent() {
        Lesson existingLesson = Lesson.builder()
                .id(1L)
                .username("user1")
                .progress(20)
                .build();

        when(lessonRepositoryPort.findById(1L)).thenReturn(Optional.of(existingLesson));
        when(lessonRepositoryPort.save(any(Lesson.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Lesson result = useCase.execute(1L, 60);

        assertEquals(60, result.getProgress());
        verify(eventPublisherPort, never()).publish(any());
    }

    @Test
    @DisplayName("Cập nhật tiến độ bài học đạt 100%: Phát sự kiện LessonCompletedEvent")
    void testProgressReaching100PublishesEvent() {
        Lesson existingLesson = Lesson.builder()
                .id(1L)
                .username("user1")
                .progress(80)
                .build();

        when(lessonRepositoryPort.findById(1L)).thenReturn(Optional.of(existingLesson));
        when(lessonRepositoryPort.save(any(Lesson.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Lesson result = useCase.execute(1L, 100);

        assertEquals(100, result.getProgress());

        ArgumentCaptor<LessonCompletedEvent> captor = ArgumentCaptor.forClass(LessonCompletedEvent.class);
        verify(eventPublisherPort, times(1)).publish(captor.capture());

        LessonCompletedEvent publishedEvent = captor.getValue();
        assertEquals("user1", publishedEvent.getUsername());
        assertEquals(1L, publishedEvent.getLessonId());
        assertEquals(100, publishedEvent.getProgress());
    }
}

