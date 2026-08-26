import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/http_compat.dart' as http;

class AuthProvider extends ChangeNotifier {
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;
  String? get errorMessage => _errorMessage;

  String get currentUsername =>
      _currentUser?.username ??
      FirebaseAuth.instance.currentUser?.displayName ??
      FirebaseAuth.instance.currentUser?.email?.split('@')[0] ??
      '';

  String? get currentMajor => _currentUser?.major;

  AuthProvider() {
    _initUser();
  }

  void _initUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUser = UserEntity(
        id: user.uid,
        username: user.displayName ?? user.email?.split('@')[0] ?? '',
        email: user.email ?? '',
      );
    }
  }

  void setUserMajor(String major) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(major: major);
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final username = credential.user?.displayName ?? email.split('@')[0];

      // Fetch user profile from Spring Boot backend
      String? major;
      int totalXp = 0;
      int streak = 0;

      try {
        final res = await http.post(
          Uri.parse('${ApiConstants.users}/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password.trim()}),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          major = data['major'];
          totalXp = (data['totalXp'] as num?)?.toInt() ?? 0;
          streak = (data['streak'] as num?)?.toInt() ?? 0;
        }
      } catch (_) {}

      _currentUser = UserEntity(
        id: credential.user!.uid,
        username: username,
        email: email.trim(),
        major: major,
        totalXp: totalXp,
        streak: streak,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Đăng nhập thất bại';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi hệ thống: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await credential.user?.updateDisplayName(username.trim());

      // Sync user with backend
      try {
        await http.post(
          Uri.parse('${ApiConstants.users}/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username.trim(),
            'email': email.trim(),
            'password': password.trim(),
          }),
        );
      } catch (_) {}

      _currentUser = UserEntity(
        id: credential.user!.uid,
        username: username.trim(),
        email: email.trim(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Đăng ký thất bại';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi hệ thống: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
