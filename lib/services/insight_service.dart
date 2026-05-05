import '../core/network/api_client.dart';
import '../models/daily_insight_model.dart';

class InsightService {
  final ApiClient _apiClient;

  InsightService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch the daily astrology dashboard for a specific date
  Future<InsightDashboardModel> getDailyInsight(String date) async {
    final response = await _apiClient.get(
      '/insights/daily',
      queryParameters: {'date': date},
    );
    return InsightDashboardModel.fromJson(response.data['data']);
  }

  /// Toggle the completion state of a specific task
  Future<UserTaskModel> toggleTaskCompletion(String taskId) async {
    final response = await _apiClient.patch('/insights/tasks/$taskId/toggle');
    return UserTaskModel.fromJson(response.data['data']);
  }
}
