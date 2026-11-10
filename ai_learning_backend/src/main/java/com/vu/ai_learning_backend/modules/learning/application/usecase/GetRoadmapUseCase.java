package com.vu.ai_learning_backend.modules.learning.application.usecase;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GetRoadmapUseCase {

    public List<String> execute(String major) {
        if (major == null) {
            return List.of("Fundamental Concepts", "Essential Vocabulary", "Advanced Topics", "Case Studies", "Final Review");
        }

        if (major.contains("Information Technology")) {
            return List.of("Introduction to IT", "Computer Hardware", "Software Engineering", "Computer Networking", "Cybersecurity Basics");
        } else if (major.contains("Business")) {
            return List.of("Business Basics", "Marketing Principles", "Financial Accounting", "Human Resource Management", "International Trade");
        } else if (major.contains("Medical")) {
            return List.of("Medical Terminology", "Human Anatomy", "Common Diseases", "Pharmacology Basics", "Patient Care & Communication");
        } else if (major.contains("Travel")) {
            return List.of("At the Airport", "Hotel Reservations", "Sightseeing & Directions", "Dining Out", "Emergency Situations");
        } else if (major.contains("Engineering")) {
            return List.of("Engineering Basics", "Materials Science", "Technical Drawing", "Mathematics for Engineers", "Safety Regulations");
        } else if (major.contains("Art")) {
            return List.of("Art History", "Color Theory", "Drawing Techniques", "Digital Design Basics", "Famous Artists & Works");
        } else if (major.contains("Daily")) {
            return List.of("Greetings & Introductions", "Family & Friends", "Hobbies & Interests", "Shopping & Prices", "Weather & Time");
        } else if (major.contains("IELTS") || major.contains("TOEIC")) {
            return List.of("Listening Strategies", "Reading Comprehension", "Writing Task 1 & 2", "Speaking Fluency", "Practice Tests");
        } else {
            return List.of("Fundamental Concepts", "Essential Vocabulary", "Advanced Topics", "Case Studies", "Final Review");
        }
    }
}

