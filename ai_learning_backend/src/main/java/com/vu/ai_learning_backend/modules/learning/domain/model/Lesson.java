package com.vu.ai_learning_backend.modules.learning.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Lesson {
    private Long id;
    private String title;
    private String pdfUrl;
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
    private String username;
    private String quizType;
    @Builder.Default
    private int progress = 0;
    private String content;
    private String category;
    @Builder.Default
    private List<Question> questions = new ArrayList<>();
    @Builder.Default
    private List<Vocabulary> vocabularies = new ArrayList<>();

    public void updateProgress(int progress) {
        this.progress = Math.min(100, Math.max(0, progress));
    }

    public boolean isFinished() {
        return this.progress >= 100;
    }

    public Lesson cloneForUser(String username, String quizType) {
        List<Vocabulary> clonedVocabs = new ArrayList<>();
        if (this.vocabularies != null) {
            for (Vocabulary v : this.vocabularies) {
                clonedVocabs.add(Vocabulary.builder()
                        .word(v.getWord())
                        .phonetic(v.getPhonetic())
                        .meaning(v.getMeaning())
                        .example(v.getExample())
                        .build());
            }
        }

        List<Question> clonedQuestions = new ArrayList<>();
        if (this.questions != null) {
            for (Question q : this.questions) {
                clonedQuestions.add(Question.builder()
                        .sentenceStart(q.getSentenceStart())
                        .sentenceEnd(q.getSentenceEnd())
                        .optionA(q.getOptionA())
                        .optionB(q.getOptionB())
                        .optionC(q.getOptionC())
                        .optionD(q.getOptionD())
                        .correctAnswer(q.getCorrectAnswer())
                        .explanation(q.getExplanation())
                        .build());
            }
        }

        return Lesson.builder()
                .title(this.title)
                .username(username)
                .quizType(quizType != null ? quizType : this.quizType)
                .progress(0)
                .content(this.content)
                .category(this.category)
                .pdfUrl(this.pdfUrl)
                .vocabularies(clonedVocabs)
                .questions(clonedQuestions)
                .createdAt(LocalDateTime.now())
                .build();
    }
}

