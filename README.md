<div align="center">

# 🤖 AI Learning App

### Smart English Learning Application Powered by AI

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.4-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Gemini AI](https://img.shields.io/badge/Gemini-2.5--flash-8E75B2?logo=googlegemini&logoColor=white)](https://ai.google.dev)
[![Java](https://img.shields.io/badge/Java-17-ED8B00?logo=openjdk&logoColor=white)](https://openjdk.org)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Private-red)](#)

**A fullstack English learning platform integrating AI, supporting lesson generation by topic or PDF,
smart dictionary lookup, multiple quiz types, and gamification mechanics.**

[Key Features](#-key-features) •
[System Architecture](#-system-architecture) •
[Installation & Running](#-installation--running) •
[API Endpoints](#-api-endpoints) •
[Database Model](#-database-model)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Tech Stack](#-tech-stack)
- [System Architecture](#-system-architecture)
- [Installation & Running](#-installation--running)
- [API Endpoints](#-api-endpoints)
- [Database Model](#-database-model)
- [Directory Structure](#-directory-structure)

---

## 🎯 Overview

**AI Learning App** is a fullstack English learning application that combines Flutter (frontend) and Spring Boot (backend), leveraging **Google Gemini AI** to automatically generate lesson content, quizzes, and provide intelligent dictionary definitions. The application aims to personalize the learning experience with gamification mechanics (XP, streak, vocabulary garden) and industry-specific learning roadmaps.

### Target Audience

- 🎓 Students wanting to learn industry-specific English
- 📚 Self-learners seeking AI-personalized study materials
- 🏆 Learners motivated by gamified mechanics (XP, streaks, leaderboard)

---

## ✨ Key Features

### 📖 Learning

| Feature | Description |
|---|---|
| **Generate Lesson by Topic** | Input a topic → AI automatically generates content, vocabulary, and questions |
| **Generate Lesson from PDF** | Upload a PDF file → AI extracts content → generates corresponding quiz |
| **3 Quiz Types** | Drag & Drop, Multiple Choice (A/B/C/D), and Fill-in-the-blank |
| **Flashcards** | Vocabulary review using digital flashcards |
| **Roadmaps** | Learning pathways tailored by major: IT, Business, Medical, Travel, Engineering, Art, Daily, IELTS/TOEIC |

### 🔤 Vocabulary & Language Tools

| Feature | Description |
|---|---|
| **AI Dictionary** | Intelligent lookup (pronunciation, part of speech, meaning, synonyms, antonyms, Vietnamese/English examples) |
| **Offline Dictionary** | Built-in SQLite English-Vietnamese dictionary (~34MB) for offline lookup |
| **Vocabulary Garden** | Save new words and review them using spaced repetition levels (0–3) |
| **Text-to-Speech (TTS)** | Hear correct word pronunciation |
| **Speech-to-Text (STT)** | Practice pronunciation using speech recognition |
| **OCR** | Extract text from images using Google ML Kit |
| **Translation** | Quick translation tool integrated into the app |

### 🏆 Gamification & Tracking

| Feature | Description |
|---|---|
| **XP System** | Earn Experience Points by completing quizzes and learning tasks |
| **Streak** | Track the number of consecutive days studied |
| **Daily Goals** | Set target minutes (default 45 mins/day) and track daily completion |
| **Leaderboard** | View the top 10 users ranked by total XP |
| **Watering Plants** | Virtual garden gamification — watering plants awards +5 XP per plant |
| **User Profile** | View personal progress, active streaks, and total watered plants |

### 🌐 User Experience

| Feature | Description |
|---|---|
| **Localization** | Dual-language interface supporting Vietnamese 🇻🇳 and English 🇬🇧 |
| **Dark / Light Mode** | Toggle between dark and light themes with persistence |
| **Connectivity Gate** | Automatically detects network drops and presents a fallback offline screen |
| **Onboarding** | Welcome screen with guide for first-time users |

---

## 🛠 Tech Stack

### Frontend — Flutter

| Category | Technology | Version |
|---|---|---|
| Framework | Flutter / Dart | SDK ^3.10.4 |
| State Management | Provider | ^6.1.5+1 |
| HTTP Client | Dio | ^5.9.0 |
| Authentication | Firebase Auth | ^6.2.0 |
| Cloud Database | Cloud Firestore | ^6.1.3 |
| Local Database | Sqflite | ^2.4.2+1 |
| Local Storage | Shared Preferences | ^2.5.4 |
| Text-to-Speech | flutter_tts | ^4.2.5 |
| Speech-to-Text | speech_to_text | ^7.3.0 |
| OCR | google_mlkit_text_recognition | ^0.15.1 |
| Translation | translator | ^1.0.4+1 |
| File Picker | file_picker | ^10.3.10 |
| Connectivity | connectivity_plus | ^7.0.0 |

### Backend — Spring Boot

| Category | Technology | Version |
|---|---|---|
| Framework | Spring Boot | 4.0.4 |
| Language | Java | 17 |
| ORM | Spring Data JPA / Hibernate | (managed) |
| Database | PostgreSQL | 15+ |
| AI Service | Google Gemini API | gemini-2.5-flash |
| PDF Processing | Apache PDFBox | 2.0.30 |
| Password Hashing | jBCrypt | 0.4 |
| Serialization | Jackson | (managed) |
| Build Tool | Maven | 3.8+ |

---

## 🏗 System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      Flutter Mobile App                      │
│                                                              │
│  ┌─────────┐  ┌────────────┐  ┌──────────┐  ┌───────────┐  │
│  │  Views   │→ │ ViewModels │→ │ Services │→ │ API Client│  │
│  │(Screens) │  │ (Provider) │  │   /DAOs  │  │   (Dio)   │  │
│  └─────────┘  └────────────┘  └──────────┘  └─────┬─────┘  │
│                                                     │        │
│  ┌──────────────┐  ┌─────────────┐  ┌────────────┐ │        │
│  │ Firebase Auth │  │  Sqflite DB │  │  ML Kit /  │ │        │
│  │  + Firestore  │  │(Offline Dict)│  │  TTS/STT  │ │        │
│  └──────────────┘  └─────────────┘  └────────────┘ │        │
└────────────────────────────────────────────────────┼────────┘
                                                     │ HTTP/REST
                                                     ▼
┌──────────────────────────────────────────────────────────────┐
│                  Spring Boot REST API (:8080)                │
│                                                              │
│  ┌─────────────┐  ┌──────────┐  ┌─────────────┐            │
│  │ Controllers  │→ │ Services │→ │Repositories │            │
│  │  (4 files)   │  │ (3 files)│  │  (5 files)  │            │
│  └─────────────┘  └────┬─────┘  └──────┬──────┘            │
│                         │               │                    │
│                    ┌────▼────┐    ┌─────▼──────┐            │
│                    │ Gemini  │    │ PostgreSQL  │            │
│                    │   AI    │    │    (JPA)    │            │
│                    └─────────┘    └────────────┘            │
└──────────────────────────────────────────────────────────────┘
```

### Flutter Architecture (Hybrid MVVM + Clean Architecture)

```
lib/
├── core/               # Infrastructure (API config, network, error handling, i18n)
├── data/               # Data layer (models, services, DAOs)
├── features/           # Clean Architecture feature modules
│   └── leaderboard/    # Reference implementation (data → domain → presentation)
├── global/             # Service locator
└── presentation/       # UI layer (views, view_models, widgets)
```

- **Primary Pattern**: MVVM with Provider
- **Error Handling**: Custom `AppException` hierarchy + Sealed `Result<T>` type
- **Reference Module**: `features/leaderboard` — Implements complete Clean Architecture separation (DataSource → Repository → UseCase → ViewModel → View)

---

## 🚀 Installation & Running

### Prerequisites

| Requirement | Version |
|---|---|
| Java | JDK 17+ |
| Maven | 3.8+ |
| PostgreSQL | 15+ |
| Flutter SDK | Stable channel (Dart ^3.10.4) |
| Android Studio / Xcode | Platform dependent |
| Gemini API Key | [Get via Google AI Studio](https://aistudio.google.com/apikey) |

### 1️⃣ Database Setup

```bash
# Create PostgreSQL Database
psql -U postgres
CREATE DATABASE ai_learning_db;
```

### 2️⃣ Start Backend

```bash
# Navigate to backend folder
cd ai_learning_backend

# Set the required environment variables
# Linux/macOS:
export GEMINI_API_KEY=your_gemini_api_key_here

# Windows (PowerShell):
$env:GEMINI_API_KEY="your_gemini_api_key_here"

# (Optional) Customize Database configurations if not matching defaults
export DB_URL=jdbc:postgresql://localhost:5432/ai_learning_db
export DB_USERNAME=postgres
export DB_PASSWORD=123123

# Run the server
./mvnw spring-boot:run          # Linux/macOS
mvnw.cmd spring-boot:run        # Windows
```

> **Server runs on**: `http://localhost:8080`

<details>
<summary>📝 Default configuration details (<code>application.properties</code>)</summary>

| Property | Default Value |
|---|---|
| Server Port | `8080` |
| Database URL | `jdbc:postgresql://localhost:5432/ai_learning_db` |
| Database Username | `postgres` |
| Database Password | `123123` |
| Hibernate DDL | `update` (auto-creates/updates tables) |
| Max Connection Pool | `20` (HikariCP) |
| Max Upload File Size | `10MB` |
| Max Request Size | `12MB` |
| Max Tomcat Threads | `200` |

</details>

### 3️⃣ Start Frontend

```bash
# Navigate to the Flutter app directory
cd ai_learning_app

# Install dependencies
flutter pub get

# Run on a connected device/emulator
flutter run

# Or run in a browser
flutter run -d chrome
```

> **API Base URL configuration**: Defined in `lib/core/config/api_config.dart`.
> - Web: `localhost`
> - Android Emulator: `10.0.2.2`
> - Physical device: The server's IP address (default fallback is `192.168.1.30`)

### 4️⃣ Quick Verification

1. Start the backend → Go to `http://localhost:8080/api/users` (GET)
2. Start the Flutter app → Register a new user
3. Generate a lesson by topic → Finish a quiz → Check if your XP increases
4. Search a word via AI Dictionary → Add it to the vocabulary garden

---

## 📡 API Endpoints

### 👤 User Endpoints (`/api/users`)

| Method | Endpoint | Description |
|:---:|---|---|
| `GET` | `/api/users` | Retrieve all users |
| `POST` | `/api/users/register` | Register a new user (body: User JSON) |
| `POST` | `/api/users/login` | Log in (body: `{username, password}`) |
| `GET` | `/api/users/profile?username=` | Retrieve user stats (XP, streak, plants) |
| `PUT` | `/api/users/update-progress?username=` | Update daily study completion (+20 XP, calculate streak) |
| `POST` | `/api/users/update-plants?username=&plants=` | Update watered plants count (+5 XP per plant) |
| `POST` | `/api/users/update-major?username=&major=` | Change study major |
| `GET` | `/api/users/leaderboard` | Get Top 10 users ordered by XP |

### 📝 Lesson Endpoints (`/api/lessons`)

| Method | Endpoint | Description |
|:---:|---|---|
| `POST` | `/api/lessons/generate-by-topic` | Create a lesson by topic (params: `topic`, `quizType`, `username`, `category`) |
| `POST` | `/api/lessons/upload` | Upload PDF and extract quiz (params: `file`, `quizType`, `username`) |
| `POST` | `/api/lessons/update-progress` | Save lesson progress percentage (body: `{lessonId, progress}`) |
| `GET` | `/api/lessons/my-lessons?username=` | Retrieve user's lessons ordered by newest first |
| `GET` | `/api/lessons/roadmap?major=` | Retrieve preconfigured learning roadmaps by major |
| `POST` | `/api/lessons/admin/pre-generate-batch` | [Admin] Batch pre-generate template lessons |

> **3-Tier Lesson Retrieval / Caching Strategy**:
> 1. Check if the user already has a saved lesson for the topic → return if present
> 2. Look up static pre-built lesson templates → clone to user if found (prevents AI API usage)
> 3. Call Gemini AI → dynamically generate a new lesson and save to DB (fallback logic)

### 📖 Dictionary Endpoints (`/api/dictionary`)

| Method | Endpoint | Description |
|:---:|---|---|
| `GET` | `/api/dictionary/lookup?word=` | Retrieve AI-powered dictionary lookup (meanings, examples, synonyms) |

### 📊 Progress Endpoints (`/api/progress`)

| Method | Endpoint | Description |
|:---:|---|---|
| `GET` | `/api/progress/today?username=` | Retrieve today's progress stats |
| `POST` | `/api/progress/add-time` | Record learning minutes (body: `{username, minutes}`) |

---

## 🗄 Database Model

### Entity Relationship Diagram

```
┌─────────────┐       ┌──────────────┐       ┌──────────────┐
│    users     │       │   lessons    │──────<│  question    │
├─────────────┤       ├──────────────┤       ├──────────────┤
│ id (PK)     │       │ id (PK)      │       │ id (PK)      │
│ email (UQ)  │       │ title        │       │ sentenceStart│
│ username(UQ)│       │ content (TXT)│       │ sentenceEnd  │
│ password    │       │ pdfUrl       │       │ optionA~D    │
│ streak      │       │ quizType     │       │ correctAnswer│
│ lives       │       │ progress     │       │ explanation  │
│ totalXp     │       │ category     │       │ lesson_id(FK)│
│ wateredPlant│       │ username     │       └──────────────┘
│ major       │       │ createdAt    │
│ lastStudyDt │       │              │       ┌──────────────┐
└─────────────┘       │              │──────<│ vocabularies │
                      └──────────────┘       ├──────────────┤
┌─────────────────┐                          │ id (PK)      │
│ daily_progress  │                          │ word         │
├─────────────────┤                          │ phonetic     │
│ id (PK)         │                          │ meaning      │
│ username        │                          │ example (TXT)│
│ studyDate       │                          │ lesson_id(FK)│
│ minutesLearned  │                          └──────────────┘
│ dailyGoal (45m) │
│ isGoalAchieved  │
│ streakCount     │
└─────────────────┘
```

### Database Indexes

| Table | Index Name | Column(s) |
|---|---|---|
| `users` | `idx_users_username` | `username` |
| `users` | `idx_users_total_xp` | `total_xp` |
| `lessons` | `idx_lessons_username_created_at` | `username`, `created_at` |
| `lessons` | `idx_lessons_category` | `category` |
| `lessons` | `idx_lessons_username_category` | `username`, `category` |
| `daily_progress` | `idx_daily_progress_username_date` | `username`, `study_date` |

---

## 📂 Directory Structure

```
AI_Learning_Project/
├── ai_learning_app/                    # 📱 Flutter Frontend
│   ├── lib/
│   │   ├── main.dart                   # Entry point + Provider configuration
│   │   ├── firebase_options.dart       # Firebase configuration (auto-generated)
│   │   ├── core/
│   │   │   ├── config/api_config.dart  # API base URL & endpoints
│   │   │   ├── error/                  # Custom exceptions
│   │   │   ├── localization/           # i18n localization (English & Vietnamese)
│   │   │   ├── network/               # Dio Client & Result pattern implementation
│   │   │   └── result/                # Sealed Result<T> utility
│   │   ├── data/
│   │   │   ├── dao/                   # SQLite dictionary database access
│   │   │   ├── models/               # QuestionModel, VocabularyModel
│   │   │   └── services/             # Dictionary Service & Spaced Repetition garden
│   │   ├── features/
│   │   │   └── leaderboard/          # Clean Architecture reference implementation
│   │   ├── global/                    # App dependency injection locator
│   │   └── presentation/
│   │       ├── views/                 # 16 UI Screens
│   │       ├── view_models/           # MVVM ViewModels (ChangeNotifiers)
│   │       └── widgets/               # Reusable presentation widgets
│   ├── assets/
│   │   ├── image/logo.png             # Logo asset
│   │   └── database/dict_hh.db       # Packed offline dictionary SQLite database (~34MB)
│   └── pubspec.yaml
│
├── ai_learning_backend/                # ⚙️ Spring Boot Backend
│   ├── src/main/java/com/vu/ai_learning_backend/
│   │   ├── AiLearningBackendApplication.java  # Main entry class
│   │   ├── controller/                # Spring Controllers (REST Endpoints)
│   │   │   ├── UserController.java    #   /api/users/*
│   │   │   ├── LessonController.java  #   /api/lessons/*
│   │   │   ├── DictionaryController.java #  /api/dictionary/*
│   │   │   └── ProgressController.java #   /api/progress/*
│   │   ├── entity/                    # Hibernate Database Entities
│   │   │   ├── User.java
│   │   │   ├── Lesson.java
│   │   │   ├── Question.java
│   │   │   ├── Vocabulary.java
│   │   │   └── DailyProgress.java
│   │   ├── repository/               # JPA Repositories
│   │   └── service/                   # Main business logic
│   │       ├── AiService.java         #   Google Gemini API client
│   │       ├── PdfService.java        #   Apache PDFBox parsing
│   │       └── ProgressService.java   #   Streak & progress updates
│   ├── src/main/resources/
│   │   └── application.properties     # Application properties config
│   └── pom.xml
│
└── docs/
    └── architecture.md                # Architecture guidelines and roadmap
```

---

## 🔧 Environment Variables

| Variable | Required | Default Value | Description |
|---|:---:|---|---|
| `GEMINI_API_KEY` | ✅ | — | API key for Gemini Generative AI |
| `DB_URL` | ❌ | `jdbc:postgresql://localhost:5432/ai_learning_db` | PostgreSQL JDBC connection URL |
| `DB_USERNAME` | ❌ | `postgres` | Database login user |
| `DB_PASSWORD` | ❌ | `123123` | Database login password |
| `DB_POOL_MAX_SIZE` | ❌ | `20` | HikariCP database connection pool size |
| `DB_POOL_MIN_IDLE` | ❌ | `5` | Minimum idle database connections |
| `SERVER_THREADS_MAX` | ❌ | `200` | Maximum Tomcat worker threads |
| `MAX_UPLOAD_FILE_SIZE` | ❌ | `10MB` | Maximum individual uploaded file size |
| `MAX_UPLOAD_REQUEST_SIZE` | ❌ | `12MB` | Maximum total HTTP request size |

---

## 📜 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/your-username/AI_Learning_Project.git
cd AI_Learning_Project

# 2. Set up the local database
psql -U postgres -c "CREATE DATABASE ai_learning_db;"

# 3. Start the backend application
cd ai_learning_backend
export GEMINI_API_KEY=your_key_here        # Linux/macOS
# $env:GEMINI_API_KEY="your_key_here"      # Windows PowerShell
./mvnw spring-boot:run

# 4. Start the frontend application (In a new terminal window)
cd ai_learning_app
flutter pub get
flutter run
```

---

## 👨‍💻 Author

Dang Thanh Vu — Mobile Developer

---

<div align="center">

*Built with ❤️ using Flutter, Spring Boot & Google Gemini AI*

</div>
