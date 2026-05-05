/// Lớp quản lý tất cả chuỗi hiển thị của ứng dụng theo ngôn ngữ.
/// Sử dụng: AppLocalizations.of(context).translate('key')
/// hoặc shortcut: S.of(context, 'key')

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  /// Truy cập nhanh từ context (an toàn khi Provider chưa sẵn sàng)
  static AppLocalizations of(BuildContext context) {
    try {
      final lang = Provider.of<LanguageProvider>(context, listen: false).languageCode;
      return AppLocalizations(lang);
    } catch (_) {
      // Fallback về Tiếng Việt nếu Provider chưa được đăng ký (ví dụ sau hot-reload)
      return AppLocalizations('vi');
    }
  }

  /// Hàm dịch từ key
  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? _localizedValues['vi']?[key] ?? key;
  }

  // ============================================
  // TẤT CẢ CÁC CHUỖI HIỂN THỊ TRONG APP
  // ============================================
  static const Map<String, Map<String, String>> _localizedValues = {
    // ========== TIẾNG VIỆT ==========
    'vi': {
      // --- Profile Screen ---
      'profile': 'Hồ sơ',
      'student': 'Học viên',
      'total_xp': 'TỔNG XP',
      'lessons': 'BÀI HỌC',
      'streak': 'CHUỖI NGÀY',
      'account': 'TÀI KHOẢN',
      'change_account_info': 'Đổi thông tin tài khoản',
      'privacy_settings': 'Cài đặt bảo mật',
      'preferences': 'TÙY CHỈNH',
      'dark_mode': 'Chế độ tối',
      'language': 'Ngôn ngữ',
      'notifications': 'Thông báo',
      'other': 'KHÁC',
      'help_center': 'Trung tâm hỗ trợ',
      'about_us': 'Về chúng tôi',
      'logout': 'Đăng xuất',
      'dark_mode_on': 'Đã bật Chế độ tối',
      'dark_mode_off': 'Đã tắt Chế độ tối',
      'opening_settings': 'Đang mở Cài đặt chung...',
      'opening_account_info': 'Đang mở trang Đổi thông tin...',
      'opening_privacy': 'Đang mở Cài đặt bảo mật...',
      'opening_notifications': 'Đang mở Cài đặt thông báo...',
      'opening_gallery': 'Đang mở thư viện ảnh...',
      'connecting_help': 'Đang kết nối đến Trung tâm hỗ trợ...',
      'about_app': 'Về App',
      'about_app_content': 'Phiên bản 1.0.0\n\nỨng dụng học tập thông minh tích hợp AI, giúp bạn biến mọi tài liệu thành bài giảng tương tác.',
      'close': 'Đóng',
      'logout_confirm_title': 'Đăng xuất',
      'logout_confirm_message': 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này không?',
      'cancel': 'Hủy',
      'logout_success': 'Đã đăng xuất thành công!',
      'choose_language': 'Chọn ngôn ngữ',
      'language_changed': 'Đã đổi ngôn ngữ sang',

      // --- Home Screen ---
      'search_hint': 'Tìm kiếm từ vựng (Anh-Việt, V...',
      'enter_text': 'Nhập văn bản cần dịch...',
      'translation_result': 'Bản dịch sẽ xuất hiện ở đây...',
      'listening': 'Đang nghe...',
      'study_materials': 'Tài liệu học tập',
      'study_materials_desc': 'Phân tích tài liệu PDF để tạo bài học',
      'upload_pdf': 'Upload PDF Document',
      'auto_create_quiz': 'Tự động tạo Quiz & Flashcard',
      'new_feature': 'TÍNH NĂNG MỚI',
      'vocabulary_garden_title': 'Vườn ươm từ vựng\ncủa bạn',
      'vocabulary_garden_desc': 'Theo dõi sự tiến bộ hàng ngày. Mỗi\ntừ vựng bạn học được sẽ giúp khu\nvườn tri thức của bạn nở rộ hơn.',
      'explore_now': 'Khám phá ngay',
      'take_new_photo': 'Chụp ảnh mới',
      'choose_from_gallery': 'Chọn từ thư viện',
      'choose_study_mode': 'Chọn chế độ học',
      'ai_design_lesson': 'AI sẽ thiết kế bài học theo cách bạn muốn!',
      'drag_drop_vocab': 'Kéo thả từ vựng',
      'multiple_choice': 'Trắc nghiệm',
      'fill_blank': 'Bài đục lỗ',
      'ai_preparing': 'AI đang soạn bài học...',
      'translation_error': 'Lỗi dịch thuật...',
      'ai_analyzing': 'Đang nhờ AI phân tích cụm từ này...',
      'dict_error': 'Lỗi đọc từ điển',
      'english_lang': 'TIẾNG ANH',
      'vietnamese_lang': 'TIẾNG VIỆT',

      // --- Welcome Screen ---
      'learn_free': 'Học miễn phí. Suốt đời.',
      'get_started': 'BẮT ĐẦU NGAY',
      'have_account': 'TÔI ĐÃ CÓ TÀI KHOẢN',

      // --- Discover Screen ---
      'leaderboard': 'Bảng xếp hạng',
      'season': 'Mùa',
      'rank_detail': 'Chi tiết thứ hạng',
      'updated_ago': 'Cập nhật 5 phút trước',
      'your_rank': 'THỨ HẠNG CỦA BẠN',
      'leading': 'Bạn đang Dẫn đầu!',
      'keep_trying': 'Cần nỗ lực hơn',
      'demo_data_notice': 'Đang dùng dữ liệu mẫu. Bấm để thử lại.',

      // --- My Lessons Screen ---
      'my_lessons': 'Bài học của tôi',
      'daily_goal': 'Mục tiêu hàng ngày',
      'day_streak': 'Ngày liên tiếp',
      'active_courses': 'Khóa học đang học',
      'view_all': 'Xem tất cả',
      'no_lessons': 'Chưa có bài học nào. Hãy upload PDF nhé!',
      'progress': 'TIẾN ĐỘ',
      'new_lesson': 'Bài học mới',
      'drag_drop_type': 'Kéo thả từ vựng',
      'multiple_choice_type': 'Trắc nghiệm A,B,C,D',
      'fill_blank_type': 'Bài tập đục lỗ',
      'study_material_type': 'Tài liệu học tập',

      // --- Vocabulary Garden Screen ---
      'your_garden': 'Vườn Ươm Của Bạn',
      'garden_empty': 'Khu vườn đang trống!',
      'garden_empty_desc': 'Hãy ra ngoài tra từ và gieo\nthêm hạt giống nhé.',
      'water_trees': 'Tưới',
      'trees_unit': 'cây',
      'all_watered': 'Đã tưới xong hôm nay',
      'all_watered_msg': 'Tuyệt vời! Toàn bộ cây đã được tưới đủ nước hôm nay.',
      'removed_from_garden': 'Đã nhổ',
      'from_garden': 'khỏi vườn.',
    },

    // ========== ENGLISH ==========
    'en': {
      // --- Profile Screen ---
      'profile': 'Profile',
      'student': 'Student',
      'total_xp': 'TOTAL XP',
      'lessons': 'LESSONS',
      'streak': 'STREAK',
      'account': 'ACCOUNT',
      'change_account_info': 'Change Account Info',
      'privacy_settings': 'Privacy Settings',
      'preferences': 'PREFERENCES',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'notifications': 'Notifications',
      'other': 'OTHER',
      'help_center': 'Help Center',
      'about_us': 'About Us',
      'logout': 'Logout',
      'dark_mode_on': 'Dark Mode enabled',
      'dark_mode_off': 'Dark Mode disabled',
      'opening_settings': 'Opening Settings...',
      'opening_account_info': 'Opening Account Info...',
      'opening_privacy': 'Opening Privacy Settings...',
      'opening_notifications': 'Opening Notification Settings...',
      'opening_gallery': 'Opening Gallery...',
      'connecting_help': 'Connecting to Help Center...',
      'about_app': 'About App',
      'about_app_content': 'Version 1.0.0\n\nAn AI-powered smart learning app that transforms any document into interactive lessons.',
      'close': 'Close',
      'logout_confirm_title': 'Logout',
      'logout_confirm_message': 'Are you sure you want to logout from this account?',
      'cancel': 'Cancel',
      'logout_success': 'Logged out successfully!',
      'choose_language': 'Choose Language',
      'language_changed': 'Language changed to',

      // --- Home Screen ---
      'search_hint': 'Search vocabulary (EN-VN, V...',
      'enter_text': 'Enter text to translate...',
      'translation_result': 'Translation will appear here...',
      'listening': 'Listening...',
      'study_materials': 'Study Materials',
      'study_materials_desc': 'Analyze PDF documents to create lessons',
      'upload_pdf': 'Upload PDF Document',
      'auto_create_quiz': 'Auto-generate Quiz & Flashcard',
      'new_feature': 'NEW FEATURE',
      'vocabulary_garden_title': 'Your Vocabulary\nGarden',
      'vocabulary_garden_desc': 'Track your daily progress. Every\nnew word you learn will help your\nknowledge garden bloom.',
      'explore_now': 'Explore Now',
      'take_new_photo': 'Take a Photo',
      'choose_from_gallery': 'Choose from Gallery',
      'choose_study_mode': 'Choose Study Mode',
      'ai_design_lesson': 'AI will design the lesson your way!',
      'drag_drop_vocab': 'Drag & Drop Vocabulary',
      'multiple_choice': 'Multiple Choice',
      'fill_blank': 'Fill in the Blanks',
      'ai_preparing': 'AI is preparing your lesson...',
      'translation_error': 'Translation error...',
      'ai_analyzing': 'Asking AI to analyze this phrase...',
      'dict_error': 'Dictionary error',
      'english_lang': 'ENGLISH',
      'vietnamese_lang': 'VIETNAMESE',

      // --- Welcome Screen ---
      'learn_free': 'Learn for free. Forever.',
      'get_started': 'GET STARTED',
      'have_account': 'I ALREADY HAVE AN ACCOUNT',

      // --- Discover Screen ---
      'leaderboard': 'Leaderboard',
      'season': 'Season',
      'rank_detail': 'Rank Details',
      'updated_ago': 'Updated 5 min ago',
      'your_rank': 'YOUR RANK',
      'leading': 'You are Leading!',
      'keep_trying': 'Keep trying harder',
      'demo_data_notice': 'Using demo data. Tap to retry.',

      // --- My Lessons Screen ---
      'my_lessons': 'My Lessons',
      'daily_goal': 'Daily Goal',
      'day_streak': 'Day Streak',
      'active_courses': 'Active Courses',
      'view_all': 'View All',
      'no_lessons': 'No lessons yet. Upload a PDF to start!',
      'progress': 'PROGRESS',
      'new_lesson': 'New Lesson',
      'drag_drop_type': 'Drag & Drop Vocabulary',
      'multiple_choice_type': 'Multiple Choice A,B,C,D',
      'fill_blank_type': 'Fill in the Blanks',
      'study_material_type': 'Study Material',

      // --- Vocabulary Garden Screen ---
      'your_garden': 'Your Garden',
      'garden_empty': 'Your garden is empty!',
      'garden_empty_desc': 'Go search for words and plant\nsome new seeds.',
      'water_trees': 'Water',
      'trees_unit': 'trees',
      'all_watered': 'All watered today',
      'all_watered_msg': 'Great! All your trees have been fully watered today.',
      'removed_from_garden': 'Removed',
      'from_garden': 'from garden.',
    },
  };
}

/// Shortcut để gọi nhanh hơn: S.of(context, 'key')
class S {
  static String of(BuildContext context, String key) {
    return AppLocalizations.of(context).translate(key);
  }
}
