# AI Learning App – Kiến trúc MVVM (Refactor)

## 1) Mục tiêu refactor

- Tách rõ **Model / View / ViewModel** để giảm coupling giữa UI và business state.
- Chuẩn hóa cấu trúc thư mục để team dễ mở rộng tính năng theo module.
- Chuyển sang import theo `package:` để giảm lỗi đường dẫn tương đối khi di chuyển file.
- Giữ nguyên hành vi hiện tại của app, tập trung vào **maintainability** trước.

---

## 2) Cấu trúc thư mục mới

```text
lib/
├── app/
│   └── main.dart
├── core/
│   ├── config/
│   │   └── api_config.dart
│   └── localization/
│       └── app_localizations.dart
├── data/
│   ├── models/
│   │   ├── question_model.dart
│   │   └── vocabulary_model.dart
│   ├── repositories/
│   └── services/
│       └── dictionary_helper.dart
├── presentation/
│   ├── view_models/
│   │   ├── language_view_model.dart
│   │   ├── quiz_view_model.dart
│   │   └── theme_view_model.dart
│   ├── views/
│   │   ├── discover_screen.dart
│   │   ├── drag_drop_quiz_screen.dart
│   │   ├── fill_blank_screen.dart
│   │   ├── flashcard_screen.dart
│   │   ├── homescreen.dart
│   │   ├── login_screen.dart
│   │   ├── major_selection_screen.dart
│   │   ├── multiple_choice_screen.dart
│   │   ├── my_lessons_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── quiz_screen.dart
│   │   ├── roadmap_screen.dart
│   │   ├── vocabulary_garden_screen.dart
│   │   ├── vocabulary_screen.dart
│   │   └── welcome_screen.dart
│   └── widgets/
│       └── dictionary_bottom_sheet.dart
├── firebase_options.dart
└── main.dart
```

---

## 3) Mapping kiến trúc MVVM trong dự án

### Model
- Chứa dữ liệu và cấu trúc entity hiển thị/trao đổi API:
  - `data/models/question_model.dart`
  - `data/models/vocabulary_model.dart`

### ViewModel
- Quản lý trạng thái và logic liên quan đến UI:
  - `presentation/view_models/theme_view_model.dart`
  - `presentation/view_models/language_view_model.dart`
  - `presentation/view_models/quiz_view_model.dart`

### View
- Chỉ đảm nhiệm phần hiển thị, đọc state từ ViewModel:
  - toàn bộ `presentation/views/*.dart`
  - UI component dùng lại: `presentation/widgets/dictionary_bottom_sheet.dart`

### Data layer (Service / Repository)
- `data/services/dictionary_helper.dart` xử lý truy cập dữ liệu từ điển cục bộ.
- `data/repositories/` đã tạo sẵn để tiếp tục tách API/network logic khỏi screen trong bước tối ưu tiếp theo.

---

## 4) Những tối ưu đã áp dụng để dễ maintain

1. **Tách điểm vào ứng dụng**
   - `lib/main.dart` chỉ là entrypoint mỏng.
   - `lib/app/main.dart` giữ app bootstrap và dependency graph (Provider).

2. **Đồng nhất import theo package path**
   - Ví dụ: `package:ai_learning_app/data/models/...`
   - Tránh đứt import khi đổi vị trí file.

3. **Đặt tên rõ vai trò**
   - `providers/*` đổi sang `presentation/view_models/*` để phản ánh đúng MVVM.

4. **Chuẩn bị sẵn đường mở rộng**
   - Có sẵn `data/repositories` cho bước tiếp theo:
     - LessonRepository
     - AuthRepository
     - QuizRepository
     - DictionaryRepository

---

## 5) Đề xuất tối ưu tiếp theo (nên làm ngay sau refactor)

### A. Tách network khỏi View
Hiện nhiều screen đang gọi API trực tiếp bằng `http`.
Nên chuyển toàn bộ vào repositories/services:
- `AuthRepository`: login/register/user profile
- `LessonRepository`: tạo lesson, lấy danh sách lesson
- `QuizRepository`: submit result, load question set

### B. Tạo ViewModel theo feature
Mỗi view lớn có ViewModel riêng:
- `HomeViewModel`
- `MyLessonsViewModel`
- `RoadmapViewModel`
- `VocabularyGardenViewModel`

### C. Chuẩn hóa state
Dùng sealed state pattern cho mỗi màn hình:
- `initial / loading / success / error`
- giúp UI đơn giản và dễ test.

### D. Dependency Injection
Dùng `get_it` + `injectable` (hoặc Riverpod) để quản lý dependency.

### E. Test strategy
- Unit test: Model parsing + ViewModel state transitions
- Widget test: screen quan trọng
- Integration test: login -> chọn ngành -> tạo bài học -> làm quiz

---

## 6) Quy ước phát triển mới

- **Không gọi API trực tiếp trong View** (trừ prototype tạm thời).
- **Không nhét business logic vào Widget build**.
- Mọi state cần tái sử dụng phải đi qua ViewModel.
- Ưu tiên component hóa widget lặp lại.
- Ưu tiên `const` widget khi có thể.

---

## 7) Kết luận

Refactor lần này đã tái cấu trúc mã nguồn về đúng hướng MVVM, giảm rủi ro khi scale và hỗ trợ onboarding dev mới nhanh hơn. Dù chưa tách hoàn toàn network/business logic khỏi views, nền tảng kiến trúc đã sẵn sàng để tiếp tục tối ưu theo từng feature mà không phá vỡ luồng hiện có.
