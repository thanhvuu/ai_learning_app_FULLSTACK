import 'package:ai_learning_app/data/models/leaderboard_user_model.dart';
import 'package:ai_learning_app/data/services/interfaces/leaderboard_service.dart';
import 'package:flutter/foundation.dart';

class DiscoverViewModel extends ChangeNotifier {
  final LeaderboardService _leaderboardService;

  DiscoverViewModel(this._leaderboardService);

  List<LeaderboardUserModel> _leaderboard = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<LeaderboardUserModel> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadLeaderboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _leaderboard = await _leaderboardService.fetchLeaderboard();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
