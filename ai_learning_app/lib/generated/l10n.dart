// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Student`
  String get student {
    return Intl.message(
      'Student',
      name: 'student',
      desc: '',
      args: [],
    );
  }

  /// `TOTAL XP`
  String get total_xp {
    return Intl.message(
      'TOTAL XP',
      name: 'total_xp',
      desc: '',
      args: [],
    );
  }

  /// `LESSONS`
  String get lessons {
    return Intl.message(
      'LESSONS',
      name: 'lessons',
      desc: '',
      args: [],
    );
  }

  /// `STREAK`
  String get streak {
    return Intl.message(
      'STREAK',
      name: 'streak',
      desc: '',
      args: [],
    );
  }

  /// `ACCOUNT`
  String get account {
    return Intl.message(
      'ACCOUNT',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Change Account Info`
  String get change_account_info {
    return Intl.message(
      'Change Account Info',
      name: 'change_account_info',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Settings`
  String get privacy_settings {
    return Intl.message(
      'Privacy Settings',
      name: 'privacy_settings',
      desc: '',
      args: [],
    );
  }

  /// `PREFERENCES`
  String get preferences {
    return Intl.message(
      'PREFERENCES',
      name: 'preferences',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message(
      'Dark Mode',
      name: 'dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `OTHER`
  String get other {
    return Intl.message(
      'OTHER',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `Help Center`
  String get help_center {
    return Intl.message(
      'Help Center',
      name: 'help_center',
      desc: '',
      args: [],
    );
  }

  /// `About Us`
  String get about_us {
    return Intl.message(
      'About Us',
      name: 'about_us',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode enabled`
  String get dark_mode_on {
    return Intl.message(
      'Dark Mode enabled',
      name: 'dark_mode_on',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode disabled`
  String get dark_mode_off {
    return Intl.message(
      'Dark Mode disabled',
      name: 'dark_mode_off',
      desc: '',
      args: [],
    );
  }

  /// `Opening Settings...`
  String get opening_settings {
    return Intl.message(
      'Opening Settings...',
      name: 'opening_settings',
      desc: '',
      args: [],
    );
  }

  /// `Opening Account Info...`
  String get opening_account_info {
    return Intl.message(
      'Opening Account Info...',
      name: 'opening_account_info',
      desc: '',
      args: [],
    );
  }

  /// `Opening Privacy Settings...`
  String get opening_privacy {
    return Intl.message(
      'Opening Privacy Settings...',
      name: 'opening_privacy',
      desc: '',
      args: [],
    );
  }

  /// `Opening Notification Settings...`
  String get opening_notifications {
    return Intl.message(
      'Opening Notification Settings...',
      name: 'opening_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Opening Gallery...`
  String get opening_gallery {
    return Intl.message(
      'Opening Gallery...',
      name: 'opening_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Connecting to Help Center...`
  String get connecting_help {
    return Intl.message(
      'Connecting to Help Center...',
      name: 'connecting_help',
      desc: '',
      args: [],
    );
  }

  /// `About App`
  String get about_app {
    return Intl.message(
      'About App',
      name: 'about_app',
      desc: '',
      args: [],
    );
  }

  /// `Version 1.0.0\n\nAn AI-powered smart learning app that transforms any document into interactive lessons.`
  String get about_app_content {
    return Intl.message(
      'Version 1.0.0\n\nAn AI-powered smart learning app that transforms any document into interactive lessons.',
      name: 'about_app_content',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout_confirm_title {
    return Intl.message(
      'Logout',
      name: 'logout_confirm_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout from this account?`
  String get logout_confirm_message {
    return Intl.message(
      'Are you sure you want to logout from this account?',
      name: 'logout_confirm_message',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Logged out successfully!`
  String get logout_success {
    return Intl.message(
      'Logged out successfully!',
      name: 'logout_success',
      desc: '',
      args: [],
    );
  }

  /// `Choose Language`
  String get choose_language {
    return Intl.message(
      'Choose Language',
      name: 'choose_language',
      desc: '',
      args: [],
    );
  }

  /// `Language changed to`
  String get language_changed {
    return Intl.message(
      'Language changed to',
      name: 'language_changed',
      desc: '',
      args: [],
    );
  }

  /// `Search vocabulary (EN-VN, V...`
  String get search_hint {
    return Intl.message(
      'Search vocabulary (EN-VN, V...',
      name: 'search_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enter text to translate...`
  String get enter_text {
    return Intl.message(
      'Enter text to translate...',
      name: 'enter_text',
      desc: '',
      args: [],
    );
  }

  /// `Translation will appear here...`
  String get translation_result {
    return Intl.message(
      'Translation will appear here...',
      name: 'translation_result',
      desc: '',
      args: [],
    );
  }

  /// `Listening...`
  String get listening {
    return Intl.message(
      'Listening...',
      name: 'listening',
      desc: '',
      args: [],
    );
  }

  /// `Study Materials`
  String get study_materials {
    return Intl.message(
      'Study Materials',
      name: 'study_materials',
      desc: '',
      args: [],
    );
  }

  /// `Analyze PDF documents to create lessons`
  String get study_materials_desc {
    return Intl.message(
      'Analyze PDF documents to create lessons',
      name: 'study_materials_desc',
      desc: '',
      args: [],
    );
  }

  /// `Upload PDF Document`
  String get upload_pdf {
    return Intl.message(
      'Upload PDF Document',
      name: 'upload_pdf',
      desc: '',
      args: [],
    );
  }

  /// `Auto-generate Quiz & Flashcard`
  String get auto_create_quiz {
    return Intl.message(
      'Auto-generate Quiz & Flashcard',
      name: 'auto_create_quiz',
      desc: '',
      args: [],
    );
  }

  /// `NEW FEATURE`
  String get new_feature {
    return Intl.message(
      'NEW FEATURE',
      name: 'new_feature',
      desc: '',
      args: [],
    );
  }

  /// `Your Vocabulary\nGarden`
  String get vocabulary_garden_title {
    return Intl.message(
      'Your Vocabulary\nGarden',
      name: 'vocabulary_garden_title',
      desc: '',
      args: [],
    );
  }

  /// `Track your daily progress. Every\nnew word you learn will help your\nknowledge garden bloom.`
  String get vocabulary_garden_desc {
    return Intl.message(
      'Track your daily progress. Every\nnew word you learn will help your\nknowledge garden bloom.',
      name: 'vocabulary_garden_desc',
      desc: '',
      args: [],
    );
  }

  /// `Explore Now`
  String get explore_now {
    return Intl.message(
      'Explore Now',
      name: 'explore_now',
      desc: '',
      args: [],
    );
  }

  /// `Take a Photo`
  String get take_new_photo {
    return Intl.message(
      'Take a Photo',
      name: 'take_new_photo',
      desc: '',
      args: [],
    );
  }

  /// `Choose from Gallery`
  String get choose_from_gallery {
    return Intl.message(
      'Choose from Gallery',
      name: 'choose_from_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Choose Study Mode`
  String get choose_study_mode {
    return Intl.message(
      'Choose Study Mode',
      name: 'choose_study_mode',
      desc: '',
      args: [],
    );
  }

  /// `AI will design the lesson your way!`
  String get ai_design_lesson {
    return Intl.message(
      'AI will design the lesson your way!',
      name: 'ai_design_lesson',
      desc: '',
      args: [],
    );
  }

  /// `Drag & Drop Vocabulary`
  String get drag_drop_vocab {
    return Intl.message(
      'Drag & Drop Vocabulary',
      name: 'drag_drop_vocab',
      desc: '',
      args: [],
    );
  }

  /// `Multiple Choice`
  String get multiple_choice {
    return Intl.message(
      'Multiple Choice',
      name: 'multiple_choice',
      desc: '',
      args: [],
    );
  }

  /// `Fill in the Blanks`
  String get fill_blank {
    return Intl.message(
      'Fill in the Blanks',
      name: 'fill_blank',
      desc: '',
      args: [],
    );
  }

  /// `AI is preparing your lesson...`
  String get ai_preparing {
    return Intl.message(
      'AI is preparing your lesson...',
      name: 'ai_preparing',
      desc: '',
      args: [],
    );
  }

  /// `Translation error...`
  String get translation_error {
    return Intl.message(
      'Translation error...',
      name: 'translation_error',
      desc: '',
      args: [],
    );
  }

  /// `Asking AI to analyze this phrase...`
  String get ai_analyzing {
    return Intl.message(
      'Asking AI to analyze this phrase...',
      name: 'ai_analyzing',
      desc: '',
      args: [],
    );
  }

  /// `Dictionary error`
  String get dict_error {
    return Intl.message(
      'Dictionary error',
      name: 'dict_error',
      desc: '',
      args: [],
    );
  }

  /// `ENGLISH`
  String get english_lang {
    return Intl.message(
      'ENGLISH',
      name: 'english_lang',
      desc: '',
      args: [],
    );
  }

  /// `VIETNAMESE`
  String get vietnamese_lang {
    return Intl.message(
      'VIETNAMESE',
      name: 'vietnamese_lang',
      desc: '',
      args: [],
    );
  }

  /// `Learn for free. Forever.`
  String get learn_free {
    return Intl.message(
      'Learn for free. Forever.',
      name: 'learn_free',
      desc: '',
      args: [],
    );
  }

  /// `GET STARTED`
  String get get_started {
    return Intl.message(
      'GET STARTED',
      name: 'get_started',
      desc: '',
      args: [],
    );
  }

  /// `I ALREADY HAVE AN ACCOUNT`
  String get have_account {
    return Intl.message(
      'I ALREADY HAVE AN ACCOUNT',
      name: 'have_account',
      desc: '',
      args: [],
    );
  }

  /// `Leaderboard`
  String get leaderboard {
    return Intl.message(
      'Leaderboard',
      name: 'leaderboard',
      desc: '',
      args: [],
    );
  }

  /// `Season`
  String get season {
    return Intl.message(
      'Season',
      name: 'season',
      desc: '',
      args: [],
    );
  }

  /// `Rank Details`
  String get rank_detail {
    return Intl.message(
      'Rank Details',
      name: 'rank_detail',
      desc: '',
      args: [],
    );
  }

  /// `Updated 5 min ago`
  String get updated_ago {
    return Intl.message(
      'Updated 5 min ago',
      name: 'updated_ago',
      desc: '',
      args: [],
    );
  }

  /// `YOUR RANK`
  String get your_rank {
    return Intl.message(
      'YOUR RANK',
      name: 'your_rank',
      desc: '',
      args: [],
    );
  }

  /// `You are Leading!`
  String get leading {
    return Intl.message(
      'You are Leading!',
      name: 'leading',
      desc: '',
      args: [],
    );
  }

  /// `Keep trying harder`
  String get keep_trying {
    return Intl.message(
      'Keep trying harder',
      name: 'keep_trying',
      desc: '',
      args: [],
    );
  }

  /// `Using demo data. Tap to retry.`
  String get demo_data_notice {
    return Intl.message(
      'Using demo data. Tap to retry.',
      name: 'demo_data_notice',
      desc: '',
      args: [],
    );
  }

  /// `My Lessons`
  String get my_lessons {
    return Intl.message(
      'My Lessons',
      name: 'my_lessons',
      desc: '',
      args: [],
    );
  }

  /// `Daily Goal`
  String get daily_goal {
    return Intl.message(
      'Daily Goal',
      name: 'daily_goal',
      desc: '',
      args: [],
    );
  }

  /// `Day Streak`
  String get day_streak {
    return Intl.message(
      'Day Streak',
      name: 'day_streak',
      desc: '',
      args: [],
    );
  }

  /// `Active Courses`
  String get active_courses {
    return Intl.message(
      'Active Courses',
      name: 'active_courses',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get view_all {
    return Intl.message(
      'View All',
      name: 'view_all',
      desc: '',
      args: [],
    );
  }

  /// `No lessons yet. Upload a PDF to start!`
  String get no_lessons {
    return Intl.message(
      'No lessons yet. Upload a PDF to start!',
      name: 'no_lessons',
      desc: '',
      args: [],
    );
  }

  /// `PROGRESS`
  String get progress {
    return Intl.message(
      'PROGRESS',
      name: 'progress',
      desc: '',
      args: [],
    );
  }

  /// `New Lesson`
  String get new_lesson {
    return Intl.message(
      'New Lesson',
      name: 'new_lesson',
      desc: '',
      args: [],
    );
  }

  /// `Drag & Drop Vocabulary`
  String get drag_drop_type {
    return Intl.message(
      'Drag & Drop Vocabulary',
      name: 'drag_drop_type',
      desc: '',
      args: [],
    );
  }

  /// `Multiple Choice A,B,C,D`
  String get multiple_choice_type {
    return Intl.message(
      'Multiple Choice A,B,C,D',
      name: 'multiple_choice_type',
      desc: '',
      args: [],
    );
  }

  /// `Fill in the Blanks`
  String get fill_blank_type {
    return Intl.message(
      'Fill in the Blanks',
      name: 'fill_blank_type',
      desc: '',
      args: [],
    );
  }

  /// `Study Material`
  String get study_material_type {
    return Intl.message(
      'Study Material',
      name: 'study_material_type',
      desc: '',
      args: [],
    );
  }

  /// `Your Garden`
  String get your_garden {
    return Intl.message(
      'Your Garden',
      name: 'your_garden',
      desc: '',
      args: [],
    );
  }

  /// `Your garden is empty!`
  String get garden_empty {
    return Intl.message(
      'Your garden is empty!',
      name: 'garden_empty',
      desc: '',
      args: [],
    );
  }

  /// `Go search for words and plant\nsome new seeds.`
  String get garden_empty_desc {
    return Intl.message(
      'Go search for words and plant\nsome new seeds.',
      name: 'garden_empty_desc',
      desc: '',
      args: [],
    );
  }

  /// `Water`
  String get water_trees {
    return Intl.message(
      'Water',
      name: 'water_trees',
      desc: '',
      args: [],
    );
  }

  /// `trees`
  String get trees_unit {
    return Intl.message(
      'trees',
      name: 'trees_unit',
      desc: '',
      args: [],
    );
  }

  /// `All watered today`
  String get all_watered {
    return Intl.message(
      'All watered today',
      name: 'all_watered',
      desc: '',
      args: [],
    );
  }

  /// `Great! All your trees have been fully watered today.`
  String get all_watered_msg {
    return Intl.message(
      'Great! All your trees have been fully watered today.',
      name: 'all_watered_msg',
      desc: '',
      args: [],
    );
  }

  /// `Removed`
  String get removed_from_garden {
    return Intl.message(
      'Removed',
      name: 'removed_from_garden',
      desc: '',
      args: [],
    );
  }

  /// `from garden.`
  String get from_garden {
    return Intl.message(
      'from garden.',
      name: 'from_garden',
      desc: '',
      args: [],
    );
  }

  /// `Learn for free. Forever.`
  String get welcome_title {
    return Intl.message(
      'Learn for free. Forever.',
      name: 'welcome_title',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message(
      'Register',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Vocabulary Garden`
  String get garden_title {
    return Intl.message(
      'Vocabulary Garden',
      name: 'garden_title',
      desc: '',
      args: [],
    );
  }

  /// `Your garden is empty!`
  String get empty_garden {
    return Intl.message(
      'Your garden is empty!',
      name: 'empty_garden',
      desc: '',
      args: [],
    );
  }

  /// `Go search for words and plant some new seeds.`
  String get save_word_instruction {
    return Intl.message(
      'Go search for words and plant some new seeds.',
      name: 'save_word_instruction',
      desc: '',
      args: [],
    );
  }

  /// `Sprout`
  String get sprout {
    return Intl.message(
      'Sprout',
      name: 'sprout',
      desc: '',
      args: [],
    );
  }

  /// `Sapling`
  String get sapling {
    return Intl.message(
      'Sapling',
      name: 'sapling',
      desc: '',
      args: [],
    );
  }

  /// `Growing Tree`
  String get growing_tree {
    return Intl.message(
      'Growing Tree',
      name: 'growing_tree',
      desc: '',
      args: [],
    );
  }

  /// `Mature Tree`
  String get mature_tree {
    return Intl.message(
      'Mature Tree',
      name: 'mature_tree',
      desc: '',
      args: [],
    );
  }

  /// `Growth Stage`
  String get growth_stage {
    return Intl.message(
      'Growth Stage',
      name: 'growth_stage',
      desc: '',
      args: [],
    );
  }

  /// `Smart Translation`
  String get smart_translation {
    return Intl.message(
      'Smart Translation',
      name: 'smart_translation',
      desc: '',
      args: [],
    );
  }

  /// `Enter text to translate...`
  String get input_hint {
    return Intl.message(
      'Enter text to translate...',
      name: 'input_hint',
      desc: '',
      args: [],
    );
  }

  /// `Translation will appear here...`
  String get output_hint {
    return Intl.message(
      'Translation will appear here...',
      name: 'output_hint',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
