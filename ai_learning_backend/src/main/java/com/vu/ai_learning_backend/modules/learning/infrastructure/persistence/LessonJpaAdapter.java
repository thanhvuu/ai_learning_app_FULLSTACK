package com.vu.ai_learning_backend.modules.learning.infrastructure.persistence;

import com.vu.ai_learning_backend.modules.learning.domain.model.Lesson;
import com.vu.ai_learning_backend.modules.learning.domain.model.Question;
import com.vu.ai_learning_backend.modules.learning.domain.model.Vocabulary;
import com.vu.ai_learning_backend.modules.learning.domain.repository.LessonRepositoryPort;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Component
public class LessonJpaAdapter implements LessonRepositoryPort {

    private final LessonJpaRepository lessonJpaRepository;

    public LessonJpaAdapter(LessonJpaRepository lessonJpaRepository) {
        this.lessonJpaRepository = lessonJpaRepository;
    }

    @Override
    @Transactional
    public Lesson save(Lesson domain) {
        LessonJpaEntity entity = toEntity(domain);
        LessonJpaEntity saved = lessonJpaRepository.save(entity);
        return toDomain(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Lesson> findById(Long id) {
        return lessonJpaRepository.findById(id).map(this::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Lesson> findFirstByUsernameAndCategory(String username, String category) {
        return lessonJpaRepository.findFirstByUsernameAndCategory(username, category).map(this::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Lesson> findFirstByCategory(String category) {
        return lessonJpaRepository.findFirstByCategory(category).map(this::toDomain);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Lesson> findByUsernameOrderByCreatedAtDesc(String username) {
        return lessonJpaRepository.findByUsernameOrderByCreatedAtDesc(username).stream()
                .map(this::toDomain)
                .collect(Collectors.toList());
    }

    public Lesson toDomain(LessonJpaEntity entity) {
        if (entity == null) return null;

        List<Question> questions = entity.getQuestions() == null ? new ArrayList<>() :
                entity.getQuestions().stream()
                        .map(q -> Question.builder()
                                .id(q.getId())
                                .sentenceStart(q.getSentenceStart())
                                .sentenceEnd(q.getSentenceEnd())
                                .optionA(q.getOptionA())
                                .optionB(q.getOptionB())
                                .optionC(q.getOptionC())
                                .optionD(q.getOptionD())
                                .correctAnswer(q.getCorrectAnswer())
                                .explanation(q.getExplanation())
                                .build())
                        .collect(Collectors.toList());

        List<Vocabulary> vocabularies = entity.getVocabularies() == null ? new ArrayList<>() :
                entity.getVocabularies().stream()
                        .map(v -> Vocabulary.builder()
                                .id(v.getId())
                                .word(v.getWord())
                                .phonetic(v.getPhonetic())
                                .meaning(v.getMeaning())
                                .example(v.getExample())
                                .build())
                        .collect(Collectors.toList());

        return Lesson.builder()
                .id(entity.getId())
                .title(entity.getTitle())
                .pdfUrl(entity.getPdfUrl())
                .createdAt(entity.getCreatedAt())
                .username(entity.getUsername())
                .quizType(entity.getQuizType())
                .progress(entity.getProgress())
                .content(entity.getContent())
                .category(entity.getCategory())
                .questions(questions)
                .vocabularies(vocabularies)
                .build();
    }

    public LessonJpaEntity toEntity(Lesson domain) {
        if (domain == null) return null;

        LessonJpaEntity entity = LessonJpaEntity.builder()
                .id(domain.getId())
                .title(domain.getTitle())
                .pdfUrl(domain.getPdfUrl())
                .createdAt(domain.getCreatedAt())
                .username(domain.getUsername())
                .quizType(domain.getQuizType())
                .progress(domain.getProgress())
                .content(domain.getContent())
                .category(domain.getCategory())
                .questions(new ArrayList<>())
                .vocabularies(new ArrayList<>())
                .build();

        if (domain.getQuestions() != null) {
            for (Question q : domain.getQuestions()) {
                QuestionJpaEntity qEntity = QuestionJpaEntity.builder()
                        .id(q.getId())
                        .sentenceStart(q.getSentenceStart())
                        .sentenceEnd(q.getSentenceEnd())
                        .optionA(q.getOptionA())
                        .optionB(q.getOptionB())
                        .optionC(q.getOptionC())
                        .optionD(q.getOptionD())
                        .correctAnswer(q.getCorrectAnswer())
                        .explanation(q.getExplanation())
                        .lesson(entity)
                        .build();
                entity.getQuestions().add(qEntity);
            }
        }

        if (domain.getVocabularies() != null) {
            for (Vocabulary v : domain.getVocabularies()) {
                VocabularyJpaEntity vEntity = VocabularyJpaEntity.builder()
                        .id(v.getId())
                        .word(v.getWord())
                        .phonetic(v.getPhonetic())
                        .meaning(v.getMeaning())
                        .example(v.getExample())
                        .lesson(entity)
                        .build();
                entity.getVocabularies().add(vEntity);
            }
        }

        return entity;
    }
}

