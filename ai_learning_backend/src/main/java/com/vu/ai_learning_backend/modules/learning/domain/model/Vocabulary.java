package com.vu.ai_learning_backend.modules.learning.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Vocabulary {
    private Long id;
    private String word;
    private String phonetic;
    private String meaning;
    private String example;
}

