import 'dart:convert';

import 'package:ai_learning_app/core/config/api_config.dart';
import 'package:ai_learning_app/data/models/leaderboard_user_model.dart';
import 'package:ai_learning_app/data/services/interfaces/leaderboard_service.dart';
import 'package:http/http.dart' as http;

class LeaderboardServiceImpl implements LeaderboardService {
  @override
  Future<List<LeaderboardUserModel>> fetchLeaderboard() async {
    final String apiUrl = "${ApiConfig.users}/leaderboard";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load leaderboard: ${response.statusCode}');
    }

    final List<dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(LeaderboardUserModel.fromJson)
        .toList();
  }
}
