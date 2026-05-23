# AI Learning App (Fullstack) — Setup Guide & Engineering Review

## 1) Project Overview

This repository contains a fullstack English-learning platform with:

- **Frontend**: Flutter app (`ai_learning_app`) targeting Android/iOS/Web/Desktop.
- **Backend**: Spring Boot REST API (`ai_learning_backend`) for authentication, lesson generation, progress tracking, dictionary lookup, and leaderboard.
- **AI-powered learning features**: lesson generation by topic/PDF, vocabulary extraction, and quiz generation.

---

## 2) Key Features

### Learner Features
- User registration/login with hashed passwords (BCrypt).
- Personalized profile with XP, streak, and watered plants (gamification).
- Multiple quiz modes (drag-drop, multiple choice, fill-blank).
- Topic-based or PDF-based lesson generation.
- Vocabulary support, dictionary lookup, and translation tools.
- Daily progress tracking.
- Leaderboard (Top users by XP).

### AI/Smart Features
- AI lesson/quiz generation from text/PDF.
- Dictionary lookup endpoint backed by AI.
- OCR and speech/tts integrations in the app for language support workflows.

---

## 3) Architecture (High Level)

- **Flutter UI (MVVM-ish organization)**
  - `presentation/`: screens and widgets
  - `data/`: models and services
  - `core/`: config/network/localization
- **Spring Boot API**
  - `controller/`: REST endpoints
  - `service/`: business logic (AI, PDF, progress)
  - `repository/`: JPA repositories
  - `entity/`: persistence model

Communication is done via HTTP APIs configured by the frontend API config.

---

## 4) Prerequisites

## Backend
- Java 17+ (recommended for Spring Boot 3.x compatibility)
- Maven 3.8+
- MySQL (or whichever DB your `application.properties` is configured for)

## Frontend
- Flutter SDK (stable channel)
- Dart SDK (included with Flutter)
- Android Studio/Xcode (depending on target platform)

---

## 5) Backend Setup (`ai_learning_backend`)

1. Go to backend folder:
   ```bash
   cd ai_learning_backend
   ```

2. Configure environment and database in:
   - `src/main/resources/application.properties`

   Typical values to verify:
   - `spring.datasource.url`
   - `spring.datasource.username`
   - `spring.datasource.password`
   - JPA/Hibernate settings
   - any API keys required by AI service logic

3. Run backend:
   ```bash
   ./mvnw spring-boot:run
   ```
   (Windows: `mvnw.cmd spring-boot:run`)

4. Default local server:
   - usually `http://localhost:8080`

5. Verify quickly:
   - Test user endpoints (`/api/users/...`) with Postman/curl.

---

## 6) Frontend Setup (`ai_learning_app`)

1. Go to app folder:
   ```bash
   cd ai_learning_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure API base URL in:
   - `lib/core/config/api_config.dart`

   Ensure this points to your backend host/port.

4. Platform-specific setup:
   - Android: verify `android/app/google-services.json` if Firebase is used.
   - iOS: verify Pods and Firebase plist (if needed).

5. Run app:
   ```bash
   flutter run
   ```

6. Optional web run:
   ```bash
   flutter run -d chrome
   ```

---

## 7) Suggested Local Development Workflow

1. Start backend first (`:8080`).
2. Run Flutter app and test login/lesson flows.
3. Validate:
   - register/login
   - generate lesson by topic
   - upload PDF learning content
   - complete quiz and check XP/streak updates
   - leaderboard display

---

## 8) Senior Engineering Review — What Should Be Improved

Below are practical, high-impact improvements for production quality:

### A. Security & Auth
1. **Replace basic login response with JWT-based auth**:
   - avoid returning full user entity directly.
   - add access/refresh token strategy.
2. **Role-based authorization** for admin/user actions.
3. **Restrict CORS** to known frontend origins (avoid `*` in production).
4. **Input validation** using Jakarta Validation (`@Valid`, `@NotBlank`, etc.).

### B. API & Error Handling
1. **Standardize API response format**:
   - e.g. `{ success, data, errorCode, message, timestamp }`.
2. **Global exception handler** with `@ControllerAdvice`.
3. **Version APIs** (`/api/v1/...`) for safer evolution.

### C. Data/Domain Design
1. **DTO layer** instead of exposing entities directly.
2. **Transactions** for multi-step lesson clone/create operations.
3. **Indexing and query tuning** for leaderboard, username lookup, lesson list.

### D. AI & Reliability
1. **Add retry/backoff & timeout policies** for AI calls.
2. **Cache frequent AI responses** (topic templates, dictionary results).
3. **Audit logging** for AI prompt/result metadata (without sensitive data).

### E. Frontend Code Quality
1. **Refactor large screens** (e.g., Home screen) into smaller widgets/services.
2. **Unified state management strategy** (Provider is okay; scale with Riverpod/Bloc if needed).
3. **Improve localization consistency** (remove mixed-language comments/messages).
4. **Graceful loading/error states** across all async operations.

### F. Testing & DevOps
1. **Backend tests**:
   - service + controller integration tests (`MockMvc`, Testcontainers).
2. **Frontend tests**:
   - widget tests for core flows; mock HTTP services.
3. **CI pipeline**:
   - lint, test, build checks for both app and backend.
4. **Environment separation**:
   - `.env`/profiles for local, staging, production.

### G. Observability
1. Add structured logging (JSON logs).
2. Add metrics and health checks (`Spring Boot Actuator`).
3. Add tracing/correlation IDs for request chains.

---

## 9) Suggested Next Milestones

1. Introduce JWT auth + DTO mapping + global exception handling.
2. Split and refactor Home screen into feature modules.
3. Add CI with mandatory test/lint gates.
4. Add staging environment and deployment runbook.

---

## 10) Quick Start Commands

### Backend
```bash
cd ai_learning_backend
./mvnw spring-boot:run
```

### Frontend
```bash
cd ai_learning_app
flutter pub get
flutter run
```

---

If you want, I can generate a **production-ready README set** next:
- `/README.md` (root)
- `/ai_learning_backend/README.md`
- `/ai_learning_app/README.md`
with badges, architecture diagrams, and API endpoint tables.
