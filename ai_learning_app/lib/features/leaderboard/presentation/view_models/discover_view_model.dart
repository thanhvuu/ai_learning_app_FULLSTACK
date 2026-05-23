import 'package:ai_learning_app/features/leaderboard/domain/entities/leaderboard_user.dart';
import 'package:ai_learning_app/features/leaderboard/domain/usecases/get_leaderboard.dart';
import 'package:flutter/foundation.dart';

class DiscoverViewModel extends ChangeNotifier {
  DiscoverViewModel(this._getLeaderboard);

  final GetLeaderboard _getLeaderboard;

  List<LeaderboardUser> _leaderboard = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LeaderboardUser> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadLeaderboard() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getLeaderboard();
    result.when(
      success: (users) => _leaderboard = users,
      failure: (exception) => _errorMessage = exception.message,
    );

    _isLoading = false;
    notifyListeners();
  }
}
