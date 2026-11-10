<div align="center">

# 🤖 AI Learning App (Fullstack)

### Smart English Learning Platform Powered by AI & Gamification

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.4-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-17%20LTS-ED8B00?logo=openjdk&logoColor=white)](https://adoptium.net)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com)
[![Google Gemini](https://img.shields.io/badge/Gemini-2.5--flash-8E75B2?logo=googlegemini&logoColor=white)](https://ai.google.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Modular%20Monolith%20%2B%20Clean%20Arch-orange)](#-system-architecture)
[![License](https://img.shields.io/badge/License-Private-red)](#)

**A production-ready fullstack English learning platform integrating Google Gemini AI,
supporting automated lesson generation by topic or PDF, smart dictionary lookup,
multi-format quizzes, offline-first sync, and engaging gamification mechanics.**

[Key Features](#-key-features) •
[System Architecture](#-system-architecture) •
[Tech Stack](#-tech-stack) •
[Directory Structure](#-directory-structure) •
[Installation & Running](#-installation--running) •
[API Endpoints](#-api-endpoints) •
[Database Model](#-database-model)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [System Architecture](#-system-architecture)
  - [Overall System Flow](#overall-system-flow)
  - [Mobile Architecture (BLoC + Modular Clean Architecture)](#mobile-architecture-flutter)
  - [Backend Architecture (Modular Monolith + Clean Architecture + Event-Driven)](#backend-architecture-spring-boot)
- [Tech Stack](#-tech-stack)
- [Directory Structure](#-directory-structure)
  - [Frontend Structure (ai_learning_app)](#frontend-ai_learning_app)
  - [Backend Structure (ai_learning_backend)](#backend-ai_learning_backend)
- [Database Model](#-database-model)
- [API Endpoints](#-api-endpoints)
- [Installation & Running](#-installation--running)
  - [Option 1: Quickstart with Docker Compose (Recommended)](#option-1-quickstart-with-docker-compose-recommended)
  - [Option 2: Manual Local Setup](#option-2-manual-local-setup)
- [Environment Variables](#-environment-variables)

---

## 🎯 Overview

**AI Learning App** is a fullstack cross-platform language learning ecosystem designed for modern learners:
- **Frontend (Flutter)**: Refactored to **Modular Clean Architecture** powered by **BLoC/Cubit state management**, **Injectable/GetIt dependency injection**, and an **offline-first repository pattern** (Hive & SQLite) with dynamic remote synchronization.
- **Backend (Spring Boot)**: Refactored from a traditional layered structure to a **Modular Monolith** with strict **Clean Architecture boundaries** across 4 Bounded Contexts (`identity`, `learning`, `gamification`, `ai`), coupled via **In-process Event-Driven messaging (Spring Events)** and fully containerized via **Docker Multi-stage builds**.

---

## ✨ Key Features

### 📖 AI-Powered Learning
- **Generate Lesson by Topic**: Input any topic or professional industry (IT, Business, Medical, etc.) → Gemini 2.5 Flash crafts an engaging reading text, core vocabulary (with IPA, meanings, examples), and exercises.
- **Generate Lesson from PDF**: Upload course materials or slides (PDF) → Apache PDFBox extracts text → AI synthesizes concise quizzes.
- **3 Quiz Formats**: Drag & Drop, Multiple Choice (A/B/C/D), and Fill-in-the-blank with immediate explanations.
- **Industry Roadmaps**: Pre-configured learning tracks (IT, Business, Medical, Travel, Engineering, Art, Daily Life, IELTS/TOEIC).
- **Multi-Tier Caching**: Intelligent 3-tier retrieval (User cached lesson → Pre-built system templates → Gemini AI generation) to minimize latency and token costs.

### 🔤 Smart Dictionary & Language Tools
- **AI Dictionary Lookup**: Rich word breakdown (part of speech, IPA phonetic pronunciation, concise Vietnamese definitions, synonyms, antonyms, bilingual example sentences).
- **Offline Dictionary**: Built-in SQLite English-Vietnamese dictionary (~34MB) for instant offline lookups without internet.
- **Vocabulary Garden**: Spaced repetition garden (Levels 0–3) for systematic long-term retention.
- **Speech Recognition (STT) & Text-to-Speech (TTS)**: Practice pronunciation and hear authentic English speech.
- **OCR Text Extraction**: Recognize text from camera or photos using Google ML Kit.

### 🏆 Gamification & Tracking
- **Experience Points (XP)**: Earn XP upon quiz completion (+20 XP), watering vocabulary plants (+5 XP), and daily goals.
- **Streak Counter**: Track consecutive study days with automatic forgiveness and reset algorithms.
- **Daily Study Goals**: Target study minutes (default 45 mins/day) with progress indicators.
- **Global Leaderboard**: Real-time Top 10 rankings sorted by total XP.
- **Decoupled Reward Events**: The learning engine triggers `LessonCompletedEvent` asynchronously; the gamification engine automatically updates XP, streaks, and progress records without cross-module tight coupling.

---

## 🏗 System Architecture

### Overall System Flow

```
┌────────────────────────────────────────────────────────────────────────┐
│                          FLUTTER MOBILE CLIENT                         │
│                                                                        │
│   ┌───────────────────┐    ┌────────────────────┐   ┌──────────────┐   │
│   │   Feature Views   │ ── │ BLoCs / Cubits     │── │ Repositories │   │
│   │   (UI Modules)    │    │ (State Management) │   │ (Domain)     │   │
│   └───────────────────┘    └────────────────────┘   └──────┬───────┘   │
│                                                            │           │
│         ┌───────────────────────┬──────────────────────────┤           │
│         ▼                       ▼                          ▼           │
│   ┌───────────┐           ┌───────────┐              ┌───────────┐     │
│   │  Dio/API  │           │  Hive DB  │              │ Sqflite DB│     │
│   │  Client   │           │ (Offline) │              │  (Dict)   │     │
│   └─────┬─────┘           └───────────┘              └───────────┘     │
└─────────┼──────────────────────────────────────────────────────────────┘
          │ HTTP / REST (JSON)
          ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   SPRING BOOT MODULAR MONOLITH (BE)                    │
│                                                                        │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │                   Presentation Layer (REST Controllers)        │   │
│   │   /api/users/*   │  /api/lessons/*  │  /api/progress/*  │ ...  │   │
│   └─────────┬───────────────────┬───────────────────┬──────────────┘   │
│             │                   │                   │                  │
│   ┌─────────▼────────┐  ┌───────▼──────────┐  ┌─────▼──────────────┐   │
│   │ Identity Module  │  │ Learning Module  │  │ Gamification Module│   │
│   │  - Auth UseCases │  │  - Lesson UseCase│  │  - Streak & XP     │   │
│   │  - User Domain   │  │  - Quiz Generator│  │  - Daily Goals     │   │
│   └──────────────────┘  └───────┬──────────┘  └─────▲──────────────┘   │
│                                 │                   │                  │
│                                 │ [Publishes Event] │ [Listens]        │
│                                 └──► LessonCompletedEvent ─────────────┘
│                                                                        │
│   ┌──────────────────┐  ┌──────────────────────────────────────────┐   │
│   │    AI Module     │  │       Shared Kernel (common package)     │   │
│   │ - Gemini Adapter │  │ - DomainEvent │ GlobalExceptionHandler   │   │
│   │ - PDFBox Adapter │  │ - ApiResponse │ Domain Exceptions        │   │
│   └────────┬─────────┘  └──────────────────────────────────────────┘   │
└────────────┼──────────────────────────┬────────────────────────────────┘
             ▼                          ▼
     ┌───────────────┐          ┌───────────────┐
     │  Google AI    │          │  PostgreSQL   │
     │  Gemini 2.5   │          │  (Port 5432)  │
     └───────────────┘          └───────────────┘
```

---

### Mobile Architecture (Flutter)

The mobile application is structured around **Feature-Driven Modular Clean Architecture** with **BLoC (Business Logic Component)**:

```
lib/
├── generated/                     # Auto-generated code (Intl localization)
└── src/
    ├── common/                    # Cross-cutting design system & utilities
    │   ├── constants/             # App assets, colors, and layout dimensions
    │   ├── enum/                  # Shared domain enumerations
    │   ├── extensions/            # Context, String, and DateTime extensions
    │   ├── theme/                 # Light & Dark theme definitions
    │   ├── utils/                 # AppEnvironment, device info, helpers
    │   └── widgets/               # Reusable atomic UI components
    │
    ├── core/                      # Global infrastructure & shared domain
    │   ├── application/           # Global BLoCs (AuthBloc, LanguageCubit, ThemeCubit)
    │   ├── di/                    # Dependency Injection (Injectable + GetIt)
    │   ├── domain/                # Core domain entities, contracts, Result<T>, AppException
    │   └── infrastructure/        # Network (Dio Client), Local DBs (Hive, Sqflite), Sync Service
    │
    └── modules/                   # Independent feature modules
        ├── app/                   # Root application container & router
        ├── splash/                # Splash & session verification
        ├── login/ & register/     # Authentication flows
        ├── home/                  # Dashboard, streak summary, daily goal
        ├── explore_lessons/       # Topic browsing, PDF upload, roadmaps
        ├── playlist/              # Lesson player, interactive quizzes, flashcards
        └── profile/               # User statistics, garden watering, settings
```

- **Separation of Concerns**: UI screens observe BLoC/Cubit states; business logic delegates to Domain Repository contracts; Infrastructure handles HTTP requests and local caching transparently.
- **Offline-First Synchronization**: Changes made offline queue up via `SyncService` into Hive storage and sync when network connectivity returns (`connectivity_plus`).

---

### Backend Architecture (Spring Boot)

The backend is built as a **Modular Monolith** where each business capability is an isolated Bounded Context following strict **Clean Architecture (Onion / Hexagonal)** layers:

```
com.vu.ai_learning_backend/
├── AiLearningBackendApplication.java
│
├── common/                               # SHARED KERNEL
│   ├── domain/DomainEvent.java           # Base class for all domain events
│   ├── exception/                        # DomainException, ResourceNotFoundException, BadRequestException
│   ├── exception/GlobalExceptionHandler  # Centralized RFC-compliant error translation
│   └── web/ApiResponse.java              # Standardized API envelope
│
└── modules/
    ├── identity/                         # BOUNDED CONTEXT: IDENTITY & USER
    │   ├── domain/model/User.java        # Pure POJO Domain Entity (rules: addXp, streak, waterPlants)
    │   ├── domain/repository/            # UserRepositoryPort (Interface)
    │   ├── application/usecase/          # Register, Authenticate, GetUserProfile, UpdateMajor
    │   ├── application/port/             # PasswordEncoderPort
    │   ├── infrastructure/persistence/   # UserJpaEntity, UserJpaRepository, UserJpaAdapter
    │   ├── infrastructure/security/      # BCryptPasswordAdapter
    │   └── presentation/UserController   # REST API: /api/users/*
    │
    ├── learning/                         # BOUNDED CONTEXT: LESSONS & QUIZZES
    │   ├── domain/model/                 # Lesson, Question, Vocabulary, QuizType
    │   ├── domain/event/                 # LessonCompletedEvent
    │   ├── domain/repository/            # LessonRepositoryPort
    │   ├── application/usecase/          # GenerateByTopic, GenerateFromPdf, UpdateProgress, Roadmap
    │   ├── application/port/             # EventPublisherPort
    │   ├── infrastructure/persistence/   # LessonJpaEntity, QuestionJpaEntity, VocabularyJpaEntity, Adapter
    │   ├── infrastructure/event/         # SpringEventPublisherAdapter
    │   └── presentation/LessonController # REST API: /api/lessons/*
    │
    ├── ai/                               # BOUNDED CONTEXT: AI & DOCUMENT SERVICES
    │   ├── application/port/             # GeminiClientPort, PdfExtractorPort
    │   ├── application/usecase/          # LookupDictionaryUseCase, ExtractPdfTextUseCase
    │   ├── infrastructure/gemini/        # GeminiAiAdapter (Gemini 2.5 Flash + pre-built caching)
    │   ├── infrastructure/pdf/           # ApachePdfBoxAdapter (PDF text extraction)
    │   └── presentation/DictionaryController # REST API: /api/dictionary/lookup
    │
    └── gamification/                     # BOUNDED CONTEXT: GAMIFICATION & TRACKING
        ├── domain/model/                 # DailyProgress (study minutes & streak calculation logic)
        ├── domain/repository/            # DailyProgressRepositoryPort
        ├── application/usecase/          # RecordStudyTime, WaterPlants, GetLeaderboard, GetTodayProgress
        ├── application/listener/         # LessonCompletedEventListener (In-process Event Bus)
        ├── infrastructure/persistence/   # DailyProgressJpaEntity, Repository, Adapter
        └── presentation/ProgressController   # REST API: /api/progress/*
```

#### Key Architecture Principles Enforced:
1. **Dependency Rule**: The `domain` layer has ZERO dependencies on Spring, Hibernate, or third-party frameworks.
2. **In-Process Event-Driven Decoupling**: When a user completes a lesson, `UpdateLessonProgressUseCase` publishes a `LessonCompletedEvent`. The `gamification` module listens via `@EventListener` to award +20 XP and advance streaks without `learning` knowing anything about `gamification`.
3. **Pluggable Infrastructure**: Swapping Gemini for another LLM or swapping PostgreSQL requires changing only an Adapter; domain and application logic remain untouched.

---

## 🛠 Tech Stack

### Frontend (Mobile App)

| Category | Technology / Package | Version | Purpose |
|---|---|---|---|
| **Framework** | Flutter / Dart | SDK ^3.4.0 | Multi-platform mobile runtime |
| **State Management** | `flutter_bloc` / `bloc` | ^8.1.6 / ^8.1.4 | Predictable state management with events & states |
| **Data Immutability** | `equatable` | ^2.0.5 | Value equality comparison for states |
| **Dependency Injection**| `injectable` / `get_it` | ^2.5.0 / ^8.0.0 | Compile-time dependency injection |
| **Networking** | `dio` / `retrofit` | ^5.9.0 / ^4.5.0 | Type-safe REST client with interceptors |
| **Routing** | `go_router` / `auto_route` | ^14.8.0 / 9.0.0 | Declarative URL-based deep-link navigation |
| **Local NoSQL DB** | `hive_ce` / `hive_ce_flutter`| <2.18.0 / <2.2.0 | Ultra-fast key-value cache and offline sync queue |
| **Local SQL DB** | `sqflite` | ^2.3.0 | Packaged offline SQLite dictionary (~34MB) |
| **Secure Storage** | `flutter_secure_storage` | ^9.2.2 | Encrypted credential & token storage |
| **Key-Value Store** | `shared_preferences` | ^2.2.3 | Theme, language, and user flags persistence |
| **Cloud Services** | `firebase_auth` / `cloud_firestore` | ^5.1.0 / ^5.0.1 | Cloud identity and real-time syncing |
| **Machine Learning** | `google_mlkit_text_recognition` | ^0.13.0 | On-device OCR from camera and images |
| **Audio & Speech** | `flutter_tts` / `speech_to_text` | ^4.0.2 / ^7.0.0 | Text-to-speech pronunciation & speech recognition |
| **Utilities** | `connectivity_plus`, `file_picker` | ^6.0.3, ^8.0.5 | Network monitoring, PDF/document picker |

### Backend (REST API)

| Category | Technology | Version | Purpose |
|---|---|---|---|
| **Framework** | Spring Boot | 4.0.4 | Enterprise Java application framework |
| **Language** | Java (OpenJDK / Temurin) | 17 LTS | High-performance compiled backend runtime |
| **Architecture** | Modular Monolith | — | Clean separation of business domains & events |
| **Database** | PostgreSQL | 15+ / 16 Alpine | Relational ACID database |
| **ORM & Data** | Spring Data JPA / Hibernate | (managed) | Declarative repository persistence |
| **Connection Pool** | HikariCP | (managed) | High-throughput connection pool (max 20) |
| **AI Integration** | Google Gemini API | gemini-2.5-flash | Content generation, quiz synthesis, smart dictionary |
| **PDF Processing** | Apache PDFBox | 2.0.30 | High-accuracy text extraction from PDF uploads |
| **Security / Hashing**| jBCrypt | 0.4 | Salted password hashing (Blowfish cipher) |
| **Documentation** | SpringDoc OpenAPI / Swagger 3 | 2.8.5 | Automated interactive API documentation |
| **Containerization**| Docker & Docker Compose | Multi-stage | Isolated packaging for local dev and cloud deploy |
| **Build Tool** | Maven Wrapper (`mvnw`) | 3.9+ | Reproducible dependency & build management |

---

## 🗄 Database Model

### Entity Relationship Diagram

```
┌─────────────────────────────────┐
│              users              │
├─────────────────────────────────┤
│ id (BIGSERIAL, PK)              │
│ email (VARCHAR, UQ, NOT NULL)   │
│ username (VARCHAR, UQ)          │
│ password (VARCHAR)              │
│ streak (INT, DEFAULT 0)         │
│ lives (INT, DEFAULT 5)          │
│ total_xp (INT, DEFAULT 0)       │
│ watered_plants (INT, DEFAULT 0) │
│ major (VARCHAR)                 │
│ last_study_date (DATE)          │
└─────────────────────────────────┘

┌─────────────────────────────────┐       ┌─────────────────────────────────┐
│             lessons             │       │            question             │
├─────────────────────────────────┤       ├─────────────────────────────────┤
│ id (BIGSERIAL, PK)              │───┐   │ id (BIGSERIAL, PK)              │
│ title (VARCHAR)                 │   │   │ sentence_start (TEXT)           │
│ content (TEXT)                  │   │   │ sentence_end (TEXT)             │
│ pdf_url (VARCHAR 1000)          │   │   │ option_a, option_b, option_c,   │
│ quiz_type (VARCHAR)             │   └──<│ option_d (VARCHAR)              │
│ progress (INT, 0-100)           │   │   │ correct_answer (VARCHAR)        │
│ category (VARCHAR)              │   │   │ explanation (VARCHAR)           │
│ username (VARCHAR)              │   │   │ lesson_id (BIGINT, FK)          │
│ created_at (TIMESTAMP)          │   │   └─────────────────────────────────┘
└─────────────────────────────────┘   │
                                      │   ┌─────────────────────────────────┐
                                      │   │          vocabularies           │
                                      │   ├─────────────────────────────────┤
                                      └──<│ id (BIGSERIAL, PK)              │
                                          │ word (VARCHAR)                  │
┌─────────────────────────────────┐       │ phonetic (VARCHAR)              │
│         daily_progress          │       │ meaning (VARCHAR)               │
├─────────────────────────────────┤       │ example (TEXT)                  │
│ id (BIGSERIAL, PK)              │       │ lesson_id (BIGINT, FK)          │
│ username (VARCHAR)              │       └─────────────────────────────────┘
│ study_date (DATE)               │
│ minutes_learned (INT)           │       * Unique Constraint:
│ daily_goal (INT, DEFAULT 45)    │         (username, study_date) on daily_progress
│ is_goal_achieved (BOOLEAN)      │
│ streak_count (INT)              │
└─────────────────────────────────┘
```

---

## 📡 API Endpoints

Interactive Swagger UI available at: `http://localhost:8080/swagger-ui/index.html`

### 👤 Module Identity (`/api/users`)

| Method | Endpoint | Description |
|:---:|---|---|
| `GET` | `/api/users` | List all registered users |
| `POST` | `/api/users/register` | Register new user account with hashed password |
| `POST` | `/api/users/login` | Authenticate user credentials (`{username, password}`) |
| `GET` | `/api/users/profile?username=` | Retrieve user stats (XP, streak, watered plants) |
| `POST` | `/api/users/update-major?username=&major=` | Update learner's specialized major |
| `PUT` | `/api/users/update-progress?username=` | Award study completion (+20 XP, calculate streak) |
| `POST` | `/api/users/update-plants?username=&plants=` | Water vocabulary garden (+5 XP per plant) |
| `GET` | `/api/users/leaderboard` | Get Top 10 global leaderboard ranked by XP |

### 📝 Module Learning (`/api/lessons`)

| Method | Endpoint | Description |
|:---:|---|---|
| `POST` | `/api/lessons/generate-by-topic` | Create or clone a lesson by topic (`topic`, `quizType`, `username`, `category`) |
| `POST` | `/api/lessons/upload` | Parse uploaded PDF and generate quizzes (`file`, `quizType`, `username`) |
| `POST` | `/api/lessons/update-progress` | Save lesson progress percentage (`{lessonId, progress}`) → fires event on 100% |
| `GET` | `/api/lessons/my-lessons?username=` | Retrieve user's completed/in-progress lessons |
| `GET` | `/api/lessons/roadmap?major=` | Retrieve tailored learning roadmap steps by major |
| `POST` | `/api/lessons/admin/pre-generate-batch` | [Admin] Batch pre-generate popular lesson templates |

### 📖 Module AI (`/api/dictionary`)

| Method | Endpoint | Description |
|:---:|---|---|
| `GET` | `/api/dictionary/lookup?word=` | Contextual AI dictionary definition (IPA, part of speech, meanings, examples, synonyms) |

### 📊 Module Gamification (`/api/progress`)

| Method | Endpoint | Description |
|:---:|---|---|
| `GET` | `/api/progress/today?username=` | Get current day's progress and streak metrics |
| `POST` | `/api/progress/add-time` | Record completed learning minutes (`{username, minutes}`) |

---

## 🚀 Installation & Running

### Prerequisites

| Tool | Version Requirement | Purpose |
|---|---|---|
| **Java JDK** | OpenJDK 17 LTS (Adoptium Temurin) | Backend compilation and execution |
| **PostgreSQL** | Version 15+ (or Docker) | Relational database |
| **Flutter SDK** | Version 3.10+ (Dart ^3.4.0) | Mobile app SDK |
| **Gemini API Key** | Free tier from [Google AI Studio](https://aistudio.google.com/apikey) | Generative AI features |
| **Docker & Compose** | Optional (Recommended) | One-command fullstack environment |

---

### Option 1: Quickstart with Docker Compose (Recommended)

Start the entire backend ecosystem (PostgreSQL 16 + Spring Boot + pgAdmin) in isolated containers:

```bash
# 1. Navigate to backend directory
cd ai_learning_backend

# 2. Set your Gemini API key in .env (copy from .env.example)
cp .env.example .env
# Edit .env and supply your GEMINI_API_KEY

# 3. Spin up all containers
docker compose up -d --build

# 4. Check status
docker compose ps
```

- **Backend API & Swagger UI**: `http://localhost:8080/swagger-ui/index.html`
- **pgAdmin Database Web UI**: `http://localhost:5050` (Email: `admin@ailearning.com`, Password: `admin`)

---

### Option 2: Manual Local Setup

#### 1️⃣ Start PostgreSQL Database
```bash
psql -U postgres
CREATE DATABASE ai_learning_db;
```

#### 2️⃣ Run Spring Boot Backend
```bash
cd ai_learning_backend

# Set Gemini API Key
# Linux / macOS:
export GEMINI_API_KEY="your_api_key_here"
# Windows (PowerShell):
$env:GEMINI_API_KEY="your_api_key_here"

# Run with Maven Wrapper
./mvnw spring-boot:run          # Linux/macOS
.\mvnw.cmd spring-boot:run      # Windows
```

#### 3️⃣ Run Flutter Mobile App
```bash
cd ai_learning_app

# Fetch dependencies
flutter pub get

# Run code generator (if needed for injectable / freezed)
dart run build_runner build --delete-conflicting-outputs

# Launch on connected device or emulator
flutter run

# Or target specific backend endpoint explicitly:
flutter run --dart-define=API_URL=http://10.0.2.2:8080     # Android Emulator
flutter run --dart-define=API_URL=http://localhost:8080    # iOS Simulator / Web / Desktop
flutter run --dart-define=API_URL=http://192.168.1.x:8080 # Physical Device (Wi-Fi LAN)
```

---

## 🔧 Environment Variables

| Variable | Required | Default Value | Description |
|---|:---:|---|---|
| `GEMINI_API_KEY` | ✅ | — | Google Gemini Generative Language API Key |
| `DB_URL` | ❌ | `jdbc:postgresql://localhost:5432/ai_learning_db` | JDBC PostgreSQL connection URL |
| `DB_USERNAME` | ❌ | `postgres` | Database username |
| `DB_PASSWORD` | ❌ | `123123` | Database password |
| `DB_POOL_MAX_SIZE` | ❌ | `20` | HikariCP max pool size |
| `DB_POOL_MIN_IDLE` | ❌ | `5` | HikariCP minimum idle connections |
| `SERVER_THREADS_MAX` | ❌ | `200` | Tomcat max request worker threads |
| `MAX_UPLOAD_FILE_SIZE` | ❌ | `10MB` | Max upload size per PDF document |
| `MAX_UPLOAD_REQUEST_SIZE` | ❌ | `12MB` | Max multipart HTTP request size |

---

## 👨‍💻 Author

**Dang Thanh Vu** — Fullstack Mobile & Backend Developer

---

<div align="center">

*Engineered with clean code principles using Flutter BLoC, Spring Boot Modular Monolith & Google Gemini AI*

</div>
